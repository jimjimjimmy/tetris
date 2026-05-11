# Tetris Game - Ideas & Future Features

---

## Territorial Decay (implemented, TetrisGame2P)

Each row cleared is worth slightly less territory over time. Prevents death spirals
and keeps matches at a comfortable pace without favoring either player.

**Final tuned values (in `preview/index.html` constants block):**
- `DECAY_RATE = 0.05`
- `MIN_SHIFT  = 0.25`

**Curve:** `shift = max(MIN_SHIFT, 1 / (1 + DECAY_RATE * priorClears))`
- Clear  0 -> 1.000 row
- Clear  5 -> 0.800
- Clear 10 -> 0.667
- Clear 20 -> 0.500
- Clear 40 -> 0.333
- Clear ~60 -> hits MIN_SHIFT floor (0.250)

**Accumulator model:** each player has a fractional `pXShiftAcc` that
collects sub-row contributions. Each tick, the integer part drains into the
boundary; the fractional remainder carries forward. P1 push UP, P2 push DOWN.

**Verified (TEST_SPEED=true, 60s run):** Match length grew from 24.6s (pre-decay)
to 35s. Final tally P2=15 clears / P1=2 (vs P2=10 / P1=0 before). Early clears
moved ~1 row each, late clears took ~2 clears per row. No death spiral.

---

## Power Pieces / Special Mechanics (pin for later levels)

- **Pac-Man power pellet equivalent** - a special piece that when used to clear
  a row, steals 2-3 rows from opponent at once. Short window of dominance.
  Gives losing player a fighting chance.

- **Blue shell equivalent** - a one-time weapon that specifically targets the
  leading player. Triggers when score gap exceeds a threshold.

- **Other level modifiers TBD** - mechanics that add pizazz at higher levels
  or unlock as game progresses.

---

## Wind (confirmed future mechanic)

Horizontal drift applied to pieces as they rise/fall. Direction changes
periodically. Adds chaos and strategy.

Wind indicator UI showing direction and strength.
Planned for after core 2-player mechanic is solid.

---

## Difficulty Levels (confirmed)

- Easy: AI makes occasional intentional mistakes
- Medium: AI plays competitively
- Hard: AI plays near-optimally

Difficulty selection screen needed before v2.

---

## Polish (Phase 5)

- NEXT piece preview (partially implemented)
- Ghost piece (faint outline showing where piece lands)
- Lock delay (brief grace period before piece locks)
- Sound: minimal, single oscillator beeps, no audio files

---

## Multiplayer (v2)

- Random matchmaking (anonymous or named)
- Friend match via room code
- Computer fills empty slot instantly if no human opponent found

---

## iOS (v3)

- Gesture controls: swipe left/right to move, tap to rotate,
  swipe up/down for buoyancy boost
- Capacitor wrapper
- App Store assets (icon, splash, screenshots)
- Game Center integration
