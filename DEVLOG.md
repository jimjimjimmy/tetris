# DEVLOG - DRIFT

A development journal covering the full build history of DRIFT: a two-player
mobile Tetris game with shared board, territorial mechanics, and a long-term
vision for becoming a communication app.

This document is a narrative, not a changelog. It covers what was built, why
decisions were made, what was tried and abandoned, and what was learned.

---

## The Idea

The project started with a concept that is more social than game: two people
share one board, each fighting to hold their territory. Clear rows and the
boundary line shifts in your favor. Lose rows and you lose ground. First to
squeeze the other player to zero wins.

The physics flip is the key detail. P1 plays from the bottom and pieces float
UP. P2 plays from the top and pieces fall DOWN. Both players are fighting
toward the center boundary line, each with natural gravity working against
them. The name DRIFT came from the idea of pieces drifting, of two people
drifting toward each other or apart.

The long-term concept is bigger: this becomes a communication app where you
earn video call time by playing. Lose territory, lose chat time. Win, extend
the call. The game IS the conversation. But that is a v3 problem. The v1
goal was a single-file, no-bundler, mobile-first 2P game that actually works.

---

## Chapter 1: Scaffold and First Principles (May 4)

**Commits: c7d90ff, e6886c6, f94749d**

The project started with a project scaffold: CLAUDE.md, BUILD-PLAN.md,
COMPONENT-INDEX.md, and a storybook. The first real decision was the tech
stack: React 18 via CDN, Babel Standalone for in-browser JSX transforms,
no bundler, no build step. Single HTML file. This was a deliberate choice
to keep the development loop as fast as possible. Open the file in a browser,
iterate, no npm install, no webpack.

The v1 spec was written out in full before any code. Key decisions documented:
- Shared board, one grid, one truth
- P1 floats up (buoyancy), P2 falls down (gravity)
- Wind as a future mechanic, real-world weather data
- Territorial tug-of-war as the core loop
- Win condition: push opponent to zero rows

The first game commit (0cacde5) was a rough proof of concept: gravity,
buoyancy, wind, boundary stealing. It barely worked but established the
core idea was implementable.

---

## Chapter 2: The Physics Problem (May 4-6)

**Commits: 40f71df, 0322369, 61819ed, 8d0858b, 31c4f5c, 97d5dd6, 7596122**

The first real technical problem was physics. P2 floats up - but Tetris
physics is built on gravity. Every collision check, every row clear, every
stack assumes pieces fall. Flipping P2 means every function needs a mirrored
version. `isValid` becomes `isValidP2`. `clearRows` becomes `clearRowsP2`.
Row insertion direction flips. Stack anchors flip.

The early builds tried to share physics code between P1 and P2 with a
direction parameter. That approach collapsed under the complexity. The final
architecture was two completely symmetric but independent sets of physics
helpers: one for each player. More code, but zero shared-state bugs.

During this period the visual layout also went through several passes. Early
versions had split viewports - each player sees only their half. That was
abandoned quickly because you lose the crucial information: you cannot see
where your pieces are landing relative to the boundary unless you can see
the boundary. The shared full-board view was the right call.

A Figma-based reskin was also started during this period (7596122: Match
Figma exactly, 38px cells, 402px frame). The visual identity was being
established in parallel with the mechanics.

After a few days of iteration, the physics were stable enough to move
forward but the whole component had become a mess. A clean reset was needed.

---

## Chapter 3: The Reset (May 10)

**Commits: 21547a7, cd8c75f, 158b7ce, 01d0c51**

The codebase was reset to a clean single-player 180-degree Tetris foundation.
This sounds like a step backward. It was not. The reset let the AI be built
and tested in isolation, without the complexity of the 2P system. A smart
placement evaluator was written from scratch: the AI tries every combination
of rotation and column position, simulates the landing, and scores each by
line clears, row density, height penalty, hole penalty (buried empty cells),
and bumpiness (column height variance). The best move wins.

This AI would later become both P1 and P2 in the 2P game. Having it proven
correct in a simple environment first prevented a whole class of bugs later.

TEST_SPEED mode was also added here: a flag that drops tick speed to 110ms
(5x fast). You can watch 60 seconds of gameplay in 12 seconds. This became
indispensable for testing the 2P boundary mechanic.

---

## Chapter 4: Building TetrisGame2P (May 10-11)

**Commits: db1b6a9, 9f11bb5, 9635e0d, 633857e, feb08d4, b40cb8d, 0bceef9, 2eccbff, 42f9994, 2aa8364, c5ae646, 694f3b7, 84582db, 8034100, ae31b6e**

TetrisGame2P was built in a rapid burst over two days. The approach was
additive: start with the single-player foundation, add P2 as a symmetric
mirror, then add the boundary shift mechanic.

The first major problem was spawn asymmetry. P1 spawned at row 29
(near the floor), giving it a long fall before locking. P2 spawned at
row 0, very close to the boundary. The cycle time difference was 2.86:1.
P1 was playing a slower game just because of where it started. The fix
was symmetric spawning: both players spawn with the same piece-travel
distance to the boundary, measured from their respective edges.

The second problem was AI repositioning. The early AI moved the piece to
its target position in one tick via a while-loop: all rotations and slides
happened instantly. This read as a teleport. The fix was single-step
repositioning: one rotation OR one slide per tick, then fall one row.
Pieces now visibly travel across the board.

The boundary shift mechanic introduced a hard problem: what happens when
the boundary moves through locked cells? Early versions had pieces
disappearing, overlapping, or getting stranded. Multiple passes were needed:

1. First: evict the loser's cells in the swept range
2. Then: translate the gainer's locked stack with the boundary
3. Then: respawn any active piece that the shift invalidated
4. Then: remove the "preventive clamp" that was blocking shifts
   and instead let the boundary slide freely, with eviction happening
   in the same paint

Each of these was a separate discovery. The final architecture was
verified with three rounds of testing: code audit (line-by-line symmetry
check), runtime probe (tick interval sampling to verify exactly 1 row per
tick in opposite directions), and six screenshots over 60 seconds at
TEST_SPEED. P1 and P2 ended up at 51 vs 49 total clears across four games.
Symmetry achieved.

**Territorial decay** was added and then removed. The idea was that early
clears were worth more territory than late clears, preventing death spirals.
It worked mathematically but introduced a fencepost bug: the second clear's
contribution sometimes got stuck below the floor value and triggered a +2
instead of +1 shift. After several attempts to fix the accumulator logic,
decay was removed in favor of clean 1:1 boundary shift. Each cleared row
moves the boundary by exactly one. Simpler, debuggable, fair.

---

## Chapter 5: The Mobile Game Shell (May 11-16)

**Commits: cda0634, 90b5a25, 7a5fe15, e5acf50, fb37d9f, 2b1863c, 264183d, f915bf1, f1c30af, 8d9030a, 5576eeb, 2b4f021, 7e2e57e, 78f53cd, b7fed03, c0c9d30, 11d67d0, 9f466c9, 5447375, 76fa205, 2a176e4, f9948c5**

game.html was created as a dedicated mobile entry point. The storybook
(index.html at the time) served as a component browser; game.html was
the actual game.

iOS added its own layer of problems. The notch and home indicator ate into
the layout. `env(safe-area-inset-*)` fixed the content; `viewport-fit=cover`
fixed the status bar. But `height: 100%` on iOS Safari does not include the
home indicator zone, leaving a black bar at the bottom. `100dvh` (dynamic
viewport height) fixed that.

The status bar was another issue. iOS Safari overlays the game with its own
status bar UI. The fix was to make the status bar itself part of the design:
extend the background behind it using `viewport-fit=cover`, compensate for
the status bar height with `env(safe-area-inset-top)`.

The visual was being pulled from Figma throughout this period. Multiple
passes were made to match the design exactly: grid alignment, gradients,
opacity model, background gradients, the boundary indicator overlays
(brackets, +N text, dashed lines). The first Figma reskin happened around
May 14 (e5acf50). The gradient was particularly tricky because iOS Safari
renders gradients differently than Chrome. A compensation layer was needed
for Safari.

The start screen was added around May 16. Players choose their side - play
as P1 (bottom, floats up) or P2 (top, falls down). The start screen also
introduced the AI difficulty slider. Touch handler re-attachment on game
start was a bug that needed fixing: the gesture listener was being lost
when the start screen mounted.

---

## Chapter 6: Ghost Piece and Gesture Ratchet (May 20-21)

**Commits: daeeefc, a76c713, d525053, d8fbad3, af3d4d8, b10f28c, 94b2620, 7d1cb23, 887381d**

Two ergonomics features shipped in quick succession: the ghost piece
(a faint outline showing where the current piece will land) and
the discrete-swipe ratchet for horizontal movement.

The ratchet was important. Without it, touch gestures fired continuously
during a drag and moved the piece too fast. The solution: STEP_PX=30
as a threshold. The piece moves one column every 30px of finger travel.
Slow swipe = one column move. Fast swipe across the board = many columns.
Predictable, controllable.

The ghost piece opacity was iterated several times: 0.20, 0.15, 0.0375,
0.075. The final value at 0.075 is barely there but visible enough to
be useful. It needs to inform without distracting.

A visual decision was made: human player always renders in bright (#b1b2b3)
regardless of which side they choose. The AI always renders in dark
(#4a4a4a). Color communicates role, not position. This makes it
immediately clear who is you and who is the machine.

Column lane indicators were added: faint vertical dashes spanning each
column from boundary to territory edge. They read as the "lanes" the
pieces fall through, reinforcing the game's spatial logic.

The North Star concept was documented in the codebase at this point
(fde41ca). A real record of the vision: communication app, earn video
call time, the board as a metaphor for relationship distance.

---

## Chapter 7: Haptics and Gesture Surface (May 22)

**Commits: cd3ae0a, cdb6b6a, 5cd9903**

Two practical improvements landed together. The gesture capture surface
was extended to span the full width of the game minus the right sidebar.
Previously, touch events were scoped to the narrow 200px play area. Players
who swiped from outside that zone got no response. The capture div now
spans x=0 to x=320 (SIDEBAR_X), so you can swipe from anywhere on the
left portion of the screen.

Haptic feedback was added via the Web Vibration API. A module-level
`haptic` object with five named moments: piece lock, line clear, boundary
gain, boundary loss, game over. Each scales its pattern by intensity
(light/medium/strong). The API fails silently on iOS Safari because
Apple does not support `navigator.vibrate`. The call sites are already
written; swapping them for `@capacitor/haptics` in v3 requires no
restructuring.

The loss indicator was also added: when the boundary shifts against you,
a -N indicator appears on your side in subtle red. Previously only the
gainer saw a +N. Now both players have feedback about what just happened.

---

## Chapter 8: Boundary Visual System (May 22-24)

**Commits: 30bd2cb, 3b0b7ad, e1c4122, 8299027, 265393f**

The boundary needed two visual layers to communicate its state:

1. The ORIGIN line: a fixed dashed line at the starting midpoint. This never
   moves. It shows where the game started.
2. The LIVE boundary: an animated solid line at the current boundary position.
   It moves with a 260ms cubic-bezier ease when territory shifts.

The gap between the two lines reads at a glance: live above origin means
P1 is ahead, live below means P2 is ahead.

The active-piece eviction problem required a careful fix. When the boundary
shifts, pieces that were sitting near the boundary edge could end up on the
wrong side. The solution was to test both active pieces against the new
boundary after every shift and respawn any that are now invalid. This runs
in the same tick as the boundary move, so there is no frame where a piece
is stranded in opponent territory.

Stack follows boundary was another subtle but important behavior. When you
gain territory, your locked stack shifts with the boundary. Your pieces
do not stay where they were while the boundary moves out from under them;
they slide with it. This keeps the relationship between stack and territory
visually consistent.

---

## Chapter 9: The Polish Sprint (May 26)

**Commits: 55bbc55, be798e9, 4a2080c, 0a3b9ef, 571aaa0, 5c16db7, 265393f, f1ffe21, d18285f, c46b3c3, e82e8ff**

A full session dedicated to feel and correctness.

**Lock delay** (55bbc55): a 250ms grace period before a piece commits.
Each piece carries a timer and a reset counter. Successful human input
during the window refreshes the timer, up to MAX_LOCK_RESETS=5. After
5 resets the piece locks regardless, preventing infinite spin. AI moves
do not reset the timer. Hard drop bypasses grace entirely.

**Soft drop** (be798e9, d18285f): soft drop fires in the natural travel
direction, the same direction the piece moves automatically. An early
version fired it against gravity, which was backwards. Fixed.

**Hard drop** (c46b3c3): hard drop fires on touch lift (touchend), not
during the drag. A 44px deadzone prevents accidental drops from small
finger movements. Horizontal ratchet still fires live during drag.
This separation was important: before this, hard drop and horizontal
movement could fire simultaneously during a diagonal swipe.

**Wall kicks** (4a2080c): rotation tries x-offsets [0, +1, -1] before
failing. First valid position wins. Pieces no longer get stuck against walls.

**Line clear flash** (4a2080c): for 100ms after a line clears, a white
overlay sits over the cleared rows. Subtle visual feedback that something
happened. The flash has a reference-equality guard so a fast second clear
does not cancel the first.

**Boundary indicator status colors** (571aaa0): when the live boundary
is displaced from origin, the indicator elements switch to status colors.
Gain = #2fff00. Loss = #ff0000. Per-element opacities from Figma: live
dash 0.5, bracket cap 0.5, bracket stem 0.15, text 0.5.

**DEBUG_PIECES mode** (0a3b9ef): when enabled, the piece randomizer always
returns BAR, a 10x1 horizontal piece. One BAR drop = one filled row = one
boundary shift. Boundary math is now testable deterministically. Always
off before push.

**Per-level fall speed** (5c16db7): the initial speed curve was too aggressive.
L3 felt expert-fast when it should feel moderate. Curve: 1=900ms, 2=700ms,
3=500ms, 4=320ms, 5=140ms. L3 as the midpoint reference.

---

## Chapter 10: Settings Screen (May 27)

**Commits: c6051c3, 2b929c9, c2f4ff1**

A settings screen was added with three sections: Sound, Haptics, and Game.
All state persists to localStorage so preferences survive app restarts.

Sound and music are stubbed with toggle switches. The actual audio assets
have not been wired yet - this is queued as F1 in DRIFT-DEV.md.

Haptics has a main toggle and an intensity selector (light/medium/strong).
The intensity multiplier scales the vibration pattern durations across all
five haptic moments.

The Game section has the AI level slider (1-5) and side selection (P1/P2).
Settings are read at game start, so changes take effect on the next match.

Gear icon and level shortcuts were added so common settings are accessible
without opening the full settings screen.

---

## Chapter 11: File Rename and Repo Cleanup (May 27)

**Commit: 4c3713c**

The old storybook (index.html at the project root) was deleted. The game
file was renamed from game.html to index.html, which becomes the GitHub
Pages default. This means the live URL simplified from .../preview/game.html
to just .../preview/.

The rename also fixed a latent confusion in the codebase about which file
was THE file. Now it is clear: `preview/index.html` is the game. Nothing else.

---

## Chapter 12: Drift Lane Prototype (May 27)

**Commits: 1e9c291, 0a04d1f, 5c87ec1, ca2ad41, ab4e05b, fdb9d11, aa4ca0a, c685648, 422de1e**

A separate prototype file - `preview/drift-test.html` - was created to
explore what drift lanes actually look like in motion. This is a
pre-production prototype, not production code. It does not go into index.html
yet because the mechanic needs to be understood visually before it is
wired into the game.

The prototype went through several complete architectural rewrites:

**Version 1** (1e9c291): CSS animation-based. Absolute-positioned elements
with keyframes. The problem with CSS animations is they have no awareness
of a beat clock. The drift visual needs to lock to BPM.

**Version 2** (0a04d1f): canvas-based with a real beat clock. BPM constant
at the top, `BEAT_MS = 60000 / BPM`, `requestAnimationFrame` polling, beat
advancing on a timer. This architecture was right. The canvas let everything
be drawn relative to the beat count.

**Version 3** (5c87ec1): grid-line fault model. Instead of filling cells,
the beat-driven highlight was drawn as a disruption of the grid lines
themselves - a gap or pulse at grid intersections. Too subtle. Hard to read.

**Version 4** (ca2ad41): pattern sampler. The prototype became a testbed for
multiple visual pattern types simultaneously: dots at intersections, corner
brackets on moving cells, two dots spaced half a row apart, directional arrows.
Each lane had its own row, beat phase, and travel direction. An 8-lane version
was the first build; it was then refined to 5 focused lanes.

The arrow pattern evolved through text glyphs (fdb9d11: Unicode -> and <-)
and then to the final Arrow.svg asset (c685648). The SVG approach allowed
the arrow to render at full cell fidelity and to rotate 180 degrees for
left-pointing lanes using canvas transform rather than two separate assets.

The beat-driven opacity wave was the core visual insight. Each cell in an
arrow row steps through four opacity levels (20/40/60/80%) on a 4-beat
cycle, with each cell one beat behind its left neighbor. The formula:

    phase = ((beatCount - 1 - col - phaseOffset) % 4 + 4) % 4

The +4 before the modulo handles negative numbers cleanly.
The result is a slow rolling wave of arrows that travels across each row
and staggers diagonally between rows. Very subtle at low opacity,
most visible on beat 4 (the accent beat).

Arrow.svg required stripping its internal opacity layers before the canvas
`globalAlpha` control would work. The original SVG had a `<g opacity="0.8">`
wrapping a `<path opacity="0.15">`, giving 0.12 effective max opacity.
After stripping, `globalAlpha` has full control.

A pause toggle was added for the prototype - both spacebar and a button -
so the animation can be frozen to examine a specific beat state.

---

## Chapter 13: Score Tracking and Match Structure (May 27)

**Commits: aa26d90, f2cbfd8, 8130977**

The game previously had no memory between matches. Win or lose, rematch
starts fresh with no record.

**Best-of-3** (aa26d90): `p1Wins` and `p2Wins` state tracks the session
record. First to 2 wins takes the set. Wins are credited at the moment
the next match starts (REMATCH button tap), so the win is recorded against
the player who won the previous game.

Two overlay states were added:
- Match-over (set not complete): shows winner, current pip count, REMATCH
  and MENU buttons
- Set-over (someone reached 2 wins): shows set winner, final record,
  PLAY AGAIN (reset score to 0-0) and MENU

Pips (filled/empty circles) show the current session score next to the
pause button in the sidebar. They update live during the `phase === "over"`
state to show the tentative new tally before the player confirms.

CSS `@keyframes fadeIn` was added for the overlay entrance. Matches the
DRIFT aesthetic: subtle, no flash.

**Diagonal swipe bug** (f2cbfd8): a swipe intended as a hard drop was also
triggering horizontal movement. The root problem was that `onMove`
(horizontal ratchet) and `onEnd` (drop detection) ran completely
independently. A diagonal gesture would accumulate enough horizontal
delta to fire a column move AND enough vertical delta to fire a hard drop.

The fix was an `axisLock` variable shared between both handlers. When total
travel exceeds LOCK_PX=10, the gesture commits to one axis based on a 2:1
ratio: if vertical travel is 2x or greater than horizontal, it is a vertical
gesture. Otherwise horizontal. Once locked, the other axis is suppressed
for the rest of that gesture.

**Speed rebalance** (8130977): the speed curve was recalibrated so L3
(500ms) represents moderate/average Tetris pace. L1=900ms, L2=700ms,
L3=500ms, L4=320ms, L5=140ms. Same curve shape, just shifted one level
slower so the gradient from casual to expert is more evenly distributed.

---

## Where Things Stand (May 27)

The game is playable, polished, and deployed at:
https://jimjimjimmy.github.io/tetris/preview/

**What is done:**
- 2P shared board with full territory mechanic
- Symmetric physics and AI for both players
- Human gesture controls with axis-lock, deadzone, and discrete ratchet
- Lock delay, wall kicks, line clear flash
- Best-of-3 score tracking across matches
- Settings screen with haptics, sound toggles, level, and side selection
- Figma-matched visual design with boundary indicator system
- iOS fullscreen, safe area, and viewport fixes
- Drift lane prototype in a separate canvas-based testbed

**What is next:**
- F1: Sound FX - piece lock, line clear, boundary gain/loss, game over
- F2: Music - wire after sound
- F8: Drift mechanic - conveyor belt rows, beat-synced, both players affected
- F6: Wind mechanic - real-world weather API
- F5: Online multiplayer - WebSockets, room codes, state sync
- F7: Capacitor iOS build

The drift visual prototype is the active research thread. Once the pattern
language is understood well enough to write the spec, the mechanic will
be built directly into index.html.

---

## Design Principles That Held Throughout

**Single source of truth for the board.** Every cell stores only CELL_EMPTY,
CELL_P1, or CELL_P2. The boundary is not in the board - it lives in
component state. This separation prevented an entire class of bugs where
the visual and the logical boundary diverged.

**Symmetric mirrors, not shared code.** P1 and P2 have mirrored helper
functions. It is more code. It is also correct. Trying to unify the physics
with a direction parameter created subtle bugs that were hard to trace.

**Verify before declaring done.** The symmetry verification involved a
code audit, a runtime probe measuring tick intervals, and six screenshots
over 60 seconds. The willingness to run three rounds of verification
instead of eyeballing it caught real bugs.

**Prototype separately.** The drift mechanic is in a separate file. It is
not in the game until it is understood. The cost of building the wrong
thing into a 2000-line single file is high. Prototyping in isolation is
cheap.

**The design is the thinking.** Every visual pass comes from Figma. Numbers
are measured, not approximated. When something looks wrong, it is wrong.
Match it exactly.
