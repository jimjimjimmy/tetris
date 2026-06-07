# DRIFT — Recurring Smoke Test Plan

**Setup:** Enable `DEBUG_PIECES = true` in the code before running (set back to `false` before push).
- **BAR piece (10×1)** — one drop fills and clears an entire row. Use for single-row boundary tests.
- **5×1 bar** — two drops complete a row. Use for partial-row / two-piece tests.
- BAR overflows the NEXT preview strip slightly — expected in debug mode only.

Run each scenario at least **3 times**. Flag anything that fails or feels inconsistent across runs.

---

## 1. Boundary & Counter

> **Root cause fixed (`0a3b9ef`):** The old `decayShiftAt` system returned decimals (0.952, 0.909…) that accumulated but `Math.floor()` only consumed whole integers — so +1→+2 needed 2 clears to cross 1.0. Replaced with simple `newBdy = boundary - n1 + n2`. All 10 transitions verified.

- [ ] neutral → +1 (boundary 22 + P1 clear)
- [ ] +1 → +2 *(was 2-clear bug — fixed)*
- [ ] +2 → +3, +3 → +4 — each one clear
- [ ] neutral → -1
- [ ] -1 → -2 *(mirror of bug — fixed)*
- [ ] -2 → -3 — each one clear
- [ ] +1 → 0 (return to neutral)
- [ ] -1 → 0 (return to neutral)
- [ ] Direction switch mid-game (e.g. at +2, P2 clears → +1)
- [ ] Simultaneous 2-row clear at +1 → +3 (not +2)
- [ ] Boundary at min (1) — no crash, P1 wins
- [ ] Boundary at max (43) — no crash, P2 wins
- [ ] Only local player's indicator visible — opponent's never renders
- [ ] Indicator always visible during active boundary change
- [ ] No indicator at neutral

---

## 2. Physics

- [ ] All 7 piece types spawn correctly
- [ ] Rotation all 4 directions per piece type
- [ ] Wall kick — rotate against left wall
- [ ] Wall kick — rotate against right wall
- [ ] Hard drop locks on next tick
- [ ] Soft drop moves one row per swipe (P1: swipe-down, P2: swipe-up)
- [ ] Soft drop only works WITH gravity — P1 swipe-up does nothing, P2 swipe-down does nothing *(bug: currently allows dragging against gravity)*
- [ ] Lock delay — piece does NOT lock immediately on landing
- [ ] Lock delay — slide/rotate during 250ms window works
- [ ] Lock delay — resets up to 5 times then locks (no infinite stalling)
- [ ] Line clear flash appears at correct row position (100ms white overlay)
- [ ] Next piece spawns only after line clear animation completes
- [ ] NEXT queue shows correct upcoming pieces (2-deep)
- [ ] Spawn position correct for all piece types

---

## 3. Levels

- [ ] L1 feels slow / beginner pace (600ms tick)
- [ ] L2 feels noticeably faster than L1 (440ms tick)
- [ ] L3 moderate (320ms tick)
- [ ] L4 fast (220ms tick)
- [ ] L5 feels expert / snappy (140ms tick, ~4.3× faster than L1)
- [ ] Speed delta between levels is consistent — not front-loaded or flat
- [ ] Speed updates immediately when level changes mid-game

---

## 4. Multiplayer & Edge Cases

- [ ] Both players clear rows simultaneously — boundary resolves correctly
- [ ] One player tops out — game ends, correct winner shown
- [ ] Boundary at absolute min (1) — P1 wins cleanly
- [ ] Boundary at absolute max (43) — P2 wins cleanly
- [ ] Pause mid-boundary-shift — state restores cleanly on unpause

---

## 5. UI & Visual Consistency

- [ ] Only one boundary indicator on screen at a time
- [ ] White for +N (local player gaining rows)
- [ ] Red for -N (local player losing rows)
- [ ] Vertical bracket anchors at dotted origin line, extends to live dashed boundary
- [ ] Bracket renders correctly in both directions (gaining and losing)
- [ ] P1 indicator appears below the live boundary
- [ ] P2 indicator appears above the live boundary
- [ ] NEXT piece preview renders correctly throughout
- [ ] Full screen — no black bar on iOS (safe area covered)

---

## 6. Wind *(add when implemented)*

- [ ] TBD

---

## Changelog

| Date | Version | Notes |
|------|---------|-------|
| 2026-05-26 | v0.1 | Initial plan — covers boundary, physics, levels, multiplayer, UI |
| 2026-05-26 | v0.2 | Updated DEBUG_PIECES setup notes (BAR piece, `0a3b9ef`); expanded boundary transitions with root cause note; all 10 transitions verified |
| 2026-05-26 | v0.3 | Added soft drop direction bug to physics section |
