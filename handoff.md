# Handoff - Tetris (DRIFT) - 2026-05-26

## What this is
Personal 2-player mobile Tetris game (preview/game.html), MacFQ machine, session focused on visual fixes to the boundary indicator system and gesture deadzone.

## Current state
- Game is fully playable: P1 floats up, P2 falls down, territory boundary shifts on line clears
- Gesture hard drop fires once on touchend (lift) with 44px minimum travel deadzone - no hair-trigger
- Keyboard ArrowUp = hard drop (P1), ArrowDown = hard drop (P2), both respect boundary
- Right-side origin line stub restored (ORIGIN_RIGHT_W=52); left-side solid stub at DASH_LEFT_X
- Colored dashed lines (green=gain, red=loss) appear on BOTH left and right margins when boundary shifts (inside bdyView block only - hidden at neutral)
- Inner dividing line hidden (showBoundary=false) - no full-width line or glow across play area
- APP_COMMIT=c0e6a11, APP_BUILD_DATE=2026-05-26T22:47:00, shows "~1m ago" in footer
- No known bugs or regressions

## Files changed this session
| File | Status | What changed |
|------|--------|--------------|
| preview/game.html | committed (e82e8ff) | Remove right-side boundary dash divs from DOM |
| preview/game.html | committed (c7f05ad) | Restore right origin line stub; remove left live boundary dash |
| preview/game.html | committed (c46b3c3) | Hard drop fires on touchend with 44px deadzone, not mid-drag |
| preview/game.html | committed (969c055) | Re-enable live boundary line - showBoundary=true (later reverted) |
| preview/game.html | committed (d0c0905) | Add colored dashed boundary lines to both left and right margins |
| preview/game.html | committed (c0e6a11) | Hide internal boundary divider - showBoundary=false (final) |
| preview/game.html | committed (5338b87) | Fix APP_BUILD_DATE to use local time not UTC |
| CLAUDE.md | committed (13c872e) | Document APP_COMMIT + APP_BUILD_DATE as required per-commit step |

## Uncommitted work
None. Working tree clean (only .DS_Store, bug_report.md, test_plan.md untracked - safe to ignore).

## Open questions / decisions pending
- Origin stubs are currently SOLID white at 0.7 opacity. Originally they were DASHED (ORIGIN_DASH_SEG=2, 2px segments). May want to restore the dashed style for lower visual weight - not yet raised with user.
- Left-side bdyView colored dashed line is new this session (right side already existed before). User approved both sides but not yet tested on physical device.
- CLAUDE.md "Last updated" timestamp in the HTML comment header is stale (still says 2026-05-21).

## What to do next
1. Test on physical device (iPhone) - verify 44px deadzone feels right for hard drop gesture
2. Update CLAUDE.md "Last updated" timestamp in the HTML comment block (line ~6)
3. Decide: origin stubs solid (current) vs dashed (original pre-session)?
4. Next feature from bug_report.md - F1 sound FX placeholder UI was the explicit next-up

## How to resume
```bash
cd ~/Library/CloudStorage/Dropbox/04\ Projects/AI\ Shared/Tetris
git pull
# Live preview already running at http://localhost:3000/preview/game.html
# (tetris-storybook server via .claude/launch.json)
```

Live URLs:
- Fullscreen game: https://jimjimjimmy.github.io/tetris/preview/game.html
- Storybook: https://jimjimjimmy.github.io/tetris/preview/index.html

## Machine / account notes
- Generated on: MacFQ (FQ-M-DQ13K4NV)
- Personal repo - always push with explicit token:
  ```bash
  GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
  git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
  ```
- Every game.html commit MUST update both APP_COMMIT (short hash) and APP_BUILD_DATE (local time via `date +"%Y-%m-%dT%H:%M:%S"` - never UTC)
- Pre-commit hook blocks em-dashes. Hyphens only.
- DEBUG_PIECES must be false before every push.
