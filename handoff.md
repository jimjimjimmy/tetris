# Handoff - DRIFT (Tetris) - 2026-06-01 (PM)

## What this is
DRIFT, 2-player iOS Tetris (Capacitor wrap of `preview/index.html`).
Generated on the **code machine** (`/Users/jimmyche/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris`). Device builds run on **Gandalf** (`/Users/jimmy/Dropbox/...`, phone "Shadowfax" = iPhone 17 Pro, iOS 26.5). This session: got the app installing on device, fixed sound + haptics, fixed Xcode Cloud, fixed tap-rotate, and uncovered a cross-machine Dropbox/git problem.

## Current state - working
- **Phone install** ✓ - the shared App scheme had an empty Run target (no `BuildableProductRunnable`); Run compiled but installed nothing. Fixed (commit `bcd801b`). App now installs/launches on Shadowfax.
- **Sound FX** ✓ - `<audio>` elements (Web Audio fails in WKWebView) + `AVAudioSession.playback` in AppDelegate so SFX play through the mute switch. Confirmed on device.
- **Haptics** ✓ - `light()` now uses `impact()` (selectionChanged was a no-op). Confirmed on device. (Gates: System Haptics on, Low Power Mode off.)
- **Xcode Cloud** ✓ - **Build 14 passed.** Root cause: `ci_scripts` must sit **next to the .xcodeproj** (`ios/App/ci_scripts/`), not just repo root. Both copies now committed (`a569677`). NOTE: only build commits >= a569677; do not "Rebuild" older builds (they lack the fix and will fail - that is what Build 15 was).
- **AI** ✓ - hole-direction bug fixed + maxH/coverage tuning; spreads ~6-7 cols.
- **node_modules** - per-machine, Dropbox-ignored on the code machine.

## Partially done / needs device confirmation
- **Tap-rotate** - two fixes shipped: (1) first horizontal move now needs 44px so a drifting tap stays a rotate (`4b731b3`); (2) wall-kick widened to +/-2 columns so rotations near walls / the I-piece succeed (`7a58dde`). Automated test_30 proves tap DETECTION is 100% up to ~43px drift. The wall-kick benefit needs a device feel-test (rebuild on Gandalf, play, confirm rotate is reliable). If a tap still fails: buzz-but-no-turn = piece truly wedged; no-buzz = tap drifted >44px and moved instead.

## Open issues
1. **Gandalf `.git` is CORRUPTED** (`git pull` -> `unpack-objects failed`) from Dropbox syncing the `.git` folder. Build still works (files sync via Dropbox), but Gandalf cannot reliably pull/commit. FIX = re-clone fresh outside Dropbox (procedure below).
2. **Two-agent hazard** - a Claude session ran on BOTH Macs against the same Dropbox repo. Going forward: only the code machine commits/pushes; Gandalf is build-only. Never run two sessions editing the same repo.

## What to do next (ordered)
1. **Repair Gandalf** (run ON Gandalf, in Terminal) - re-clone OUTSIDE Dropbox so git is never Dropbox-corrupted again. Do NOT `rm` the Dropbox copy (Dropbox would delete it on the other Mac too):
   ```sh
   mkdir -p ~/Developer && cd ~/Developer
   git clone https://github.com/jimjimjimmy/tetris.git
   cd tetris
   npm install
   npx cap sync ios
   # open ios/App/App.xcodeproj from ~/Developer/tetris in Xcode -> select Shadowfax -> Run
   ```
   From now on, build Gandalf from `~/Developer/tetris` and `git pull` there to get updates.
2. **Device feel-test tap-rotate** (from the new clone): play a few rounds, confirm rotate is reliable now. Report buzz-vs-no-buzz on any miss.
3. (Optional) Start a fresh **Xcode Cloud** build on latest `main` if you want a TestFlight build - it will pass like Build 14.

## How to resume
- Code machine (this one): edit `preview/index.html`, bump APP_COMMIT + APP_BUILD_DATE, commit, push (token form below).
- Gandalf: `cd ~/Developer/tetris && git pull && npm install && npx cap sync ios`, then Run to Shadowfax.

## Machine / account notes
- Push (personal repo, explicit token):
  ```bash
  GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
  git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
  ```
- Every `preview/index.html` commit bumps APP_COMMIT + APP_BUILD_DATE (local time). No em-dashes (pre-commit hook blocks them).
- `TEST_PROBE = true` (a11y probe for XCUITest) - set false for App Store builds.
- Run UI tests: `npm run uitest` (code machine). Latest full suite: 18/18 passed (2026-06-01 PM, on the latest code incl. scheme/tap/wall-kick fixes).
