# Handoff - Tetris (DRIFT) - 2026-05-28

## What this is

Personal 2-player mobile Tetris on MacFQ (jimjimjimmy/tetris). This
session: shipped the QA backlog (lock delay, soft drop, line clear
flash, wall kicks), fixed the +1->+2 boundary fencepost, added the
DEBUG_PIECES smoke-test BAR piece, applied Figma 152-1747 / 152-2247
status-color polish to the boundary indicator, corrected an
origin/live solid-vs-dashed swap, and disabled the toward-boundary
hard drop so vertical gestures only ever act away from the boundary.

## Current state

Working and shipped:
- All four backlog tickets closed (#1 lock delay, #2 soft drop, #3
  line clear flash, #4 wall kicks).
- Boundary shift is now 1:1 -- `newBdy = boundary - n1 + n2`. The old
  `decayShiftAt` decimal accumulator (0.952, 0.909...) was the root
  cause of the +1->+2 / -1->-2 / simul-2-at-+1 bugs. Removed entirely.
- DEBUG_PIECES smoke-test mode: when `true`, every piece spawns as
  a 10x1 BAR for deterministic single-row clears. `spawnX(type)`
  returns 0 for BAR, 3 otherwise. Always `false` before push.
- Status-color indicator (Figma 152-1747 / 152-2247):
  - Live boundary line: dashed 4/4, color `#2fff00` (gain) /
    `#ff0000` (loss) / `DASH_COLOR` white (neutral).
  - Origin line: solid at midline, `ORIGIN_DASH_COLOR` (white 0.7).
    Distinguishes neutral reference from displacing live boundary.
  - Bracket: stem 1px wide at opacity 0.15, cap 4x1 at LIVE end at
    opacity 0.5.
  - "+N" / "-N" text: Inter Regular 10/2px uppercase, opacity 0.5,
    same color as bracket.
- Vertical gesture / arrow rule (this session's final commit `9f57cc7`):
  the only vertical input is the AWAY-from-boundary direction.
    P1 swipe-down / ArrowDown -> soft drop +1
    P1 swipe-up   / ArrowUp   -> no-op
    P2 swipe-up   / ArrowUp   -> soft drop -1
    P2 swipe-down / ArrowDown -> no-op
  Hard-drop apply branches kept in applyP*/applyP* but no caller
  triggers them. One-line wiring change to re-enable.
- Mobile dvh viewport fix (`f1ffe21`) so the app covers the full
  screen on iOS Safari, no bottom black bar.
- Per-level fall speed: L1=600ms, L2=440, L3=320, L4=220, L5=140.

Partially done / interrupted:
- None this session. Backlog cleared.

Known untracked working docs (local, NOT committed):
- `bug_report.md` -- queue of bugs + features.
    B1 "Soft drop works against gravity" is now shipped as
    `9f57cc7`. User should move it to Done.
- `test_plan.md` -- recurring smoke test checklist using DEBUG_PIECES.

## Files changed this session

| File | Status | What changed |
|------|--------|-------------|
| preview/game.html | committed (multiple) | Lock delay + soft drop + line clear flash + wall kicks + 1:1 boundary shift + DEBUG_PIECES BAR + status-color indicator + origin/live solid/dashed swap + hard-drop disable |
| CLAUDE.md | committed | Per-commit notes for each of the above |
| bug_report.md | untracked | User-maintained bug + feature queue (pre-existing) |
| test_plan.md | untracked | User-maintained smoke-test plan (pre-existing) |
| .DS_Store | untracked (ignored) | macOS finder metadata |

## Uncommitted work

None on `preview/game.html` or `CLAUDE.md`. The two `.md` files in
the working tree (bug_report.md, test_plan.md) are user-maintained
local tracking docs and were not touched by this session.

## Open questions / decisions pending

1. Update bug_report.md B1 status. Soft-drop-against-gravity bug
   was shipped as commit `9f57cc7`. Move B1 from Pending to Done.
2. Hard drop returnability. Disabled this session. If gameplay
   feels too slow without it, the apply* internals are intact --
   one-line restore in the keyboard / onEnd handler.
3. Sound FX + music (F1, F2 in bug_report.md). Spec says
   placeholder options UI first, then wire ~6-8 CC0 sounds.
4. Score / win streak tracker (F3). Not started.
5. Game-over / rematch screen (F4). Currently uses an inline
   summary overlay with REMATCH button; no proper end screen.

## What to do next

1. User: tick off B1 in bug_report.md. Move "Soft drop works
   against gravity" to Done with commit `9f57cc7`.
2. Run the test_plan.md smoke pass on device. Set
   `DEBUG_PIECES = true` locally and walk through the 10+
   boundary transitions plus the new vertical-gesture rules.
3. Pick the next feature from bug_report.md (F1 sound FX
   placeholder UI is the explicit next-up).
4. APP_COMMIT housekeeping: current is `9f57cc7`. Always bump
   to the new short hash before pushing a behavioral commit.

## How to resume

```bash
cd "$HOME/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris"
git pull

# Local server (matches the working-dir layout used by tetris-storybook).
python3 -m http.server 7654
# then open http://localhost:7654/preview/game.html

# When ready to push:
GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
```

Live URLs (auto-update from main):
- Fullscreen game: https://jimjimjimmy.github.io/tetris/preview/game.html
  Footer shows `APP_COMMIT="9f57cc7"` after Pages refresh.

## Machine / account notes

- Generated on MacFQ.
- Personal repo on `jimjimjimmy` GitHub account, NOT FloQast. Always
  push with the explicit token form above.
- Cross-machine state lives in Dropbox `04 Projects/AI Shared/Tetris/`.
  Both MacFQ and Gandalf can edit; CLAUDE.md is the single source
  of truth.
- Pre-commit hook blocks em-dashes. Use hyphens only.
- `TEST_SPEED` AND `DEBUG_PIECES` must both be `false` before every
  push. Verified clean.
- `APP_COMMIT` must be updated to short hash of HEAD just before
  commit so the start-screen stamp reflects the build being shipped.
- Current build identity: `APP_VERSION = "v0.1"`, `APP_COMMIT = "9f57cc7"`.
