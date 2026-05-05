# Tetris — Project Context

<!--
  IMPORTANT: KEEP THIS FILE CURRENT
  Whichever machine (MacFQ or Gandalf) adds a component, updates a file,
  or makes a structural change: update this file before ending the session.
  Both machines depend on this as the single source of truth.
  Last updated: 2026-05-04 — MacFQ (setup)
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

**Tetris** — [describe the project here once scope is defined]

No bundler, no build step. Single HTML file rendered by Babel CDN in the browser.

## Key file

```
preview/storybook.html   <- THE file. All components live here.
                            Never create separate standalone preview files.
```

Live URL: https://jimjimjimmy.github.io/tetris/preview/storybook.html

## Folder structure

```
preview/storybook.html      <- storybook (design QA)
components/                 <- engineering deliverables (.jsx per component)
  tokens.js                   design tokens as JS exports
  icons.jsx                   all Icon* components
assets/icons/               <- SVGs exported from Figma
BUILD-PLAN.md               <- project roadmap
COMPONENT-INDEX.md          <- engineering reference with Figma node IDs
CLAUDE.md                   <- this file
```

**Rule:** `components/` and `assets/` are parallel engineering deliverables. New components go into storybook.html first, then get extracted to `components/` separately.

## GitHub - Two-remote setup

| Remote | Repo | Purpose |
|--------|------|---------|
| `origin` | `https://github.com/jimjimjimmy/tetris.git` | Personal dev - push here first |

### Initial setup (one time, already done)
```bash
git remote add origin https://github.com/jimjimjimmy/tetris.git
```

### Push commands (two-account setup - ALWAYS use explicit token)
```bash
GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
```

> Note: this machine has two GitHub accounts (jimjimjimmy personal + JimmyChe_floqast work).
> Always use the explicit token form above or git will use the wrong account and get a 403.

### Ongoing workflow
```bash
git add .
git commit -m "your message"
# then use the explicit push command above
```

---

## Architecture

### Stack
- React 18 (UMD CDN)
- Babel Standalone 7.23.9 (in-browser JSX transform)
- Inter font (Google Fonts)
- `<script type="text/babel">` - all code is JSX inside this single tag

### Design tokens - T object (fill in from Figma)
```js
const T = {
  // Populate from Figma once design file is established
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
- Before building any component: read exact type specs from Figma info panel for every
  text element (fontSize, fontWeight, lineHeight, letterSpacing). No guessing.

---

## Cross-machine collaboration (MacFQ + Gandalf)

- **MacFQ** = FloQast MacBook (Jimmy's work machine)
- **Gandalf** = other machine
- Files live in Dropbox: `~/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris/`
- Dropbox handles live file sync between machines
- Git is the source of truth for committed state - push at end of every session

### Handoff rules
1. **Update this CLAUDE.md** whenever you add a component, rename a file, or change the architecture.
2. **Never create standalone HTML preview files** - all components go into storybook.html.
3. **Push to GitHub** at the end of every session so both machines are on the same commit.
4. **Don't assume the other machine's session history** - write CLAUDE.md as current facts.

---

## Current components

### Getting Started
- `Placeholder` - replace with first real component

---

## Memory

User preferences: `~/Dropbox/04 Projects/AI Shared/memory/MEMORY.md`
