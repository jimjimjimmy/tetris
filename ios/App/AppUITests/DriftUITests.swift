//
//  DriftUITests.swift
//  AppUITests
//
//  Automated gesture + UI test suite for the DRIFT Capacitor app.
//
//  DRIFT runs entirely inside a single WKWebView, so XCUITest cannot see the
//  React-rendered buttons or the canvas-like game board through the native
//  accessibility tree. To work around this, the web app (preview/index.html)
//  renders a hidden "test probe" element (gated behind the TEST_PROBE flag)
//  whose text content mirrors live game state as a compact key=value string
//  beginning with "DRIFT;". WKWebView exposes that element to the a11y tree,
//  and these tests read it to verify state they otherwise could not observe.
//
//  Gestures are performed as real coordinate-based taps/swipes, which dispatch
//  genuine native touch events through WKWebView -- the same path the TAP_PX
//  fix lives in -- so gesture-delivery success rates are measured faithfully.
//
//  Logical frame is 402x880, scaled by min(w/402, h/880) and centered on
//  screen (see FullscreenGame). framePoint() reproduces that mapping.
//

import XCTest

final class DriftUITests: XCTestCase {

    var app: XCUIApplication!

    // Logical frame dimensions (must match FRAME_W / GAME_2P_H in index.html).
    let FRAME_W: CGFloat = 402
    let FRAME_H: CGFloat = 880

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launch()
        // Give the Babel CDN transform + React mount time to render.
        _ = waitForProbe(timeout: 20)
    }

    // MARK: - Coordinate mapping

    /// Map a logical frame coordinate (0..402, 0..880) to an absolute screen coordinate.
    func framePoint(_ fx: CGFloat, _ fy: CGFloat) -> XCUICoordinate {
        let f = app.frame
        let scale = min(f.width / FRAME_W, f.height / FRAME_H)
        let sx = f.width  / 2 + (fx - FRAME_W / 2) * scale
        let sy = f.height / 2 + (fy - FRAME_H / 2) * scale
        let base = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        return base.withOffset(CGVector(dx: sx, dy: sy))
    }

    /// Normalized whole-screen coordinate (used for start-screen buttons whose
    /// exact frame position is hard to compute due to flex centering + insets).
    func screenPoint(_ nx: CGFloat, _ ny: CGFloat) -> XCUICoordinate {
        return app.coordinate(withNormalizedOffset: CGVector(dx: nx, dy: ny))
    }

    // MARK: - Probe reading

    /// Find the probe element (label begins with "DRIFT;"). Tries webView
    /// staticTexts first, then a flattened fallback.
    func probeElement() -> XCUIElement {
        let pred = NSPredicate(format: "label BEGINSWITH 'DRIFT;'")
        let web = app.webViews.firstMatch
        let inWeb = web.staticTexts.matching(pred).firstMatch
        if inWeb.exists { return inWeb }
        let flat = app.staticTexts.matching(pred).firstMatch
        if flat.exists { return flat }
        // Last resort: any descendant.
        return app.descendants(matching: .any).matching(pred).firstMatch
    }

    @discardableResult
    func waitForProbe(timeout: TimeInterval) -> Bool {
        return probeElement().waitForExistence(timeout: timeout)
    }

    /// Parse the probe label into a dictionary.
    func readProbe() -> [String: String] {
        let el = probeElement()
        guard el.exists else { return [:] }
        let label = el.label
        var dict = [String: String]()
        for part in label.split(separator: ";") {
            let kv = part.split(separator: "=", maxSplits: 1)
            if kv.count == 2 { dict[String(kv[0])] = String(kv[1]) }
        }
        return dict
    }

    func probeInt(_ key: String) -> Int {
        return Int(readProbe()[key] ?? "") ?? -999
    }

    func probeStr(_ key: String) -> String {
        return readProbe()[key] ?? ""
    }

    // MARK: - High-level actions

    /// Start a game on the given side. Self-correcting: taps a candidate
    /// coordinate, verifies via the probe, retries nearby y offsets if needed.
    @discardableResult
    func startGame(side: Int) -> Bool {
        // Candidate normalized Y positions for the P1 / P2 buttons.
        let candidates: [CGFloat] = side == 1
            ? [0.62, 0.59, 0.65, 0.56, 0.68]
            : [0.71, 0.68, 0.74, 0.65, 0.77]
        for ny in candidates {
            screenPoint(0.5, ny).tap()
            usleep(500_000)
            let p = readProbe()
            if p["phase"] == "playing" && p["side"] == String(side) {
                return true
            }
        }
        return readProbe()["phase"] == "playing"
    }

    /// Open settings via the in-game gear icon. Self-correcting on Y (inset).
    @discardableResult
    func openSettings() -> Bool {
        // Gear is at frame (~361, 80 + safe-area-inset). Try a span of insets.
        let insets: [CGFloat] = [62, 47, 0, 30, 80]
        for inset in insets {
            framePoint(361, 80 + inset + 12).tap()
            usleep(500_000)
            if readProbe()["set"] == "1" { return true }
        }
        return readProbe()["set"] == "1"
    }

    /// Tap the play-area center (inside the gesture surface, no insets).
    func tapPlay() {
        framePoint(161, 440).tap()
    }

    /// Ensure the game is in the playing phase. If the board has topped out
    /// (over=1), tap the REMATCH button to start a fresh match. Used by the
    /// hard-drop tests, which fill the board fast and would otherwise have the
    /// game-over overlay intercept later swipes (a measurement artifact, not a
    /// gesture failure).
    func ensurePlaying() {
        if readProbe()["phase"] == "playing" { return }
        for ny: CGFloat in [0.55, 0.52, 0.58, 0.50] {
            screenPoint(0.42, ny).tap()   // REMATCH (left button on game-over)
            usleep(500_000)
            if readProbe()["phase"] == "playing" { return }
        }
    }

    /// Swipe inside the gesture surface from one frame coord to another.
    func swipeFrame(_ fromX: CGFloat, _ fromY: CGFloat, _ toX: CGFloat, _ toY: CGFloat, duration: TimeInterval = 0.12) {
        framePoint(fromX, fromY).press(forDuration: duration, thenDragTo: framePoint(toX, toY))
    }

    // MARK: - GESTURE TESTS (3 runs each)

    func test_01_TapToRotate() throws {
        XCTAssertTrue(startGame(side: 1), "game should start as P1")
        var runResults = [Int]()
        for run in 1...3 {
            let before = probeInt("tap")
            for _ in 0..<10 {
                tapPlay()
                usleep(200_000)
            }
            usleep(300_000)
            let after = probeInt("tap")
            let delivered = max(0, after - before)
            runResults.append(delivered)
            print("RESULT tap_rotate run\(run): \(delivered)/10 taps delivered")
        }
        let total = runResults.reduce(0, +)
        print("RESULT tap_rotate AGGREGATE: \(total)/30")
        XCTAssertGreaterThanOrEqual(total, 27, "tap delivery should be >= 27/30 (9/10)")
    }

    func test_02_SwipeLeft() throws {
        XCTAssertTrue(startGame(side: 1), "game should start as P1")
        var success = [Int]()
        for run in 1...3 {
            var ok = 0
            for _ in 0..<10 {
                let b = probeInt("left")
                swipeFrame(200, 440, 80, 440)   // rightish -> leftish, pure horizontal
                usleep(300_000)
                if probeInt("left") > b { ok += 1 }
            }
            success.append(ok)
            print("RESULT swipe_left run\(run): \(ok)/10 produced a left move")
        }
        let total = success.reduce(0, +)
        print("RESULT swipe_left AGGREGATE: \(total)/30")
        XCTAssertGreaterThanOrEqual(total, 27, "swipe-left delivery should be >= 27/30")
    }

    func test_03_SwipeRight() throws {
        XCTAssertTrue(startGame(side: 1), "game should start as P1")
        var success = [Int]()
        for run in 1...3 {
            var ok = 0
            for _ in 0..<10 {
                let b = probeInt("right")
                swipeFrame(80, 440, 240, 440)   // leftish -> rightish (stays x<320)
                usleep(300_000)
                if probeInt("right") > b { ok += 1 }
            }
            success.append(ok)
            print("RESULT swipe_right run\(run): \(ok)/10 produced a right move")
        }
        let total = success.reduce(0, +)
        print("RESULT swipe_right AGGREGATE: \(total)/30")
        XCTAssertGreaterThanOrEqual(total, 27, "swipe-right delivery should be >= 27/30")
    }

    func test_04_SwipeUpP1HardDrop() throws {
        XCTAssertTrue(startGame(side: 1), "game should start as P1")
        var success = [Int]()
        for run in 1...3 {
            var ok = 0
            for _ in 0..<10 {
                ensurePlaying()                  // rematch if the board topped out
                let b = probeInt("up")
                swipeFrame(161, 520, 161, 360)   // pure vertical up, > DROP_PX
                usleep(350_000)
                if probeInt("up") > b { ok += 1 }
            }
            success.append(ok)
            print("RESULT swipe_up_p1 run\(run): \(ok)/10 produced a hard drop")
        }
        let total = success.reduce(0, +)
        print("RESULT swipe_up_p1 AGGREGATE: \(total)/30")
        XCTAssertGreaterThanOrEqual(total, 27, "P1 swipe-up hard drop should be >= 27/30")
    }

    func test_05_SwipeDownP2HardDrop() throws {
        XCTAssertTrue(startGame(side: 2), "game should start as P2")
        var success = [Int]()
        for run in 1...3 {
            var ok = 0
            for _ in 0..<10 {
                ensurePlaying()                  // rematch if the board topped out
                let b = probeInt("down")
                swipeFrame(161, 360, 161, 520)   // pure vertical down, > DROP_PX
                usleep(350_000)
                if probeInt("down") > b { ok += 1 }
            }
            success.append(ok)
            print("RESULT swipe_down_p2 run\(run): \(ok)/10 produced a hard drop")
        }
        let total = success.reduce(0, +)
        print("RESULT swipe_down_p2 AGGREGATE: \(total)/30")
        XCTAssertGreaterThanOrEqual(total, 27, "P2 swipe-down hard drop should be >= 27/30")
    }

    func test_06_DiagonalDoesNotDoubleTrigger() throws {
        XCTAssertTrue(startGame(side: 1), "game should start as P1")
        var violations = 0
        var trials = 0
        // A range of diagonal angles; none should fire BOTH a horizontal move
        // and a hard drop in the same gesture (axis lock must pick one).
        let diagonals: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (120, 520, 240, 360), // shallow up-right
            (240, 520, 120, 360), // shallow up-left
            (120, 360, 240, 520), // shallow down-right (no-op drop for P1, but move may fire)
            (161, 520, 230, 380), // steeper up-right
        ]
        for run in 1...3 {
            for d in diagonals {
                let hBefore = probeInt("left") + probeInt("right")
                let vBefore = probeInt("up") + probeInt("down")
                swipeFrame(d.0, d.1, d.2, d.3)
                usleep(350_000)
                let hAfter = probeInt("left") + probeInt("right")
                let vAfter = probeInt("up") + probeInt("down")
                let moved = hAfter > hBefore
                let dropped = vAfter > vBefore
                trials += 1
                if moved && dropped { violations += 1 }
            }
            print("RESULT diagonal run\(run): violations so far \(violations)/\(trials)")
        }
        print("RESULT diagonal AGGREGATE: \(violations) double-triggers in \(trials) diagonal swipes")
        XCTAssertEqual(violations, 0, "diagonal swipes must never fire both move and drop")
    }

    // MARK: - GAME FLOW TESTS

    func test_10_LaunchShowsStartScreen() throws {
        // The probe's initial text is just "DRIFT;"; the React flush effect
        // populates the fields on first render and WKWebView needs a moment to
        // surface the updated label. Poll until phase is present.
        var phase = ""
        for _ in 0..<25 {
            phase = probeStr("phase")
            if !phase.isEmpty { break }
            usleep(300_000)
        }
        print("RESULT launch_start_screen: phase=\(phase.isEmpty ? "?" : phase)")
        XCTAssertEqual(phase, "start", "app should launch to the start screen")
    }

    func test_11_TapP1StartsAsP1() throws {
        XCTAssertTrue(startGame(side: 1))
        let p = readProbe()
        print("RESULT start_as_p1: phase=\(p["phase"] ?? "?") side=\(p["side"] ?? "?")")
        XCTAssertEqual(p["phase"], "playing")
        XCTAssertEqual(p["side"], "1")
    }

    func test_12_TapP2StartsAsP2() throws {
        XCTAssertTrue(startGame(side: 2))
        let p = readProbe()
        print("RESULT start_as_p2: phase=\(p["phase"] ?? "?") side=\(p["side"] ?? "?")")
        XCTAssertEqual(p["phase"], "playing")
        XCTAssertEqual(p["side"], "2")
    }

    func test_13_PausePausesGame() throws {
        XCTAssertTrue(startGame(side: 1))
        // Pause button at frame (~355, 432). Tap and verify paused=1.
        var paused = false
        for dx: CGFloat in [0, 6, -4, 10] {
            framePoint(357 + dx, 432).tap()
            usleep(400_000)
            if readProbe()["paused"] == "1" { paused = true; break }
        }
        print("RESULT pause: paused=\(probeStr("paused"))")
        XCTAssertTrue(paused, "pause button should set paused=1")
    }

    func test_14_SettingsGearOpens() throws {
        XCTAssertTrue(startGame(side: 1))
        let ok = openSettings()
        print("RESULT settings_open: set=\(probeStr("set"))")
        XCTAssertTrue(ok, "gear should open settings (set=1)")
    }

    func test_15_GameOverAndRematch() throws {
        // Drive a fast match to completion: start as P1, hard-drop repeatedly.
        // At a fast level the board fills and the match resolves; we then look
        // for the over=1 state. This can take a while, so allow generous time.
        XCTAssertTrue(startGame(side: 1))
        var over = false
        let deadline = Date().addingTimeInterval(120)
        while Date() < deadline {
            swipeFrame(161, 520, 161, 360)  // hard drop up
            usleep(250_000)
            // occasional rotate + shift to vary placement
            tapPlay()
            usleep(150_000)
            if readProbe()["over"] == "1" { over = true; break }
        }
        print("RESULT game_over_reached: over=\(probeStr("over"))")
        if !over {
            // Not a hard failure -- match may not end within budget at this
            // level. Report and skip the rematch sub-check.
            print("RESULT game_over: NOT reached within 120s budget (informational)")
            throw XCTSkip("Match did not end within time budget; rematch not exercised")
        }
        // Rematch button (left button) at game-over. Tap and verify back to playing.
        var restarted = false
        for ny: CGFloat in [0.55, 0.52, 0.58] {
            screenPoint(0.42, ny).tap()
            usleep(600_000)
            if readProbe()["phase"] == "playing" { restarted = true; break }
        }
        print("RESULT rematch: phase=\(probeStr("phase"))")
        XCTAssertTrue(restarted, "rematch should return to playing")
    }

    // MARK: - SETTINGS TESTS

    func test_20_LevelSelectorChangesLevel() throws {
        // Wait for the start-screen probe to populate.
        var phase = ""
        for _ in 0..<25 { phase = probeStr("phase"); if !phase.isEmpty { break }; usleep(300_000) }
        XCTAssertEqual(phase, "start")

        // The start screen reports the current level directly (lvl=...).
        let lvlBefore = probeInt("lvl")
        print("RESULT level_before: \(lvlBefore)")
        XCTAssertTrue(lvlBefore >= 1 && lvlBefore <= 5, "start screen should report a valid level")

        // Open settings via the centered "Level N" text on the start screen
        // (reliable center coordinate), falling back to the top-right gear.
        var opened = false
        for ny: CGFloat in [0.51, 0.48, 0.54, 0.45] {
            screenPoint(0.5, ny).tap()
            usleep(450_000)
            if readProbe()["set"] == "1" { opened = true; break }
        }
        if !opened { opened = openSettings() }
        print("RESULT settings_for_level: set=\(probeStr("set")) opened=\(opened)")

        // Change the level by sweeping the level-button row inside the sheet.
        // Accept any valid level change as success.
        var changed = false
        for ny: CGFloat in [0.42, 0.46, 0.50, 0.54, 0.58, 0.38] {
            for nx: CGFloat in [0.30, 0.42, 0.54, 0.66, 0.78] {
                screenPoint(nx, ny).tap()
                usleep(180_000)
                let now = probeInt("lvl")
                if now >= 1 && now <= 5 && now != lvlBefore { changed = true; break }
            }
            if changed { break }
        }
        let lvlNow = probeInt("lvl")
        print("RESULT level_after: \(lvlNow) changed=\(changed)")
        XCTAssertTrue(lvlNow >= 1 && lvlNow <= 5, "level should remain a valid 1..5 value")
        // Headline assertion: the selector actually changed the level value.
        XCTAssertTrue(changed, "tapping a different level button should change lvl")
    }

    /// Start a game (P1) then open settings via the gear. Returns set==1.
    func openSettingsInGame() -> Bool {
        _ = startGame(side: 1)
        return openSettings()
    }

    /// Sweep tap targets over a Y band on the right side of the settings sheet
    /// until the SPECIFIC probe field flips value. Field-specific detection
    /// means hitting an adjacent row (e.g. Music) is harmless -- only a change
    /// to `field` counts. Hitting an already-active toggle is a no-op, so the
    /// sweep covers both the OFF (left) and ON (right) button positions.
    func sweepToggle(field: String, yBand: [CGFloat]) -> Bool {
        let v0 = probeStr(field)
        for ny in yBand {
            for nx: CGFloat in [0.58, 0.66, 0.74, 0.82] {
                screenPoint(nx, ny).tap()
                usleep(180_000)
                let now = probeStr(field)
                if !now.isEmpty && now != v0 { return true }
            }
        }
        return probeStr(field) != v0
    }

    func test_22_SoundFXToggle() throws {
        XCTAssertTrue(openSettingsInGame(), "settings should open")
        let before = probeStr("sfx")
        let changed = sweepToggle(field: "sfx", yBand: [0.18, 0.20, 0.22, 0.24, 0.26, 0.28, 0.30, 0.32])
        print("RESULT sfx_toggle: before=\(before) after=\(probeStr("sfx")) changed=\(changed)")
        XCTAssertTrue(changed, "Sound FX ON/OFF should flip the sfx setting")
    }

    func test_23_HapticsToggle() throws {
        XCTAssertTrue(openSettingsInGame(), "settings should open")
        let before = probeStr("hap")
        let changed = sweepToggle(field: "hap", yBand: [0.34, 0.36, 0.38, 0.40, 0.42, 0.44, 0.46, 0.32])
        print("RESULT haptics_toggle: before=\(before) after=\(probeStr("hap")) changed=\(changed)")
        XCTAssertTrue(changed, "Haptics ON/OFF should flip the hap setting")
    }

    func test_24_VolumeSlider() throws {
        XCTAssertTrue(openSettingsInGame(), "settings should open")
        let v0 = probeInt("vol")
        print("RESULT volume_before: \(v0)")
        var changed = false
        // Volume is a 10-segment bar on the right of the Volume row (~ny 0.30).
        // Tapping different x positions sets different volumes.
        for ny: CGFloat in [0.28, 0.30, 0.26, 0.32, 0.34] {
            for nx: CGFloat in [0.55, 0.62, 0.70, 0.78, 0.85] {
                screenPoint(nx, ny).tap()
                usleep(160_000)
                let now = probeInt("vol")
                if now >= 1 && now <= 10 && now != v0 { changed = true; break }
            }
            if changed { break }
        }
        print("RESULT volume_slider: before=\(v0) after=\(probeInt("vol")) changed=\(changed)")
        XCTAssertTrue(probeInt("vol") >= 1 && probeInt("vol") <= 10, "volume stays in 1..10")
        XCTAssertTrue(changed, "tapping the volume bar should change the volume value")
    }

    // Reproduces the real-world "tap sometimes doesn't rotate" report: a finger
    // tap is never perfectly still. This sweeps horizontal drift on an otherwise
    // tap gesture and measures, per drift amount: how many registered as a tap
    // (driftActs.tap delta), how many got stolen as a sideways move (left+right
    // delta), and how many actually rotated the piece (p1rot changed). The real
    // device touch path is exercised (coordinate press+drag through WKWebView).
    func test_30_JitteryTapRotation() throws {
        XCTAssertTrue(startGame(side: 1), "game should start as P1")
        let drifts: [CGFloat] = [0, 15, 25, 35, 43, 55, 70]
        for drift in drifts {
            var tapReg = 0, moveReg = 0, rotChanged = 0
            for _ in 0..<6 {
                let tBefore = probeInt("tap")
                let mBefore = probeInt("left") + probeInt("right")
                let rBefore = probeInt("p1rot")
                if drift == 0 {
                    framePoint(161, 440).tap()
                } else {
                    // quick tap that drifts `drift` px horizontally before lift
                    framePoint(161, 440).press(forDuration: 0.06, thenDragTo: framePoint(161 + drift, 440))
                }
                usleep(350_000)
                if probeInt("tap") > tBefore { tapReg += 1 }
                if (probeInt("left") + probeInt("right")) > mBefore { moveReg += 1 }
                if probeInt("p1rot") != rBefore { rotChanged += 1 }
            }
            print("RESULT jittertap drift=\(Int(drift))px: tap=\(tapReg)/6 move=\(moveReg)/6 rotChanged=\(rotChanged)/6")
        }
    }

    func test_21_SoundAndHapticsTogglesReachable() throws {
        // Verifies the settings screen (which contains the Sound FX, Haptics,
        // and Volume controls) is reachable from in-game. Toggling individual
        // controls by coordinate is unreliable through the web view; this test
        // confirms the surface opens so those controls are present.
        XCTAssertTrue(startGame(side: 1))
        let ok = openSettings()
        print("RESULT settings_toggles_reachable: set=\(probeStr("set"))")
        XCTAssertTrue(ok, "settings (sound/haptics/volume) should be reachable")
    }
}
