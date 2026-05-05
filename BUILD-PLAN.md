# Tetris — Build Plan

Last updated: 2026-05-04

---

## v1 Goal: Single-player prototype

Get the balloon physics and controls feeling right. No multiplayer, no AI, no matchmaking.
Everything in a single storybook.html. Ship to GitHub Pages for device testing.

---

## Phase 1 -- Foundation

- [ ] Design tokens finalized (colors, board cell size, font)
- [ ] GameBoard component: shared board, boundary line, P1 top / P2 bottom split
- [ ] Block rendering: 10-column grid, square cells, ASCII minimal style
- [ ] Piece set: all 7 tetrominoes, rendered as colored cells (no sprites)

## Phase 2 -- Physics

- [ ] P1 gravity: piece falls at fixed interval, accelerates on drop-hold
- [ ] P2 buoyancy: piece floats up at fixed interval, accelerates on drop-hold
- [ ] Collision detection: piece locks when it hits the boundary or another piece
- [ ] Wind: constant horizontal drift applied each tick; direction set at round start
- [ ] Row clear: detect full rows, remove, shift remaining rows toward boundary
- [ ] Boundary shift: each row cleared moves boundary line 1 row toward opponent
- [ ] Win condition: detect when a player has 0 rows remaining

## Phase 3 -- Controls (on-screen buttons)

- [ ] ControlPad component: [ <- ] [ rotate ] [ -> ] with [ drop ] centered below
- [ ] Semi-transparent button style, large tap targets (mobile-first, 393px wide)
- [ ] P1 layout: buttons at bottom of screen
- [ ] P2 layout: buttons at top of screen (mirrored/flipped)
- [ ] Rotate: always clockwise for both players
- [ ] Drop: P1 holds to accelerate down; P2 holds to accelerate up

## Phase 4 -- Game loop

- [ ] Piece queue: spawn next piece at start of player's territory
- [ ] Next-piece preview
- [ ] Game start / game over screen
- [ ] Score / territory counter display (how many rows each player holds)
- [ ] Replay / rematch button

## Phase 5 -- Polish (pre-v2)

- [ ] Lock delay (brief grace period before piece locks on contact)
- [ ] Wall kick (standard SRS kicks on rotate near wall)
- [ ] Piece ghost (faint outline showing where piece will land)
- [ ] Sound: optional, minimal (single oscillator beeps, no audio files)

---

## v2 -- Multiplayer

- [ ] WebSocket server (separate from storybook, likely Node.js)
- [ ] Random matchmaking (anonymous)
- [ ] Friend match via room code
- [ ] Solo vs AI
- [ ] Wind indicator UI
- [ ] Co-op mode: both players clearing the same board

---

## v3 -- iOS

- [ ] Capacitor wrapper
- [ ] App Store assets (icon, splash, screenshots)
- [ ] Touch input audit (replace any hover states)

---

## Notes

- All v1 components go into `preview/storybook.html` first
- Extract to `components/` only when the dev team needs them
- Figma file: TBD (visual style is ASCII/minimal, may not need Figma for v1)
- No em-dashes anywhere -- pre-commit hook will block commits containing them
