# Tetris - Project Context

<!--
  IMPORTANT: KEEP THIS FILE CURRENT
  Whichever machine (MacFQ or Gandalf) adds a component, updates a file,
  or makes a structural change: update this file before ending the session.
  Both machines depend on this as the single source of truth.
  Last updated: 2026-05-16 - MacFQ (game.html v23 P2 NEXT queue + side-aware NEXT display: P2 now has its own 2-deep NEXT queue (p2Next + p2NextNext, mirror of P1's). The P2 spawn block shifts the queue (p2Next <- p2NextNext, p2NextNext <- randPiece()), matching P1's behavior. The NEXT block in the sidebar reads from whichever side the human is playing: playerSide===2 shows p2Next/p2NextNext, otherwise p1Next/p1NextNext (default). Each side's queue is independent, so the AI's queue doesn't interfere with the human's NEXT preview. No game-mechanic rule changes; index.html untouched.)
-->

## Required reading before building

Before implementing any component or fixing any visual bug, read the design-to-code-qa skill:

- Skill: `~/.claude/skills/design-to-code-qa/SKILL.md`

Non-negotiables:
1. No `localhost:*` or `file://` URLs in committed code. Fetch and save every asset from Figma MCP into `assets/` before committing.
2. Run the visual + technical QA checklist before any commit that touches visuals.
3. `grep -rn "localhost:\|file://" preview/` should return nothing.

---

## What this is

**Tetris** (working title) -- a two-player mobile web game, eventually wrapped in Capacitor for iOS App Store.

No bundler, no build step. Single HTML file rendered by Babel CDN in the browser.

## Key file

```
preview/index.html   <- THE file. All components live here.
                            Never create separate standalone preview files.
preview/game.html    <- Standalone fullscreen entry point that renders ONLY
                            TetrisGame2P. For mobile testing (Xcode Simulator)
                            and the eventual Capacitor wrapper. Has its own
                            inlined copy of TetrisGame2P + dependencies.
                            P1 is HUMAN-controlled here (no AI scoring block):
                              tap   = rotate CW (Space key parallel)
                              swipeL/R = move horizontally (Arrow keys)
                              swipeUp  = hard-drop UP / buoyancy boost (ArrowUp)
                              swipeDown = +1 row toward floor (ArrowDown)
                            Gesture handler is scoped to a playRef element
                            (NOT document) so taps on the right-sidebar
                            chrome do not trigger P1 inputs.
                            P2 still AI. EXCEPTION to the rule above: never
                            add other components here. Keep it minimal.
                            Skinned to Figma node 124-1377 (Portfolio-2026):
                            CELL=20, play area 200x400 centered vertically,
                            right sidebar (info, gear, pause, NEXT). The
                            ergonomic pause hit box is 48x48 around the
                            12x16 visible bars. 2-deep P1 NEXT queue
                            (p1Next + p1NextNext) -- newer pieces enter
                            the TOP slot and shift down as they spawn.
```

Live URLs:
- Storybook (all components): https://jimjimjimmy.github.io/tetris/preview/index.html
- Fullscreen game (mobile/Capacitor): https://jimjimjimmy.github.io/tetris/preview/game.html

---

## Game concept

### Core mechanic
- Shared board split between two players by a boundary line
- P1 plays from the top half, pieces fall down (normal gravity)
- P2 plays from the bottom half, pieces float up (balloon/buoyancy physics)
- Wind drifts pieces left or right as they fall/rise
- Clearing a row moves the boundary line, stealing territory from the opponent
- Win condition: push the opponent's territory to zero rows

### Physics notes
- P1 drop = assisted by gravity (hold to accelerate fall)
- P2 drop = assisted by buoyancy (release = piece floats up faster)
- Wind is a constant horizontal drift applied during movement, not just on input
- Rotate is always clockwise for both players

### Directional language
- "Toward opponent" = aggressive (P1 moves down, P2 moves up)
- "Away from opponent" = defensive

---

## Controls (v1 - on-screen buttons)

No swipe gestures in v1. Semi-transparent on-screen buttons only.

Layout:
```
[ <- ]  [ rotate ]  [ -> ]
        [  drop  ]
```

- P1: drop accelerates the piece downward
- P2: drop accelerates the piece upward (buoyancy boost)
- Both: rotate is always clockwise

Wind indicator: planned for v2 (not in v1).

---

## Game modes

| Mode | Description |
|------|-------------|
| Versus | Territorial war -- clear rows to push boundary into opponent's space |
| Co-op | Both players collaboratively clear the same shared board |

---

## Multiplayer (v2+)

| Type | Mechanic |
|------|----------|
| Random match | Anonymous or named matchmaking |
| Friend match | Room code |
| Solo vs AI | AI opponent |

---

## Visual style

- ASCII/minimal aesthetic -- no custom assets
- No sprites, no images, block pieces only
- Color palette TBD (likely monochrome or 2-color contrast)
- Mobile-first layout (fits 393px wide)

---

## Tech stack

| Layer | Tech |
|-------|------|
| v1 | React 18 CDN + Babel Standalone 7.23.9, single index.html |
| v2 | WebSockets for real-time multiplayer |
| v3 | Capacitor for iOS App Store wrap |

---

## Folder structure

```
preview/index.html      <- storybook (design QA)
components/                 <- engineering deliverables (.jsx per component)
  tokens.js                   design tokens as JS exports
assets/                     <- any static assets (none for v1, ASCII only)
BUILD-PLAN.md               <- project roadmap
COMPONENT-INDEX.md          <- engineering reference with component notes
CLAUDE.md                   <- this file
```

**Rule:** `components/` is a parallel engineering deliverable. New components go into index.html first, then get extracted to `components/` separately.

---

## GitHub - Single remote (personal project)

| Remote | Repo | Purpose |
|--------|------|---------|
| `origin` | `https://github.com/jimjimjimmy/tetris.git` | Personal dev - only remote |

### Push commands (two-account setup - ALWAYS use explicit token)
```bash
GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
```

> This machine has two GitHub accounts (jimjimjimmy personal + JimmyChe_floqast work).
> Always use the explicit token form above or git will use the wrong account and get a 403.
> Tetris is personal -- Gandalf CAN push directly. No freeradicals-studio remote needed.

---

## Architecture

### Stack
- React 18 (UMD CDN)
- Babel Standalone 7.23.9 (in-browser JSX transform)
- Inter font (Google Fonts)
- `<script type="text/babel">` - all code is JSX inside this single tag

### Design tokens - T object
```js
const T = {
  bg:    "#f5f5f5",
  white: "#ffffff",
  black: "#1a1a1a",
  gray:  "#999999",
  // Expand as the color palette is decided
};
```

### Animation hook
```js
function useReveal(duration) {
  // RAF-driven 0 to 1 ease-out cubic. Returns progress value p (0-1).
  // Use p to drive bar widths, opacity, transforms on mount.
}
```

---

## Adding a new component

1. Write `function MyComponent() { ... }` above `const SECTIONS`
2. Add an entry to the correct section in `SECTIONS`:
   ```js
   { id: "MyComponent", label: "My Component", desc: "Short description", component: MyComponent }
   ```
3. If it has animation, add `"MyComponent"` to `ANIMATED_IDS`

**canvas-wrap default** - components render inside `.canvas-wrap` (padding 20px, border-radius 12). Override per component if needed.

---

## Critical editing rules

### JSX style - ALWAYS objects, NEVER strings
```jsx
// correct
<div style={{display:"flex", gap:8}}>
// will break the page silently
<div style="display:flex; gap:8px">
```

### Editing the file
- Use Python string replacement - never `sed -i` (breaks on macOS with special chars)
- After every component replacement, check for extra closing brace artifact:
  - Bad pattern: `  );\n}\n}\n\n\nconst SECTIONS`
  - Good pattern: `  );\n}\n\n\nconst SECTIONS`

### SVG in JSX
- All SVG attributes must be camelCase: `strokeWidth`, `strokeLinecap`, `fillRule`
- `style` attributes inside SVG must also be objects

### Design philosophy
- Match Figma exactly. Measure everything: spacing, alignment, line weight, placement.
- Never simplify. The design is the thinking.
- Always screenshot after visual changes - never say "done" without visual proof.
- User uses Brave browser. Control Chrome MCP works with Brave.

---

## Cross-machine collaboration (MacFQ + Gandalf)

- **MacFQ** = Jimmy's FloQast MacBook. Has access to FQ GitHub (FloQastInc repos) and freeradicals-studio. All FQ-related pushes happen here only.
- **Gandalf** = personal machine. Has access to jimjimjimmy personal GitHub only. No FQ GitHub access.
- Tetris is a personal project - Gandalf CAN push to jimjimjimmy/tetris directly.
- Files live in Dropbox: `~/Dropbox/04 Projects/AI Shared/Tetris/`
- Dropbox handles live file sync between machines
- Git is the source of truth for committed state - push at end of every session

### Handoff rules
1. **Update this CLAUDE.md** whenever you add a component, rename a file, or change the architecture.
2. **Never create standalone HTML preview files** - all components go into index.html.
3. **Push to GitHub** at the end of every session so both machines are on the same commit.
4. **Don't assume the other machine's session history** - write CLAUDE.md as current facts.

---

## Current components

### Game
- `TetrisGame` - single-player 180-degree Tetris. P2, wind, and boundary shift stripped. Clean foundation for rebuilding 2P mechanics.
  - ROWS=33, COLS=10, CELL=40, BOARD_PX=400. Frame 402px wide, BOARD_LEFT=1. Boundary fixed at 12.
  - ROWS=33: rows 0-29 are visible (20-row viewport at rows 10-29), rows 30-32 are off-screen spawn buffer. Spawn at ROWS-4=29 fills full visible height.
  - P1 territory = rows boundary..ROWS-1. Boundary is FIXED (no territory shifts on clear).
  - P1 spawns at row ROWS-4=26 (bottom), floats UP (y-1 per tick), stacks near boundary (row 12).
  - Game over = spawn blocked (standard Tetris lose condition).
  - Row clear: full rows in P1 territory removed, remaining rows shift toward boundary (upward). Viewport stays fixed via p1ViewAnchor.
  - P1 viewport: 20 rows starting at p1ViewAnchor (boundary-PEEK=10). p1ViewAnchor clamped to boundary.
  - Auto-AI: board-evaluating smart AI. Evaluates all (rot, x) combos via getLandingY + clearRows simulation. Scores by: line clear bonus (500/line) + quadratic row density (filled^2) + height penalty + hole penalty (30 per buried empty cell) + bumpiness penalty (2 per adjacent column height diff). SCORE_MAX_R=ROWS-4 caps scoring to visible rows only. Moves one step/tick toward best target. AI_PERIOD=1. Clears ~5+ rows per 60s at normal speed. All 10 columns stay active.
  - AI difficulty: AI_DIFFICULTY constant ('EASY'|'MEDIUM'|'HARD'). EASY: 33% chance of random move. MEDIUM/HARD: always optimal.
  - TEST_SPEED: TEST_SPEED=true sets TICK_MS=110 (5x speed). TEST_SPEED=false (default) sets TICK_MS=550. ALWAYS false before push.
  - Controls: arrow keys (left/right/up=rotate/down=drop). No on-screen HUD buttons.
  - Cheat keys: "1" fill+clear boundary row, "2" clear full rows, "3" staircase fill, "0" reset.
  - Layout: P1_VP_Y=0, NEXT_Y=800, GAME_H=874. NEXT strip = 74px (#080808).
  - Cells: 34x34px visible (CELL=40 - 3px padding each side), color #B1B2B3. No grid borders.
  - Boundary visual: 2px semi-transparent white line at boundary row inside BoardViewport.

### 2P Shared Board
- `TetrisGame2P` - shared board with P1 (bottom half, floats UP, #B1B2B3) and P2 (top half, falls DOWN, #4a4a4a). Territorial tug-of-war via boundary shift.
  - Layout: NEXT_2P_H=37px P2-NEXT + 800px board (20 rows) + 37px P1-NEXT = GAME_2P_H=874px.
  - ROWS_2P=20 (the 2P-specific row count). EVEN, so boundary = ROWS_2P / 2 = 10 sits at the exact midpoint and both players own identical territory of ROWS_2P/2 = 10 rows each. No spawn buffer -- every row is visible and playable. (The legacy 1P standalone games keep ROWS=33 with their old layout; ROWS_2P is a separate constant just for TetrisGame2P.)
  - BDY_2P = ROWS_2P / 2 = 10 is the INITIAL boundary only. Actual boundary is dynamic state, tracked as `boundary` in component state.
  - Territory shift mechanic with decay: each cleared row contributes `max(MIN_SHIFT, 1 / (1 + DECAY_RATE * priorClears))` to that player's fractional accumulator (`p1ShiftAcc`/`p2ShiftAcc`). Each tick the integer portion drains into the boundary (P1 push UP, P2 push DOWN); fractional remainder persists. Constants live in the top block: `DECAY_RATE = 0.05`, `MIN_SHIFT = 0.25`. Decay floor reached around 60 clears. Helpers: `decayShiftAt(priorClears)`, `sumDecayShift(startIdx, n)`.
  - Win condition: `boundary <= 0` -> P1 WINS (P2 squeezed out). `boundary >= ROWS_2P` (20) -> P2 WINS (P1 squeezed out). GAME OVER overlay shows "P1 WINS" / "P2 WINS" with "territory claimed" subtitle.
  - Board cells store only `CELL_EMPTY=0`, `CELL_P1=1`, `CELL_P2=2`. The boundary is NOT stored in the board -- it lives in state as a separate variable. `isValid2P(cells, board, boundary, player)` applies the asymmetric rule so the boundary row belongs to exactly ONE player (P1): P1 rejects cells at `r < boundary`, P2 rejects cells at `r >= boundary`. This guarantees equal-sized territories when ROWS_2P is even and BDY_2P = ROWS_2P / 2: P2 owns rows 0..ROWS_2P/2-1 (top half), P1 owns rows ROWS_2P/2..ROWS_2P-1 (bottom half). The boundary line is a 2px CSS overlay rendered by `BoardViewport`, not board cells. Helpers: `initBoard2P` (all zeros), `isValid2P`, `lockPiece2P`. Preventive boundary clamp keeps the line from sliding past locked cells: `maxP2Row < newBdy <= minP1Row`. P1 spawn formula `ROWS_2P - 1 - pieceMaxDr(type, 0)` places the piece bottom on the visible floor (row ROWS_2P-1).
  - Demo HUD (pure UI):
    - `P` key toggles pause. While paused, both players freeze (tick callback early-returns when `s.paused`). PAUSED overlay shown at center.
    - Countdown timer (`DEMO_DURATION_S = 60` constant). Wall-clock setInterval decrements `demoLeft` once per second unless paused or summary is set. When it hits 0, `summary = {p1Lines, p2Lines, boundary, winning}` is stored, the tick freezes, and a DEMO COMPLETE overlay appears with the stats and a REMATCH button.
    - Timer shown as `M:SS` in the top NEXT strip (between the P2 piece preview and the P2 score). Tabular-nums for stable width.
    - Pure UI: no changes to `isValid2P`, boundary logic, piece movement, or AI scoring.
  - Boundary line: 2px white line, animated with `transition: top 260ms cubic-bezier(0.22, 1, 0.36, 1)`. Glow via boxShadow when animateBoundary=true.
  - BoardViewport extended with `animateBoundary` prop. TetrisGame (single-player) passes false (default); TetrisGame2P passes true.
  - Symmetric spawn: P1 spawns at `y = P1_VIEWPORT_H - 1 - pieceMaxDr(type, 0)` (body bottom at row 19, far edge of P1 visible territory). P2 spawns at `y = 0` (body top at row 0, far edge of P2 territory). Travel distance per piece = `boundary - 1 - pieceMaxDr` for both players. Helpers: `pieceMaxDr(type, rot)`, `p1SpawnY2P(type)`. Previously P1 spawned at `ROWS-4=29` which gave it a 19-tick fall vs P2's 6-8 ticks (~2.86:1 cycle-rate asymmetry).
  - Row clear helpers `clearP1_2P(board, bdy)` / `clearP2_2P(board, bdy)` now take dynamic bdy parameter.
  - Both AI-controlled. AI uses 4-component scoring (line clears + density + height penalty + holes + bumpiness) parameterized on the current dynamic boundary. SCORE_MAX_1=19 fixed (last visible row). SCORE_MAX_2 = boundary - 1 (P2 territory upper bound).
  - P1 height penalty: `Math.max(0, ly - boundary - 2) * 4`. Both P1 and P2 AI now use SINGLE-STEP repositioning per tick (rotate XOR slide one cell, then fall one cell). Replaces earlier while-loop that did all rotations + slides in one tick, which read as a teleport. Verified by 110ms sampling: pieces move exactly 1 row per tick in opposite directions, perfectly co-tick.
  - Verified decay at TEST_SPEED=true (60s): early P2 clears each pushed ~1 row, later clears took ~2 P2 clears per row of shift. Game ended at 35s with P2=15 clears, P1=2 (vs 24.6s / P2=10 / P1=0 pre-decay) -- 42% longer match, no death spiral, P1 had time to score. "P2 WINS" overlay triggered correctly. Zero console errors.
  - Verified P1/P2 symmetry at TEST_SPEED=true across 4 games: P1=51 total clears, P2=49 total clears (ratio 1.04:1, was 2.86:1 pre-fix). Winner distribution: 3 P1 wins, 1 P2 win. Boundary stayed near midline in early-game, drift driven by piece RNG rather than systemic asymmetry. Zero console errors.
  - Triple-validation completed: Round 1 (code audit) showed every P1 line of code has a mirrored P2 line on adjacent lines with same args. Round 2 (runtime probe at 110ms cadence) confirmed mean tick interval = 110.0ms (TICK_MS), P1 piece moved -1 row per tick (17->10), P2 piece moved +1 row per tick (2->9), both locking same tick; bdyEvents=[] during 6s window with no row clears (boundary only ever updates when n1>0 or n2>0). Round 3 (six screenshots at 10s intervals over 60s, with auto-rematch on game-over) showed every frame has cells in correct territories, boundary visible at midline, stacks growing comparably on each side. No jumps, no random resets.
  - P2 color #4a4a4a (dark gray). P1 color #B1B2B3 (light gray).
  - CompactNext: 7px cells, no label, both 37px NEXT strips.
  - Debug key "0" resets.
  - TEST_SPEED: same global flag. ALWAYS false before push.

### Components
- `NextPieceDisplay` - renders upcoming P1 piece using 18px cells. Shows "NEXT" label above.
- `CompactNext` - compact piece preview for 37px NEXT strips. 7px cells, no text label.

### P2 Standalone
- `TetrisGameP2` - standard gravity Tetris (P2 perspective, for independent testing alongside TetrisGame).
  - P2_FLOOR=20, P2_SPAWN_Y=3, P2_VP_START=1, P2_VIEWPORT_H=20. Mirrors P1 exactly from the other end.
  - P2_FLOOR = ROWS-1-12 = 20 (mirror of P1 boundary=12). P2 territory: rows 3..20 (18 rows, same as P1).
  - Pieces spawn at row 3 (top), fall DOWN (y+1 per tick), stack from row 20 upward.
  - Row clear: `clearRowsP2()` removes full rows in 0..P2_FLOOR, prepends empty rows at top (pieces shift DOWN). Mirror of P1 clearRows.
  - isValidP2: r >= 0 && r <= P2_FLOOR && c within COLS && cell null. No boundary arg.
  - AI: same scoring structure as P1 but flipped. Height penalty: penalize landing far from P2_FLOOR. Hole penalty: empty cell with fill ABOVE (unreachable in standard gravity). Bumpiness: same formula.
  - Viewport: fixed [P2_VP_START, P2_VP_START+P2_VIEWPORT_H) = rows 1..20, 800px. Same GAME_H=874.
  - AI only (no keyboard/touch controls). Debug key "0" resets.
  - Verified: 10+ lines in 60s at 5x speed, all 10 cols active, collapse direction correct, zero errors.

---

## Memory

User preferences: `~/Dropbox/04 Projects/AI Shared/memory/MEMORY.md`
