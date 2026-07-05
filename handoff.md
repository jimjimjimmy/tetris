# Handoff - Tetris (Rival) - 2026-07-04

## What this is
Personal 2-player mobile Tetris (`jimjimjimmy/tetris`), Capacitor iOS wrap.
Generated on the CODE machine (`/Users/jimmyche/.../Dropbox/.../Tetris`).
This session focused on the online (2 Players) flow polish + the iOS keyboard
saga; a parallel background session ("forfeit timer") landed alongside it.

## Current state
HEAD = `a926206`; footer/APP_COMMIT = `10d3490`. Local == origin/main (pushed).

Landed since the keyboard fix (`1fca9ed`), newest first:
- **In-app numeric keypad** (`ca8ec53`, `96cd7ad`): the room-code text `<input>`
  was REPLACED with an on-screen keypad (Figma Enter Code `385:6362`),
  auto-connects on the 4th digit. This removes the OS keyboard from the code
  screen entirely -> the whole "iOS keyboard slides / Back button moves up"
  problem is now moot there.
- **Pre-match START IN countdown** (`9920fbc`) before the game begins; also runs
  on rematch (`c1522e0`). This is the 377:6670 countdown that was requested.
- **Auto-forfeit on pause** (`1d0cd8e`, `4f0bcd3`, `69c01a5`, `723f536`,
  `10d3490`): online pause was RE-ENABLED (reverses the earlier MVP "hide pause
  in 2P"), with an auto-forfeit timer + countdown shown to both players and
  POV-worded captions. This was the `task_aeeecb81` background task.
- **Optical centering** (`11bbc4b`, `db19e9a`) of standalone letter-spaced text
  + the shared room code / 2P share-screen labels.
- Earlier this session (still in history): numeric room codes, Room-Full
  screen, opponent-paused overlay (376:6580), online best-of-3 "Play Game N",
  and the native `@capacitor/keyboard` resize:none fix (`5623347`).

Reconciliation point: the native `@capacitor/keyboard` fix is likely now
REDUNDANT on the code screen since the in-app keypad means no OS keyboard is
summoned there. It's harmless (guarded) but see Open questions.

## Files changed (areas touched across the recent commits)
| File | Status | What changed |
|------|--------|-------------|
| preview/app.jsx | committed | Source of truth: keypad, countdown, forfeit, pause, optical centering, keyboard guards |
| preview/app.js | committed | Compiled output (npm run build) |
| preview/index.html | committed | #root align-items flex-start (top-anchor) + caret/ellipsis keyframes |
| capacitor.config.json | committed | Added `Keyboard: { resize: "none" }` |
| package.json / package-lock.json | committed | Added `@capacitor/keyboard@^8.0.5` |
| CLAUDE.md | committed | Notes for keyboard-stable frame, forfeit, ROWS_2P/BDY_2P fix |
| store-screenshots/ | UNTRACKED | 01-gameplay / 02-countdown / 03-keypad PNGs (App Store) - not committed |

## Uncommitted work
Only `store-screenshots/` is untracked (3 App Store PNGs). Not committed - it's
a pending decision (see below). Tree is otherwise clean.

## Open questions / decisions pending
1. `store-screenshots/` - commit to the repo, or add to .gitignore? (App Store
   assets; decide if they belong in git.)
2. `@capacitor/keyboard` + `resize:"none"` - now that the code screen uses an
   in-app keypad (no OS keyboard), is the plugin still needed anywhere? If no
   other screen uses a real text input it can be removed (or left as harmless
   insurance). Removing = dep change + Gandalf npm install + cap sync.
3. Device confirmation still pending: in-app keypad + START IN countdown +
   auto-forfeit have NOT been eyeball-confirmed on a real device this session.

## What to do next
1. Rebuild on Gandalf and device-verify: (a) Enter-Code screen uses the in-app
   keypad with NO OS keyboard / no Back-button movement; (b) START IN countdown
   plays before the match and on rematch; (c) pause -> opponent sees forfeit
   countdown, and a timed-out pause forfeits correctly (2-device test).
2. Resolve the two decisions above (store-screenshots gitignore; keep/remove
   @capacitor/keyboard).
3. Then continue remaining online polish: Connection-Failed/timeout state was
   proposed but not built; reconnect + rematch-consent were deferred.

## How to resume
```bash
cd ~/Developer/tetris   # Gandalf build clone (NOT the Dropbox copy)
git pull
npm install             # required: @capacitor/keyboard is a new dep this session
npx cap sync ios
npx cap open ios        # build to "Shadowfax"
```
On the code machine: edit `preview/app.jsx`, `npm run build`, bump
APP_COMMIT/APP_BUILD_DATE, commit BOTH app.jsx + app.js.

## Machine / account notes
- Generated on the CODE machine. Gandalf is build-only (`~/Developer/tetris`).
- Personal repo - push with the explicit token:
```bash
GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
```
