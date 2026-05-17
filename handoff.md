# Handoff - Tetris (jimjimjimmy/tetris) - 2026-05-16

## What this is

Personal 2-player mobile Tetris project on MacFQ. This session iterated heavily on `preview/game.html` -- the standalone fullscreen entry point intended for iOS Simulator and eventual Capacitor wrap. Storybook file `preview/index.html` was deliberately left untouched throughout the session.

This session's arc: Figma-skin polishing on game.html (gradient corrections, status-bar safe-area, NEXT bottom safe-area, pause centering on boundary, dashed-line orientation), then a start screen with side selection, then wiring the side selection to actually swap which side the human controls, then fixing two real bugs the user hit on mobile (touch handler not re-attaching after the start screen, and the NEXT block always showing P1's queue).

## Current state

Working and shipped:
- `preview/game.html` standalone fullscreen with Figma node 124-1377 / 128-3004 / 145-3068 chrome (icons, pause, NEXT, gradients, grid, dashed boundary, stack-height brackets, "+N" gain indicator, all transitions).
- Start screen: phase="start" initial; "[ P1 up-arrow ]" and "[ P2 down-arrow ]" buttons. Tapping a button transitions phase to "playing" and sets `playerSide`.
- Side switching is functional: P1 selection runs the P2 AI block + human-controlled P1; P2 selection runs the P1 AI block + human-controlled P2.
- `applyP1` and `applyP2` dispatchers handle tap / left / right / hard-drop (`up` for P1, `down` for P2). The "backward" direction is intentionally a no-op for each side.
- Touch handler re-attaches on phase change (deps now `[applyP1, applyP2, state.phase]`). Keyboard handler binds to window so it works regardless.
- Two-deep NEXT queue for BOTH players (`p1Next`+`p1NextNext`, `p2Next`+`p2NextNext`). NEXT block in the sidebar shows whichever side the human is playing.
- Pause icon vertically centered on the starting boundary line (y=440, derived from `PLAY_Y + BDY_2P * CELL - PAUSE_BAR_H/2`).
- iOS Safari gradient compensation: radial stops boosted from Figma source `rgba(17,18,19,0.5)` to `rgba(36,38,44,0.55)`; stripe alpha reduced 0.3 to 0.18. Mobile rendering verification still required on iOS Simulator.
- Status-bar overlay (`apple-mobile-web-app-status-bar-style=black-translucent`) + icon top inset (`calc(<base>px + env(safe-area-inset-top))`). NEXT block bottom safe-area: `top: calc(NEXT_Y - max(20px, env(safe-area-inset-bottom)))`.
- Web Vibration API haptic feedback via single useEffect with refs (piece lock 30ms, row clear 60ms, boundary shift 100ms, game over 200ms). iOS Safari does not support Vibration API; will need a Capacitor plugin for native haptics later.
- Touch gesture sensitivity: STEP_PX = 10 (was 20). 10px swipe registers; tap window <10px.

Partially done / known limitations:
- The "DIFF: none" mobile gradient verification is still on the user's side. I cannot screenshot the iOS Simulator from this environment. If `rgba(36,38,44,0.55)` still reads near-black on iPhone, we can push another +10% lightness.
- Re-install of the home-screen icon needed after status-bar style change (iOS caches the launch config from initial install).
- Vibration API is iOS-unsupported; Capacitor `@capacitor/haptics` plugin will be needed for native iOS feedback.

No known regressions. Mechanics (isValid2P, boundary clamp, decay, clearP1_2P/clearP2_2P) untouched all session.

## Files changed this session

| File | Status | What changed |
|------|--------|-------------|
| preview/game.html | committed (multiple commits) | All visual + interaction changes: Figma skin polish, start screen, side switching, NEXT queue routing, haptics, gesture sensitivity, safe-area insets, gradient values, dashed line orientation, pause centering, mobile touch re-attach fix |
| CLAUDE.md | committed | Last-updated entry refreshed after each commit with summary of that increment |
| .DS_Store | untracked (ignored) | macOS Finder metadata, not committed |

## Uncommitted work

None. Working tree is clean except for `.DS_Store` (macOS Finder turd, never committed).

## Open questions / decisions pending

1. iOS Simulator gradient verification: user reported v17 might still be too dark on real iPhone. If still wrong after testing, push lightness another ~10% (try `rgba(50,53,60,0.55)`).
2. Vibration API on iOS: not supported. When the project moves to Capacitor, swap the haptic block for `@capacitor/haptics` `Haptics.impact({ style: ... })`.
3. Start-screen design is placeholder ("design comes later" per the spec). Currently text-only ASCII style. Future iteration will need a Figma frame to skin from.
4. AI difficulty: there's a single `AI_DIFFICULTY = 'MEDIUM'` constant but no logic gates off it. Easy / Medium / Hard tiers are TODO.
5. The legacy `P2_COLOR_2P = "#4a4a4a"` constant is no longer used for rendering (replaced by opacity-based `P1_LOCKED_COLOR` / `P2_LOCKED_COLOR` / `ACTIVE_COLOR` in v16). Can be deleted in a cleanup pass.

## What to do next

1. **Verify on iPhone PWA standalone.** Add `preview/game.html` to the iOS home screen (delete and re-add to pick up the `black-translucent` status-bar config). Confirm: gradient depth reads correctly, NEXT strip clears the home indicator, P1 and P2 side selection both produce working touch input, NEXT block shows the human's queue for either side. Report any mismatch to next session.
2. **Address remaining gradient discrepancy if any.** If iPhone gradient still feels too dark, bump radial stops another ~10% lightness (target `rgba(50,53,60,0.55)`).
3. **Start-screen design pass.** Pull a Figma frame for the start screen (currently text placeholder) and skin it properly. Probably needs proper button styles, possibly a logo / hero image.
4. **AI difficulty tiers.** Wire `AI_DIFFICULTY` constant to actual scoring weight differences (e.g., EASY skews holes/bumpiness less, HARD adds lookahead).
5. **Capacitor wrap prep.** When iOS native packaging starts: swap `navigator.vibrate` for `@capacitor/haptics`, audit safe-area handling, and decide whether to keep web feature flag toggles or hardcode for native.

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
