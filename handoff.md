# Handoff - RVAL (aka Tetris, aka Drift) - 2026-09-03

## What this is
Two-player territorial Tetris game, App Store name **RVAL**, bundle id `com.typographic.drift`, working dir `~/Developer/tetris` (single source of truth, single-machine, no Dropbox copy). This session's focus: finishing the v1.1 "Drift mode" App Store submission (build fixes, copy, screenshots/video) end-to-end.

## Current state
- **App**: v1.1, build 5 (`MARKETING_VERSION=1.1`, `CURRENT_PROJECT_VERSION=5` in the Xcode project; `APP_VERSION="v1.1"` / `APP_BUILD_NUMBER="5"` in `preview/app.jsx`, shown in Settings as `v1.1 (5)`). Build 5 uploaded and fully processed in App Store Connect (confirmed "Complete" in Build Uploads).
- **Xcode Cloud signing bug found and fixed**: the App target's Debug/Release configs were missing `DEVELOPMENT_TEAM`, so Xcode Cloud archives came out unsigned (`SigningIdentity`/`Team` both empty in the archive's Info.plist) and couldn't be distributed. Fixed in `40aad87`. A **local** archive (`Product -> Archive` in Xcode, not Xcode Cloud) is what actually got build 5 signed and uploaded successfully.
- **Version/build display convention adopted**: Settings now shows `v1.1 (5)` - the standard iOS "Version X (build N)" pattern, matching what TestFlight shows per install. Documented in `CLAUDE.md` under "Bumping the Xcode build number" - `APP_BUILD_NUMBER` in `app.jsx` must be bumped by hand alongside `CURRENT_PROJECT_VERSION` every time a new archive build number is cut. Build number is global/monotonic across the app's lifetime, not reset per marketing version (e.g. next would be `v1.1 (6)` or `v1.2 (6)`, not `v1.2 (1)`).
- **App Store Connect submission for v1.1**: description, promotional text, "What's New" copy, and keywords are all drafted (see below) but I have **no confirmation "Submit for Review" was actually clicked**. Worth checking App Store Connect directly before assuming this is live.
- **App Preview video**: solved after real back-and-forth. Apple's App Preview video spec for this size bucket is **886x1920** (or 1920x886 landscape) - a different resolution than screenshots (1242x2688), which isn't obvious from the UI. First upload attempt failed with a dimensions error; second attempt (converted correctly) failed with "unsupported or corrupted audio" even though the source had *no* audio track at all - Apple's validator appears to require *some* audio stream to be present, even silent. Fix: always mux in a silent AAC track. Final best version was a **genuine native screen recording** via `xcrun simctl io <udid> recordVideo` (real continuous 60fps capture), not the frame-sampled screenshot approach used earlier in the session - see `rval-drift-native-886x1920.mp4` below.
- **Unrelated fix landed outside this session**: commit `8ca5929` (2026-08-07, this machine, different session) fixed the home-screen app display name - it was still "Rival" in `capacitor.config.json` / `Info.plist`, leftover from before the RVAL rebrand; now lowercase `rval` to match the shipped App Store name. Already committed and pushed. Not something this session did - flagging so it's not mistaken for still-open work.
- **Board-width redesign (16 columns)**: discussed and scoped but **not started**. See "Open questions" below.

## Files changed this session

| File | Status | What changed |
|------|--------|-------------|
| `ios/App/App.xcodeproj/project.pbxproj` | committed (`40aad87`) | Added missing `DEVELOPMENT_TEAM = 32S35BUK9J;` to App target Debug/Release configs (was only on project defaults + UI-test target). Also bumped `CURRENT_PROJECT_VERSION` 4->5 (`7cbf7ac`). |
| `preview/app.jsx` / `preview/app.js` | committed (`7cbf7ac`, `67b6849`, `43195d0`) | `SHOW_BUILD_STAMP = false` for the App Store archive; added `APP_BUILD_NUMBER` constant and display (`v1.1 (5)` in Settings); bumped `APP_COMMIT`/`APP_BUILD_DATE` stamp. |
| `CLAUDE.md` | committed (`e29fd2f`) | Documented the `APP_BUILD_NUMBER` convention and the exact steps/sed command to bump the Xcode build number across all 4 pbxproj occurrences. |
| `APP-STORE-SUBMISSION.md` | committed (`695480d`) | Added a "Drift" line to the `MODES` section of the App Store description worksheet. |
| `RELEASE_NOTES_v1.1.md` | committed (`695480d`, created this session) | Engineering-facing release notes for v1.1, later retitled from "DRIFT" to "RVAL" (that's the actual App Store brand name; "Drift" the word stays correct as the mode name elsewhere in the doc). Includes a "Build 5" addendum for the signing fix / version-display change. |
| `store-screenshots/6.5-display/04-drift-gameplay.png`, `05-drift-start.png` | committed (`9ef5e07`) | New 1242x2688 screenshots showing Drift mode (gameplay + start-screen starfield), captured via iOS Simulator since the existing 3 screenshots predate Drift mode. Jimmy felt the quality wasn't as good as the browser-rendered ones - kept in repo but not necessarily the final pick. |
| `store-screenshots/rval-drift-browser-886x1920.mp4` | **not committed** (gitignored, `store-screenshots/*.mp4`) | App Preview candidate recorded via real Chrome (crisper text/starfield than simulator) but frame-sampled (not continuous), ~16.5s, cropped/scaled/silent-AAC-muxed to spec. |
| `store-screenshots/rval-gameplay-5-appstore-886x1920.mp4` | **not committed** | Re-encode of an existing pre-session gameplay clip (`OK rval-gameplay-5.mp4`) to the 886x1920 + silent-AAC spec - this is the one that hit the "corrupted audio" error before the silent-track fix was added. |
| `store-screenshots/rval-drift-native-886x1920.mp4` | **not committed** | **Best candidate.** Genuine native 60fps `simctl recordVideo` capture off an iPhone 17 Pro Max simulator, trimmed to a 22s mid-to-late-game window, scaled to 886x1920 with silent AAC. This is what I'd upload. |

## Uncommitted work
None - `git status` is clean, everything above is either committed+pushed or intentionally gitignored (the mp4s). Confirmed `git log origin/main..HEAD` is empty (fully pushed).

## Open questions / decisions pending

1. **Was v1.1 actually submitted for review?** I prepared all App Store Connect copy and confirmed build 5 processed successfully, but never got confirmation the Submit button was clicked. Check App Store Connect's "iOS App Version 1.1" page status before assuming this shipped.
2. **Which screenshots/video actually go into App Store Connect?** Jimmy said the simulator-generated screenshots (`04-drift-gameplay.png`, `05-drift-start.png`) weren't as good quality as the browser-rendered ones shown inline earlier - but nothing was saved from the browser preview as a file (that tool can't export files directly), so those simulator PNGs are the only Drift-mode screenshot files that actually exist on disk. Worth deciding: use these, or re-generate via the real Chrome browser path (like the video) for better fidelity. For video, `rval-drift-native-886x1920.mp4` (real continuous recording) is the strongest candidate of the three generated this session.
3. **Xcode Cloud is still unfixed for signing.** The `DEVELOPMENT_TEAM` fix in the pbxproj did NOT actually solve Xcode Cloud producing signed archives (verified: build 183 post-fix still came out with empty `SigningIdentity`/`Team`). Build 5 shipped via a **local** Xcode archive instead. If Jimmy wants Xcode Cloud to auto-upload to TestFlight going forward, its workflow signing/certificate configuration in App Store Connect needs a separate look - not something a repo file edit can fix.
4. **Board-width redesign (16 columns) - not started.** Scoped in conversation: keeping the right sidebar (pause/settings icons at `SIDEBAR_X=320`) fixed and `CELL=20` unchanged (since `CELL` also sets row height via `GAME_2P_H = ROWS_2P * CELL`) means 16 columns x 20px = exactly 320px, i.e. the play area would need to start flush at `PLAY_X~0`, effectively dropping/redesigning the left bracket/dash decoration (`BRACKET_X`, `DASH_LEFT_W`, etc.). Jimmy wants to redesign that UI himself before this gets implemented. Also flagged: wider board = longer horizontal wrap distance in Drift mode, so wind/AI tuning may feel different at 16 columns and should be playtested once the layout lands, not reasoned about in the abstract.

## What to do next
1. Check App Store Connect to confirm whether v1.1 was actually submitted for review (see open question 1).
2. Decide on final screenshots + video for the submission (open question 2), upload them.
3. If Xcode Cloud auto-upload matters going forward, investigate its workflow signing config in App Store Connect (open question 3) - separate from this repo.
4. Whenever Jimmy has a board-width redesign direction, implement the 16-column layout change (open question 4) - prototype visually first, playtest the wind/wrap feel before tuning anything.

## How to resume
```bash
cd ~/Developer/tetris
git pull
```
Nothing else needed - single machine, single clone, already in sync with `origin/main`.

## Machine / account notes
- Generated on **Gandalf** (personal laptop).
- Personal repo - push with the explicit jimjimjimmy token form (already documented in `CLAUDE.md`):
  ```bash
  GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
  git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
  ```
- The three `.mp4` App Preview candidates are local-only (gitignored by design - large binaries). If picking this up on a different machine, they'll need to be re-generated or transferred manually; they were also sent to Jimmy directly as files during this session.
