# Handoff - DRIFT (Tetris) - 2026-06-01 (EOD)

## What this is
DRIFT, 2-player iOS Tetris (Capacitor wrap of `preview/index.html`).
Generated on the **code machine** (`/Users/jimmyche/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris`). Device builds run on **Gandalf** (`/Users/jimmy/Developer/tetris` after the re-clone; phone "Shadowfax" = iPhone 17 Pro, iOS 26.5). This session got the app onto the device, fixed sound/haptics, fixed Xcode Cloud, fixed tap-rotate, fixed the cross-machine Dropbox/git mess, and repaired + de-prompted the memory sync.

## Current state - working
- **Phone install** ✓ - the shared App scheme had an empty Run target (no `BuildableProductRunnable`); Run compiled but installed nothing. Fixed (`bcd801b`).
- **Sound FX** ✓ - `<audio>` elements + `AVAudioSession.playback` in AppDelegate (plays through the mute switch). Confirmed on device.
- **Haptics** ✓ - `light()` uses `impact()` (selectionChanged was a no-op). Confirmed on device. Gates: System Haptics on, Low Power Mode off.
- **Xcode Cloud** ✓ - Build 14 passed. `ci_scripts/ci_post_clone.sh` must sit BOTH at repo root AND next to the .xcodeproj (`ios/App/ci_scripts/`); both committed (`a569677`). Only build commits >= a569677; never "Rebuild" older builds.
- **AI** ✓ - hole-direction bug fixed + maxH/coverage tuning; spreads ~6-7 cols.
- **Memory sync** ✓ - `~/Dropbox/04 Projects/AI Knowledge/Claude-Mem/merge-mem.sh` had a macOS `mktemp` bug (left a literal temp file, silently breaking the 5:15am sync since May 29) - FIXED + now cleans `-shm`/`-wal`. Last merge: 4752 obs / 235 sessions.
- **Sync prompts removed** ✓ - permission allow-rules added so "sync everything" no longer asks to "accept": merge-mem.sh + `gh auth token` in `~/.claude/settings.json`; git + `npx cap sync` in `Tetris/.claude/settings.local.json` (gitignored, project-scoped so it doesn't auto-allow git in FQ work repos).
- **node_modules / git** - per-machine, Dropbox-ignored. Code machine pushes; Gandalf is build-only.

## Partially done / needs device confirmation
- **Tap-rotate** - two fixes shipped: first horizontal move needs 44px so a drifting tap stays a rotate (`4b731b3`); wall-kick widened to +/-2 cols (`7a58dde`). Automated test_30: tap DETECTION 100% up to ~43px drift. Wall-kick benefit still needs a device feel-test. On a miss: buzz-but-no-turn = piece wedged; no-buzz = tap drifted >44px and moved instead.

## Open issues
1. **Gandalf `.git` corruption** - fix is the re-clone to `~/Developer/tetris` (see below). If not yet done on Gandalf, do it before building there.
2. **Two machines, one repo** - SINGLE-WRITER rule now documented at top of CLAUDE.md: only the code machine commits/pushes; Gandalf pulls + builds. Never run two editing Claude sessions on the repo.

## Files changed this session
| File | Status | What changed |
|------|--------|-------------|
| (git) preview/index.html, AppDelegate.swift, Info.plist, App.xcscheme, project.pbxproj, ci_scripts/*, package.json, CLAUDE.md, DriftUITests.swift, handoff.md | committed (HEAD 72337dd) | all the fixes above; pushed to GitHub |
| ~/Dropbox/04 Projects/AI Knowledge/Claude-Mem/merge-mem.sh | edited (not in git; Dropbox-synced) | mktemp + WAL-cleanup fix |
| ~/.claude/settings.json | edited (not in git) | permissions.allow for merge-mem.sh + gh auth token |
| Tetris/.claude/settings.local.json | created (gitignored) | permissions.allow for git + npx cap sync |

## What to do next (ordered)
1. **If not already done: repair Gandalf** (run ON Gandalf):
   ```sh
   mkdir -p ~/Developer && cd ~/Developer
   git clone https://github.com/jimjimjimmy/tetris.git
   cd tetris && npm install && npx cap sync ios
   # open ios/App/App.xcodeproj from ~/Developer/tetris -> Shadowfax -> Run
   ```
   Build from `~/Developer/tetris` and `git pull` there from now on. Do NOT delete the Dropbox copy.
2. **Device feel-test tap-rotate** from the new clone; report buzz-vs-no-buzz on any miss.
3. **Confirm both machines' memory is in sync**: run a sync on Gandalf; both should show 4752 obs / 235 sessions on the startup stats line.
4. (Optional) Fresh **Xcode Cloud** build on latest `main` for a TestFlight build (passes like Build 14).

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
- Run UI tests: `npm run uitest`. Last full suite: 18/18 passed.
- Current: HEAD `72337dd` (= GitHub main); APP_COMMIT `7a58dde` (last index.html behavioral commit).
