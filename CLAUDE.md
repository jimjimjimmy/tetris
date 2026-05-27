# Tetris - Project Context

<!--
  IMPORTANT: KEEP THIS FILE CURRENT
  Whichever machine (MacFQ or Gandalf) adds a component, updates a file,
  or makes a structural change: update this file before ending the session.
  Both machines depend on this as the single source of truth.
  Last updated: 2026-05-21 - Gandalf (game.html: ghost opacity 0.075, lane guide opacity 0.10 (rgba for background-agnostic theming); P2_LOCKED_COLOR #4a4a4a fully opaque; human player always gets bright locked color regardless of P1/P2 side; APP_BUILD_DATE + relTime() helper for version stamp with s/m/h/d precision; stamp font 12, flex layout. APP_COMMIT ba417d1.)
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
  - Gesture surface (cd3ae0a): touch listeners attach to a transparent
    full-height capture div spanning x=0..SIDEBAR_X=320. Player can swipe/tap
    anywhere on the left portion of the screen, not just the narrow 200px
    play column. Right sidebar (info/gear/pause/NEXT at x>=349 > SIDEBAR_X)
    sits outside the capture zone and remains independently tappable.
  - Live boundary solid line (438f492): replaced the dashed
    backgroundImage with background:<color> on both left + right
    live-boundary divs. background-color added to the transition so
    neutral/gain/loss color flips ease smoothly. Origin (dotted) line
    unchanged.
  - Status-color boundary indicator (571aaa0, Figma 152-1747 / 152-2247):
    when the live boundary is displaced, the live dashed line, the
    bracket (stem + cap), and the +N/-N text all switch to a status
    color. Gain = #2fff00, loss = #ff0000. Neutral keeps the existing
    white treatment.
    Per-element opacities per Figma: live dash 0.5 (rgba pre-mixed for
    the gradient), bracket cap 0.5, bracket stem 0.15, text 0.5.
    Bracket gains a 4x1 horizontal cap at the LIVE boundary end
    (top for gain, bottom for loss). Text style updated to Inter
    Regular 10/2px uppercase per spec.
    Constants added: GAIN_HEX, LOSS_HEX, GAIN_DASH_RGBA, LOSS_DASH_RGBA.
    All indicator elements live in the [261, 320] right-margin gutter
    between play area and sidebar -- no overhang into either.
    DASH_RIGHT_W set to 0: the right-side dash stub was removed so the
    boundary line clips exactly at the play area right edge (x=261).
  - 1:1 boundary shift + DEBUG_PIECES (0a3b9ef): removed the decay
    accumulator (decayShiftAt/sumDecayShift, DECAY_RATE, MIN_SHIFT,
    p1ShiftAcc, p2ShiftAcc). Each row cleared moves the boundary by
    exactly 1, with no fractional carry-over. Tick is now
    newBdy = boundary - n1 + n2. Fixes the +1->+2 (and -1->-2)
    fencepost where the second clear's 0.952 contribution got stuck
    below floor=1, and the simultaneous 2-row-at-+1 case that landed
    on +2 instead of +3.

    New smoke-test mode DEBUG_PIECES (default false): when true,
    randPiece() always returns BAR, a 10x1 horizontal piece added to
    SHAPES. One BAR drop = one filled row = exactly one row clear,
    so transition tests are deterministic. New spawnX(type) helper
    returns 0 for BAR (full-row alignment), 3 otherwise. All spawn
    sites switched from x:3 literal to spawnX(type). Always false
    before push.
  - Line clear flash + wall kicks (4a2080c, closes #3 + #4):
    Wall kicks: applyP1/applyP2 'tap' tries [0, +1, -1] x-offsets on
    rotation; first valid (rot, x) wins. Updates both rot and x in
    the same state change.
    Line clear flash: new state.clearAnim shape {rows: number[],
    ts: ms} | null. Tick scans for full rows BEFORE clearP*_2P
    mutates the board (per-side: P1 territory r>=boundary, P2
    territory r<boundary). For 100ms a white rgba(255,255,255,0.7)
    overlay sits at PLAY_Y + r * CELL for each cleared row. Expire
    via useEffect setTimeout, reference-equality guard so a fast
    second clear doesn't cancel the first. New constant
    CLEAR_FLASH_MS = 100.
  - Soft drop (be798e9/corrected): soft drop fires in the natural-travel
    direction -- same way the piece moves automatically.
      P1 (floats UP): swipe-up / ArrowUp -> y-1 (one row UP per STEP_PX)
      P2 (falls DOWN): swipe-down / ArrowDown -> y+1 (one row DOWN per STEP_PX)
    Opposite swipe is intentionally a no-op (against gravity).
    Keyboard: ArrowUp fires P1 soft (side!=2); ArrowDown fires P2 soft (side==2).
    Touch onMove: P1 fires on negative dy (swipe-up); P2 fires on positive dy (swipe-down).
    Both refresh the lock-delay timer like any other successful input.
    Touch soft drop is one-shot per gesture: softFired flag set on first
    STEP_PX threshold crossing, then locked until the next touchstart.
    Horizontal movement still uses the full while-ratchet (tracks finger).
  - Lock delay (55bbc55, closes #1): 250ms grace before a piece commits.
    Each piece carries lockPendingTs + lockResets. Tick: piece that
    can't move forward starts the timer; LOCK_DELAY_MS later (or sooner
    if the timer is bumped into the past), the lock commits. Successful
    human input during the window refreshes the timer up to
    MAX_LOCK_RESETS=5 times then caps (prevents infinite spin). AI
    moves do not reset. Hard drop bypasses the grace by pre-aging the
    timer to LOCK_DELAY_MS in the past. Constants:
    LOCK_DELAY_MS=250, MAX_LOCK_RESETS=5.
  - Mobile dvh viewport (f1ffe21): html/body/#root now use 100dvh
    (dynamic viewport height) with a 100vh fallback. Fixes a visible
    black bar at the bottom of the app on iOS Safari where the
    height: 100% layout viewport was excluding the home-indicator
    zone. viewport-fit=cover meta tag unchanged. FullscreenGame
    recalc still measures root.clientHeight so scale picks up the
    larger dvh automatically on URL-bar show/hide.
  - Per-level fall speed (5c16db7): AI_LEVEL_CONFIG now carries tickMs
    per level: 1=600, 2=440, 3=320, 4=220, 5=140. ~1.5x faster per
    level, 4.3x speedup L1->L5. Tick useEffect deps include
    state.aiLevel so the interval rebuilds when level changes on the
    start screen. TEST_SPEED override (110ms) preserved.
  - Local-player boundary indicator (265393f): single +N/-N number
    rendered only from the LOCAL player's perspective (no opponent
    indicator). Persistent while boundary != BDY_2P. Vertical line
    anchors at originY and extends to boundaryY. Number = abs gap from
    origin in rows. Color: white if local ahead, red if local behind.
    Text sits at the live boundary on the local player's territory side.
    lastGain state retained for haptics, no longer drives this visual.
  - Stack follows boundary (8299027): on territory shift the gainer's
    entire locked stack translates with the boundary instead of being
    decoupled. delta>0 (P1 gain) shifts every CELL_P1 up by delta;
    delta<0 (P2 gain) shifts every CELL_P2 down by |delta|. Loser
    cells in the swept range and any winner cells that would shift
    off-board are dropped. Active pieces are NOT translated; existing
    active-piece eviction respawn handles the rare case where the
    boundary moves past an active piece.
  - Two-boundary visual (e1c4122): ORIGIN dashed lines (rgba 0.7, 2/2
    pattern, no animation) drawn at the fixed midpoint PLAY_Y + BDY_2P *
    CELL alongside the LIVE boundary (rgba 0.4, 4/4 pattern, 260ms
    cubic-bezier animation). The gap reads at a glance: live above
    origin = P1 ahead, live below = P2 ahead, overlap = neutral.
    Constants: ORIGIN_DASH_COLOR, ORIGIN_DASH_SEG=2. Render order:
    origin stacked AFTER live so origin wins z when both share a y.
  - Active-piece eviction on boundary shift (3b0b7ad): after the
    locked-cell sweep, both p1 and p2 active pieces are tested against
    the new boundary via isValid2P. If invalid (piece would sit in the
    other player's territory), the piece is respawned from the NEXT
    queue at its natural spawn position. Fixes a regression where
    pieces sitting at the boundary edge during a shift got locked in
    the wrong territory on the next tick.
  - Boundary eviction + indicator lockstep (30bd2cb): dropped the
    preventive piece-blocking clamp on newBdy. The boundary now slides
    freely to its calculated position; any loser cells in the swept
    range are evicted in the same paint, so the dashed boundary line
    visibly traverses them over the 260ms ease-out. `lastGain` is now
    computed from realShift = boundary - newBdy (after game-over
    clamps), so +N/-N only fires when the line actually moves and the
    row count matches the cells visibly traversed.
  - Loss indicator (5cd9903): paired with the existing "+N" gainer
    indicator, "-N" now also renders on the LOSING player's side of the
    boundary in subtle warning red (rgba(255,110,110,0.7)). Driven by the
    same `lastGain` state; same GAIN_FADE_MS (1500ms) lifetime; mirrored
    across the boundary line. Boundary slide animation already in place
    via BoardViewport `transition: top 260ms cubic-bezier(0.22, 1, 0.36, 1)`
    (animateBoundary prop passed from TetrisGame2P).
  - Haptics (cdb6b6a): module-level `haptic` helper with light/medium/heavy/
    gameOver methods. Each wraps `navigator.vibrate` in a feature check +
    try/catch, fails silently on iOS Safari, swap target for
    @capacitor/haptics in v3. Wiring:
    move/rotate -> light (30ms) inside applyP1/applyP2 on every successful
    input; piece lock -> medium (60ms) gated on HUMAN side's piece-type
    change; row clear + territory shift -> heavy (100ms); game over ->
    pattern [200, 100, 200].
  - P1_LOCKED_COLOR "#b1b2b3" (bright). P2_LOCKED_COLOR "#4a4a4a" (dark, fully opaque). Human player always renders as bright regardless of side chosen; AI always renders dark. cellColor map computed at render from playerSide state.
  - GHOST_COLOR "rgba(177,178,179,0.075)". LANE_COLOR "rgba(255,255,255,0.10)". Both rgba for background-agnostic theming.
  - APP_BUILD_DATE constant (ISO datetime string). relTime() helper renders as "Xs ago / Xm ago / Xh ago / Xd ago / Mon D / Mon D, YYYY". Version stamp: font 12, flex space-between, build date on right.
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
