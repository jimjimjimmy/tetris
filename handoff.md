# Handoff - DRIFT (Tetris) - 2026-06-01

## What this is
DRIFT, the 2-player iOS Tetris (Capacitor wrap of `preview/index.html`).
Generated on the **code machine** (`/Users/jimmyche/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris`, where Claude runs + pushes). Device builds happen on the other Mac (Gandalf, `/Users/jimmy/Dropbox/...`, phone "Shadowfax" connected). This session: sound/haptics on device, AI spread fix, XCUITest suite, Xcode Cloud CI, app naming, and a cross-machine node_modules fix.

## Current state
- **Sound FX**: JS engine = HTML `<audio>` elements (works in Capacitor WKWebView; Web Audio did not). Unlocked on the start-tap gesture. Native `AVAudioSession` set to `.playback` so SFX play through the iPhone mute switch. WORKS in simulator; **not yet confirmed on a physical device** (needs Gandalf rebuild).
- **Haptics**: bridge fires (Capacitor Haptics). Suppressed when tethered to a Mac via USB, and by Low Power Mode / System-Haptics-off. **Not yet confirmed on device untethered.**
- **AI**: fixed. Was stacking narrow/tall because (a) both hole-detection loops scanned the wrong direction (counted ~9 fake holes per landed piece, scores ~-4000 on an empty board) and (b) aggHPenalty penalized total height (no spread incentive). Now: corrected hole direction + maxHPenalty + coverageBonus. Verified spreading ~6-7 cols wide in sim.
- **XCUITest suite** (`ios/App/AppUITests/DriftUITests.swift`): 17 tests, last run 17/17 pass. Run via `npm run uitest`. Relies on the TEST_PROBE a11y bridge.
- **TEST_PROBE = true** in index.html (hidden a11y state element for XCUITest). Set false for App Store builds.
- **Xcode Cloud**: `ci_scripts/ci_post_clone.sh` added (npm install + cap sync) so fresh clones resolve the local-path Capacitor SPM deps. Build 6 failed because it ran before the script landed; needs a fresh build on the latest commit.
- **App name**: home-screen name = `Drift - Test` via `CFBundleDisplayName` (single source). Product name reverted to `App` (artifact stays App.app). Bundle id `com.typographic.drift` unchanged (permanent).
- **node_modules**: now Dropbox-ignored on the code machine (per-machine from now on).

## Files changed this session
| File | Status | What changed |
|------|--------|-------------|
| preview/index.html | committed | TEST_PROBE a11y probe + driftActs counters; AI hole-direction fix; maxHPenalty/coverageBonus AI tuning; Audio-element SFX engine + _unlock; tap/drop gesture fixes; APP stamp bumps |
| ios/App/App/AppDelegate.swift | committed | AVAudioSession `.playback` (+mixWithOthers) so SFX bypass the mute switch |
| ios/App/App/Info.plist | committed | CFBundleDisplayName = "Drift - Test" |
| ios/App/App.xcodeproj/project.pbxproj | committed | Added AppUITests UI-test target (via xcodeproj gem) |
| ios/App/App.xcodeproj/xcshareddata/xcschemes/App.xcscheme | committed | New shared App scheme (build=App, test=AppUITests) |
| ios/App/AppUITests/DriftUITests.swift | committed | 17-test XCUITest suite (gestures/flow/settings) |
| ci_scripts/ci_post_clone.sh | committed | Xcode Cloud post-clone: npm install + cap sync |
| package.json | committed | `uitest` / `uitest:nobuild` scripts |
| CLAUDE.md | committed | AI/probe/XCUITest/CI docs + per-machine node_modules rule + dual Dropbox paths |

## Uncommitted work
None tracked (working tree clean). Untracked stray files exist but are NOT mine and should be left alone: extra `preview/assets/Sound fx/*` candidate audio, root `assets/`, `test_plan.md`.

## Open questions / decisions pending
1. Do SFX actually play on the physical device now (AVAudioSession + mute-switch fix)? Unverified - needs Gandalf rebuild.
2. Do haptics fire on device untethered? Unverified (simulator has no Taptic Engine). Check Low Power Mode + Settings > Sounds & Haptics > System Haptics.
3. Xcode Cloud: re-run a build on latest `main` to confirm ci_post_clone.sh fixes SPM/node_modules resolution.

## What to do next
1. **On Gandalf (phone Mac)**: `git pull`, then `npm install`, then `xattr -w com.dropbox.ignored 1 node_modules`, then `npx cap sync ios`. Xcode: Clean Build Folder (Cmd+Shift+K), select **Shadowfax**, **Run (Cmd+R)** -- not Build. Trust profile + Developer Mode ON if prompted.
2. Verify SFX audible (try the ring/silent switch both ways - should now play either way) and haptics felt (untethered).
3. Re-run the Xcode Cloud build on the latest commit; watch the Post-Clone step.
4. If shipping a real build: flip `TEST_PROBE = false` in index.html (like DEBUG_PIECES/TEST_SPEED).

## How to resume
```bash
# On whichever Mac you sit down at:
git pull
npm install            # node_modules is per-machine now; not synced via Dropbox
xattr -w com.dropbox.ignored 1 node_modules   # once per machine, if not already set
npx cap sync ios
# code machine: Claude edits preview/index.html, commits, pushes
# phone machine: open ios/App in Xcode, select Shadowfax, Run
```

## Machine / account notes
- Generated on the **code machine** (`/Users/jimmyche/Library/CloudStorage/Dropbox/...`).
- Phone/device builds: **Gandalf** (`/Users/jimmy/Dropbox/...`), device "Shadowfax" (iPhone 17 Pro, iOS 26.5).
- Source syncs via git + Dropbox; **node_modules is per-machine (Dropbox-ignored) - run `npm install` locally**.
- Personal repo. Push with the explicit token form:
  ```bash
  GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
  git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
  ```
- Every `preview/index.html` commit must bump `APP_COMMIT` + `APP_BUILD_DATE` (local time). No em-dashes anywhere (pre-commit hook blocks them). Current stamp: `APP_COMMIT = 1e8b6c0`.
