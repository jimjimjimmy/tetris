# Handoff - Tetris - 2026-05-27

## What this is
Personal 2-player mobile Tetris game (jimjimjimmy/tetris), Gandalf machine, sync-everything session - no active feature work this session.

## Current state
- 2P game fully playable: shared board, dynamic boundary line, AI opponent (P2), gesture controls
- Best-of-3 score tracking and match/set-over screens in place (aa26d90)
- Level tick speeds rebalanced - L3 = standard Tetris reference pace (8130977)
- Diagonal swipe bug fixed - no longer triggers both horizontal move and hard drop (f2cbfd8)
- Key file renamed: preview/game.html -> preview/index.html (2026-05-27, MacFQ)
- No known bugs or regressions

## Files changed this session
No feature work on Gandalf this session. Uncommitted changes are from a prior session:

| File | Status | What changed |
|------|--------|-------------|
| BUILD-PLAN.md | staged deletion | File deleted - contents migrated to GAME-IDEAS.md |
| GAME-IDEAS.md | unstaged modification | 79 lines added, absorbed BUILD-PLAN content |
| assets/Sound fx/ | untracked | Sound effects directory added but not committed |
| test_plan.md | untracked | Test plan file, not yet committed |

## Uncommitted work
- BUILD-PLAN.md deletion is staged, GAME-IDEAS.md update is unstaged - safe to commit together as a content reorganization
- assets/Sound fx/ and test_plan.md are untracked - decide whether to commit or .gitignore before next push

## Open questions / decisions pending
- Sound assets: commit assets/Sound fx/ or .gitignore it?
- test_plan.md: commit or .gitignore?
- Next game feature: check GAME-IDEAS.md for queued ideas

## What to do next
1. Commit BUILD-PLAN.md deletion + GAME-IDEAS.md update together
2. Decide on sound assets and test_plan.md
3. Read GAME-IDEAS.md for next feature

## How to resume
```bash
cd ~/Dropbox/04\ Projects/AI\ Shared/Tetris
git status
# Live game: https://jimjimjimmy.github.io/tetris/preview/
```

## Machine / account notes
- Generated on Gandalf (sync-everything session 2026-05-27)
- Personal repo - always push with explicit token:
```bash
GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
```
- Every index.html commit MUST update APP_COMMIT + APP_BUILD_DATE (local time, never UTC)
- DEBUG_PIECES and TEST_SPEED must be false before every push
