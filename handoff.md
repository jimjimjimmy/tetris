# Handoff - Tetris (jimjimjimmy/tetris) - 2026-05-17

## What this is

Personal 2-player mobile Tetris project on MacFQ. This session fixed the P2 NEXT
piece preview display order, updated GAME-IDEAS.md with new big ideas (Real-World
Conditions, Planetary Environments, Game Design Philosophy), and synced memory.

## Current state

Working and shipped (v24):
- `preview/game.html` standalone fullscreen with full Figma chrome (icons, pause, NEXT,
  gradients, grid, dashed boundary, stack-height brackets, "+N" gain indicator).
- Start screen with P1/P2 side selection. Side switching functional: human controls
  the chosen side, AI controls the other.
- Two-deep NEXT queue for both players (p1Next+p1NextNext, p2Next+p2NextNext).
- **P2 NEXT slot direction fixed (v24):** TOP slot (opacity 0.5, more prominent) now
  shows the next-to-spawn piece when playing as P2. Previously showed the piece AFTER
  next. Fix: two-line swap in the render destructure swapping nextTop/nextBottom
  assignment when playerSide===2. P1 display unchanged.
- Touch handler re-attaches on phase change. Haptics via Web Vibration API.
  Safe-area insets for status bar and home indicator. Gradient compensation for iOS.
- GAME-IDEAS.md expanded with: Game Design Philosophy (transparency / fair-by-design),
  Real-World Conditions (live weather API driving game physics), Planetary Environments
  (per-planet physics presets with full planet list).

Partially done / known limitations:
- iPhone PWA gradient verification still on user's side. If rgba(36,38,44,0.55) still
  reads near-black on real iPhone, bump to rgba(50,53,60,0.55).
- Start screen is placeholder ASCII style. Figma frame not yet started.
- AI_DIFFICULTY constant exists but no logic gates off it.
- Vibration API is iOS-unsupported; Capacitor @capacitor/haptics needed for native.

No known regressions. All mechanics untouched this session.

## Files changed this session

| File | Status | What changed |
|------|--------|-------------|
| preview/game.html | committed (a650270) | P2 NEXT slot direction fix: TOP slot now shows p2Next (next-to-spawn) when playerSide===2 |
| CLAUDE.md | committed (a650270) | Last-updated entry bumped to v24 |
| GAME-IDEAS.md | committed (47ee525) | Added Game Design Philosophy, Real-World Conditions, Planetary Environments sections |

## Uncommitted work

None. Working tree is clean except .DS_Store (never committed).

## Open questions / decisions pending

1. iPhone gradient verification: rgba(36,38,44,0.55) not yet confirmed on real device.
   If still too dark, try rgba(50,53,60,0.55).
2. Real-World Conditions multiplayer: whose weather applies when players are in different
   locations? Options noted in GAME-IDEAS.md - no decision yet.
3. Start screen needs a Figma frame before skinning ("design comes later").
4. AI_DIFFICULTY constant exists but EASY/MEDIUM/HARD have no behavioral difference yet.
5. P2_COLOR_2P "#4a4a4a" legacy constant no longer used - can be deleted in cleanup.

## What to do next

1. **iPhone PWA test.** Delete and re-add game.html to iOS home screen (picks up
   black-translucent status bar config). Verify: gradient depth, NEXT strip clears home
   indicator, both P1/P2 side selections produce working touch, NEXT block correct.
2. **Gradient fix if needed.** If still too dark on iPhone, bump to rgba(50,53,60,0.55).
3. **Start screen design pass.** Pull Figma frame, skin properly (buttons, layout, logo).
4. **AI difficulty tiers.** Wire AI_DIFFICULTY to scoring weights (EASY: reduce hole/
   bumpiness penalty; HARD: add 1-piece lookahead).
5. **Real-World Conditions spike.** Weather API call at game start -> WIND_FORCE constant
   -> lateral drift per tick. Show conditions in HUD before match.

## How to resume

```bash
# From either MacFQ or Gandalf
cd "$HOME/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris"
git pull

# Run a local server to test in Brave or Simulator
python3 -m http.server 7654
# then open http://localhost:7654/preview/game.html

# When ready to push:
GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
```

Live URLs (auto-updated from main):
- Storybook: https://jimjimjimmy.github.io/tetris/preview/index.html
- Fullscreen game (target for Simulator + Capacitor): https://jimjimjimmy.github.io/tetris/preview/game.html

## Machine / account notes

- Generated on **MacFQ**.
- Personal repo on `jimjimjimmy` GitHub account, NOT FloQast. Always push with the explicit token form shown above to avoid pushing under the wrong account.
- Cross-machine state lives in Dropbox `04 Projects/AI Shared/Tetris/`. Both MacFQ and Gandalf can edit; CLAUDE.md is the single source of truth for component state.
- Pre-commit hook blocks em-dashes. Use hyphens (`-`) only in commits, code, and docs.
- TEST_SPEED constant must be `false` before every push. Verified clean for this handoff.
