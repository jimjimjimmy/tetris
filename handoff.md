# Handoff - Tetris (jimjimjimmy/tetris) - 2026-05-21

## What this is

Personal 2-player mobile Tetris project on MacFQ. This session added two
gameplay-feel improvements (discrete-swipe ratchet + ghost piece) and a
build-identity stamp on the start screen. Ended mid-task on a ghost-opacity
tweak the user interrupted to call handoff.

## Current state

Working and shipped:
- `preview/game.html` v26 with full Figma chrome (icons, pause, NEXT, gradients,
  grid, dashed boundary, stack brackets, "+N" gain indicator) + start screen
  with P1/P2 side selection + side-aware human/AI routing.
- Both queues two-deep: p1Next+p1NextNext, p2Next+p2NextNext. NEXT sidebar
  shows whichever side the human is playing.
- **Discrete swipe ratchet (this session, daeeefc):** STEP_PX 10 -> 30. Each
  30px of horizontal drag fires exactly one cell move. Long drags step
  discretely. No more continuous-slide feel.
- **Ghost piece (this session, daeeefc):** active piece projected straight up
  (P1) or down (P2) to landing position, painted at GHOST_COLOR
  rgba(177,178,179,0.2) before active piece is painted. Only for the human
  player's piece; AI piece has no ghost.
- **Build-identity stamp (this session, a76c713):** APP_VERSION = "v0.1",
  APP_COMMIT = "daeeefc" constants. Renders "v0.1 . daeeefc" at bottom-center
  of the start screen only, monospace 10px / 2px letter-spacing / opacity 0.35.
- Pause icon vertically centered on starting boundary line (y=440).
- iOS Safari gradient compensation. Status-bar overlay + chrome top safe-area.
  NEXT bottom safe-area. Haptics via Web Vibration API (Android only).

Partially done / interrupted:
- User asked to reduce ghost opacity from 0.2 to ~0.15 because the ghost
  looks identical to P2's locked stack (same alpha as P2_LOCKED_COLOR) and
  reads as a placed piece. Was about to ship a one-line GHOST_COLOR change
  when user called handoff. Not committed.

Known limitations carrying over:
- iPhone PWA gradient verification still on user's side. If rgba(36,38,44,0.55)
  still reads near-black on real iPhone, bump to rgba(50,53,60,0.55).
- Start screen is placeholder ASCII style. Figma frame not yet started.
- AI_DIFFICULTY constant exists but no logic gates off it.
- Vibration API is iOS-unsupported; Capacitor @capacitor/haptics needed for
  native haptics.
- APP_COMMIT must be updated manually before each commit (no build step).

No known regressions. All game mechanics untouched this session.

## Files changed this session

| File | Status | What changed |
|------|--------|-------------|
| preview/game.html | committed (daeeefc) | STEP_PX 10->30 (discrete swipe ratchet); ghost piece overlay added (GHOST_COLOR + computation in render before active-piece overlay) |
| preview/game.html | committed (a76c713) | APP_VERSION + APP_COMMIT constants; version stamp rendered at bottom of start screen |
| CLAUDE.md | committed (both) | Last-updated entry refreshed after each commit |
| .DS_Store | untracked (ignored) | macOS Finder metadata, not committed |

## Uncommitted work

None on disk. The pending ghost-opacity tweak (rgba alpha 0.2 -> 0.15) was
planned but interrupted before any edit. Working tree is clean except for
`.DS_Store`.

## Open questions / decisions pending

1. **Ghost opacity (interrupted task).** Current GHOST_COLOR = rgba(177,178,179,0.2)
   which is identical to P2_LOCKED_COLOR, so ghost looks like a placed piece.
   User asked to drop to 0.15 (or lower). Next session: change the constant,
   verify ghost is visibly distinct from locked pieces, ship.
2. iPhone PWA gradient: still unverified on device.
3. Start screen Figma frame: design pass needed.
4. AI_DIFFICULTY tiers: not wired.
5. APP_COMMIT automation: optional pre-commit hook to run `git rev-parse
   --short HEAD` and substitute into the file.

## What to do next

1. **Finish ghost-opacity fix.** Change GHOST_COLOR in preview/game.html from
   "rgba(177, 178, 179, 0.2)" to "rgba(177, 178, 179, 0.15)" (or lower).
   Reload, confirm ghost is faint hint not solid piece. Update CLAUDE.md.
   Update APP_COMMIT to current HEAD before commit. Push. Done.
2. **iPhone PWA verification.** Delete + re-add game.html on iOS home screen
   (picks up status-bar config). Verify gradient depth, NEXT clears home
   indicator, both sides selectable + controllable, version stamp visible.
3. **Start screen Figma pass.** Pull a frame, skin properly.
4. **AI difficulty tiers.** Wire AI_DIFFICULTY to scoring weights.
5. **Real-World Conditions spike** (from GAME-IDEAS.md): weather API at game
   start -> WIND_FORCE constant -> lateral drift per tick.

## How to resume

```bash
# From either MacFQ or Gandalf
cd "$HOME/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris"
git pull

# Local server (matches the working-dir layout used by tetris-storybook).
# The repo serves preview/game.html via the parent http-server config in
# Dropbox/04 Projects/AI Shared/.claude/launch.json (cwd=./Tetris).
python3 -m http.server 7654
# then open http://localhost:7654/preview/game.html

# When ready to push:
GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
```

Live URLs (auto-updated from main):
- Storybook: https://jimjimjimmy.github.io/tetris/preview/index.html
- Fullscreen game (target for Simulator + Capacitor):
  https://jimjimjimmy.github.io/tetris/preview/game.html

## Machine / account notes

- Generated on **MacFQ**.
- Personal repo on `jimjimjimmy` GitHub account, NOT FloQast. Always push
  with the explicit token form shown above.
- Cross-machine state lives in Dropbox `04 Projects/AI Shared/Tetris/`. Both
  MacFQ and Gandalf can edit; CLAUDE.md is the single source of truth.
- Pre-commit hook blocks em-dashes. Use hyphens only in commits, code, docs.
- TEST_SPEED constant must be `false` before every push. Verified clean.
- APP_COMMIT must be updated to short hash of HEAD just before commit so
  the start-screen stamp reflects the build being shipped.
- Current build identity: APP_VERSION = "v0.1", APP_COMMIT = "daeeefc"
  (pre-handoff). After next commit, bump APP_COMMIT first.
