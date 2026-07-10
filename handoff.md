# Handoff - RVAL (jimjimjimmy/tetris) - 2026-07-09

## What this is

RVAL - the two-player territorial Tetris app. Personal repo `jimjimjimmy/tetris`,
Capacitor iOS wrap. This session (on Gandalf, `~/Developer/tetris`): shipped 1.0
to the App Store, then produced a set of gameplay demo videos for portfolio /
App Store preview use.

**Status:** version 1.0 (build 3) is LIVE on the App Store (approved, published).
Bundle ID `com.typographic.drift`, marketing name `RVAL`.

## Current state

Working / shipped:
- **App is live in the App Store as RVAL 1.0 (3)** with the RVAL wordmark, all
  metadata, screenshots, support/privacy pages, categorized Puzzle + Casual.
- Support email: `rval@typographic.com` (was `arch.rival@...`, swapped mid-session).
- 7 gameplay demo MP4s in `store-screenshots/` (see file list below). Two of
  them are flagged with an `OK ` prefix in the filename - those are the user's
  chosen keepers:
  - `OK rval-gameplay-3.mp4` (20s, tug-of-war, 6 boundary shifts)
  - `OK rval-gameplay-5.mp4` (19.4s, dominant local +2 with drama)

Uncommitted in-tree:
- `ios/App/App.xcodeproj/project.pbxproj` and `App.xcscheme` have small
  cosmetic Xcode "recommended settings" churn (`LastUpgradeCheck`
  `2650`->`2660`, `LastUpgradeVersion` `1600`->`2660`,
  `TARGETED_DEVICE_FAMILY` string `"1"` -> integer `1`). No behavior change.
  Safe to commit or leave.
- 5 of the 7 gameplay MP4s are untracked. Decide: keep in git, gitignore, or
  move to Dropbox.

Known regressions introduced this session: **none in shipped code**. All AI /
TEST_SPEED hacks used for video capture were reverted; `preview/app.jsx` and
`preview/app.js` match the last committed version (`c34429c` + the `24414df`
stamp).

## Files changed this session

| File | Status | What changed |
|------|--------|-------------|
| ios/App/App.xcodeproj/project.pbxproj | committed (`a646516`, `da6c0aa`, `c34429c`) + small unstaged churn | iPhone-only; build number bumped 1 -> 2 -> 3; small Xcode housekeeping (uncommitted) |
| ios/App/App/Info.plist | committed (`da6c0aa`) | `ITSAppUsesNonExemptEncryption = false` to skip encryption prompt |
| preview/app.jsx | committed (`b60553b`, `24414df`) | RVAL wordmark component replaced ARCH RIVAL lockup; APP_COMMIT + build date bumped |
| preview/app.js | committed (`b60553b`, `24414df`) | Rebuilt output |
| assets/splash.svg | committed (`b60553b`) | Splash wordmark swapped to RVAL |
| ios/App/App/Assets.xcassets/Splash.imageset/*.png | committed (`b60553b`) | 6 splash PNGs regenerated (2732x2732, no alpha) |
| ios/App/App/public/app.js | committed (`c34429c`) | `cap sync ios` output - the KEY fix that made build 3 actually ship RVAL (build 2 shipped stale public/) |
| support.html | committed (`a646516`, `aff6695`) | Created; email later swapped to `rval@typographic.com` |
| privacy.html | committed (`a646516`, `aff6695`) | Created; same email swap |
| index.html | committed (`a646516`) | Root redirect title `DRIFT` -> `Arch Rival` |
| APP-STORE-SUBMISSION.md | committed (`bfe0fc5`, `4bc69cf`, `aff6695`, `eb1762c`) | Worksheet created + iterated (RVAL name, email, versioning conventions) |
| CLAUDE.md | committed (`b60553b`) | `RivalLogo` entry rewritten for RVAL |
| store-screenshots/rval-gameplay*.mp4 | UNTRACKED (7 files) | Portfolio / App Store preview clips generated via puppeteer + ffmpeg |

## Uncommitted work

None. Both leftovers were resolved in `81fa5ae`:
- Xcode housekeeping churn (`project.pbxproj`, `App.xcscheme`) committed as-is.
- Gameplay MP4s added to `.gitignore` (`store-screenshots/*.mp4`). They live
  on Gandalf disk only; not versioned.

Everything else was already committed. Both clones on Gandalf
(`~/Developer/tetris` and the Dropbox copy) are at `81fa5ae` clean.

## To any other machine reading this

The **other Mac's clone** (MacFQ at `/Users/jimmyche/.../Tetris`) will
be stale until it runs:
```bash
cd "/Users/jimmyche/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris"
git checkout -- .    # discard any stale uncommitted diffs
git pull
```
Per the new convention (top of CLAUDE.md), the other Mac should NOT edit or
push RVAL from here on - Gandalf is the primary. Sync-only.

## Open questions / decisions pending

1. **Gameplay video final selection.** User marked 2 as "OK" (files prefixed
   `OK rval-gameplay-3.mp4` and `OK rval-gameplay-5.mp4`). No decision yet on
   the other 5 - delete, keep as backups, or archive.
2. **Xcode "Update to recommended settings" prompt** - was flagged during
   Archive; ignored to avoid interrupting the ship. Should be reviewed and
   applied when there's time.
3. **EU trader status** in App Store Connect - the banner was showing on the
   Apps page. Not blocking US distribution; must be resolved for EU
   distribution. Answer will be "not a trader" if you're an individual dev.
4. **Post-mortem: cap sync gap.** Session hit a real problem where build 2
   uploaded with stale `ios/App/App/public/` because `npx cap sync ios` was
   not run between the RVAL source swap and Archive. Fixed for build 3 and
   documented in memory (`feedback_capacitor_cap_sync_before_archive.md`) so
   the pattern doesn't repeat.
5. **Xcode Cloud** - is configured (per CLAUDE.md `ci_scripts/`), but we shipped
   via local Archive from Gandalf, not Cloud. Consider validating Cloud path
   for future updates.

## What to do next

1. **Commit or discard the Xcode housekeeping churn** in `project.pbxproj` and
   `App.xcscheme`. One-liner commit if you want it clean.
2. **Decide on the 7 gameplay MP4s** - pick keepers, decide git tracking vs
   gitignore.
3. **Resolve the EU trader status banner** in App Store Connect when convenient.
4. **v1.0.1 plan** (whenever it's needed): for a hotfix, bump
   `CFBundleShortVersionString` to `1.0.1`, bump `CURRENT_PROJECT_VERSION`
   to `4`, edit source, `npm run build`, **`npx cap sync ios`**, verify
   `ios/App/App/public/app.js` has the change, Archive, upload, attach in
   App Store Connect. (Versioning notes are in `APP-STORE-SUBMISSION.md`.)
5. **Portfolio case study** - user mentioned wanting to write one up. Gameplay
   videos are ready; write-up not started.

## How to resume

On Gandalf (this machine, build-only clone at `~/Developer/tetris`):
```bash
cd ~/Developer/tetris
git pull
ls store-screenshots/
```

On the MacFQ (Dropbox copy at `/Users/jimmyche/.../Tetris`):
```bash
cd "/Users/jimmyche/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris"
git pull
```

For any code edit that changes `preview/app.jsx`:
```bash
# edit preview/app.jsx
npm run build          # writes preview/app.js
npx cap sync ios       # copies preview/app.js -> ios/App/App/public/app.js  <-- REQUIRED for iOS builds
grep -o "<expected-string>" ios/App/App/public/app.js  # verify sync landed
# bump APP_COMMIT + APP_BUILD_DATE per CLAUDE.md two-commit pattern
# then Archive in Xcode
```

## Machine / account notes

- Session ran on **Gandalf** (`~/Developer/tetris`). Per CLAUDE.md, Gandalf is
  build-only from the Developer clone, NOT the Dropbox copy. This session did
  commit and push directly from Gandalf, which worked cleanly.
- Personal repo; push with the explicit token form:
  ```bash
  GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
  git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
  ```
- App Store account: Jimmy Chen team ID `32S35BUK9J`. Bundle ID
  `com.typographic.drift` (unchanged for identity continuity even though
  marketing name is now RVAL).
- Support email `rval@typographic.com` is the canonical contact for App Review,
  support page, and privacy page.
