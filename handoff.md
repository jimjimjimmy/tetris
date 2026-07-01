# Handoff - Tetris (Drift) - 2026-07-01

## What this is
Personal Tetris game (jimjimjimmy/tetris), MacFQ session, focused on start screen polish and page transition animations.

## Current state
- All transitions working: Settings opens (content drifts in from right), closes (exits right, home content slides in from left)
- Start screen: Music label no longer shifts on toggle, 44px tap areas on Music/Difficulty/Single/2 Players
- Series score pips visible during gameplay, "Play Game 2/3" button naming correct
- Pause screen: Resume/Restart(solo)/Quit(online), POV-correct pip colors
- SVG arrow assets (ArrowR/ArrowL) used everywhere instead of text arrows
- Animation library documented in CLAUDE.md
- Transitions need verification on device after Xcode rebuild

## Files changed this session

| File | Status | What changed |
|------|--------|-------------|
| preview/index.html | committed | Start screen tap areas, Music label fix, all page transitions (driftIn/driftOut/slideInLeft/driftOutRight), React.Fragment stagger system, Settings stagger, 2 Players nowrap |
| CLAUDE.md | committed | Added full Animation Library section: keyframes table, forward/back nav rules, stagger pattern, Settings specifics |

## Uncommitted work
None. All changes committed and pushed.

## Open questions / decisions pending
- Transitions on device need verification after full Xcode rebuild (user reported "no transition work" before doing the rebuild)
- Consider whether start screen should animate OUT when a game starts (no exit animation currently when tapping Single/2 Players)

## What to do next
1. Verify transitions on device after Xcode rebuild: Cmd+Shift+K (clean) then Cmd+R (run) on Gandalf
2. If transitions still broken on device, check WKWebView CSS animation compatibility
3. Consider transitions for game-start and game-over screens using same animation library
4. Any remaining Figma design items

## How to resume
On Gandalf:
```bash
cd ~/Developer/tetris && git pull && npx cap sync ios
# Then Xcode: Cmd+Shift+K + Cmd+R
```

On MacFQ:
```bash
cd "/Users/jimmyche/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris"
git pull
```

## Machine / account notes
- Handoff generated on MacFQ
- Personal repo - always push with explicit token:
  ```bash
  GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
  git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
  ```
- Never commit/push from Gandalf - MacFQ is the sole writer
