# Tetris - Project Context

<!--
  IMPORTANT: KEEP THIS FILE CURRENT
  Whichever machine (MacFQ or Gandalf) adds a component, updates a file,
  or makes a structural change: update this file before ending the session.
  Both machines depend on this as the single source of truth.
  Last updated: 2026-05-06 - Gandalf (CELL=40 from Figma, single piece color #B1B2B3, removed grid borders + death line, exact HUD positions from Figma nodes)
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
```

Live URL: https://jimjimjimmy.github.io/tetris/preview/index.html

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
  - ROWS=30, COLS=10, CELL=40, BOARD_PX=400. Frame 402px wide, BOARD_LEFT=1. Boundary fixed at 12.
  - P1 territory = rows boundary..ROWS-1. Boundary is FIXED (no territory shifts on clear).
  - P1 spawns at row ROWS-4=26 (bottom), floats UP (y-1 per tick), stacks near boundary (row 12).
  - Game over = spawn blocked (standard Tetris lose condition).
  - Row clear: full rows in P1 territory removed, remaining rows shift toward boundary (upward). Viewport stays fixed via p1ViewAnchor.
  - P1 viewport: 20 rows starting at p1ViewAnchor (boundary-PEEK=10). p1ViewAnchor clamped to boundary.
  - Auto-AI: smart placement AI. Evaluates all (rot, x) combos via getLandingY + clearRows simulation. Scores by full-row bonus (500) + quadratic density. Moves one step/tick toward best target. AI_PERIOD=1. Clears ~1 row per 12-15 seconds reliably.
  - Controls: arrow keys (left/right/up=rotate/down=drop). No on-screen HUD buttons.
  - Cheat keys: "1" fill+clear boundary row, "2" clear full rows, "3" staircase fill, "0" reset.
  - Layout: P1_VP_Y=0, NEXT_Y=800, GAME_H=874. NEXT strip = 74px (#080808).
  - Cells: 34x34px visible (CELL=40 - 3px padding each side), color #B1B2B3. No grid borders.
  - Boundary visual: 2px semi-transparent white line at boundary row inside BoardViewport.

### Components
- `NextPieceDisplay` - renders upcoming P1 piece using 18px cells. Shows "NEXT" label above.

---

## Memory

User preferences: `~/Dropbox/04 Projects/AI Shared/memory/MEMORY.md`
