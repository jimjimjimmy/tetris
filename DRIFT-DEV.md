# DRIFT - Dev Plan

Last updated: 2026-05-27

---

## Project Info

- **Repo:** https://github.com/jimjimjimmy/tetris
- **Live game:** https://jimjimjimmy.github.io/tetris/preview/game.html
- **Storybook:** https://jimjimjimmy.github.io/tetris/preview/index.html
- **Local:** http://localhost:3000/preview/game.html
- **Current commit:** 4a2080c

---

## Roadmap

### v1 - Single device 2-player (current)
Core game is complete and playable. P1 floats up, P2 falls down, boundary shifts on line clears.

| Phase | Item | Status |
|-------|------|--------|
| Foundation | Board, boundary, block rendering, piece set | Done |
| Physics | Gravity, buoyancy, collision, row clear, boundary shift, win condition | Done |
| Controls | Swipe gestures, hard drop, rotate, soft drop | Done |
| Game loop | Piece queue, NEXT preview, game start/over, rematch | Done |
| Polish | Lock delay, wall kicks, line clear animation, sound FX placeholder, haptics placeholder | Done |
| Visual | Boundary indicator (green/red), dashed boundary line, full screen iOS fix | Done |
| Settings | Sound FX, music, volume, haptics, intensity, level, side | Done |
| Debug | DEBUG_PIECES mode (BAR 10x1 piece), TEST_SPEED flag | Done |

### v2 - Polish + Features

| # | Item | Notes | Status |
|---|------|-------|--------|
| F1 | Sound FX | CC0 assets: piece lock, line clear, boundary gain/loss, game over. Sources: Freesound.org, OpenGameArt, Kenney.nl | Pending |
| F2 | Music | Wire after sound FX. Toggle in settings. | Pending |
| F3 | Score / win streak tracker | Session only, no persistent leaderboard yet | Pending |
| F4 | Game-over / rematch screen | Winner display, session record, rematch + menu options | Pending |
| F5 | Online multiplayer | Two devices, WebSockets/Supabase, room codes, state sync, latency handling | Future |
| F6 | Wind mechanic | Real-world weather API. See GAME-IDEAS.md for full spec. | Future |
| F7 | Native iOS / Capacitor build | Wrap existing web app. Requires Xcode 26+, Apple Developer Program ($99/yr). Native haptics via @capacitor/haptics -- call sites already wired. | Future |
| F8 | Drift mechanic | Conveyor belt rows/columns. See GAME-IDEAS.md for full spec. | Future |

### v3 - Native iOS

| Item | Notes | Status |
|------|-------|--------|
| Capacitor build | F7 above | Future |
| Native haptics | Swap navigator.vibrate() for @capacitor/haptics. Call sites already wired. | Future |
| App Store assets | Icon, splash, screenshots | Future |
| Game Center | Leaderboards, achievements | Future |

---

## Bug Tracker

| # | Description | Notes | Status |
|---|-------------|-------|--------|
| ~~B1~~ | ~~Soft drop works against gravity~~ | ~~Gesture must only work WITH gravity~~ | ~~Won't fix for now~~ |
| B2 | Boundary line poking out on right | Small segment extends past right edge of play area. Should clip at play area boundary. | Pending |
| ~~B3~~ | ~~Soft drop speed tied to swipe speed~~ | ~~Should be fixed 1 row per swipe regardless of velocity~~ | ~~Won't fix for now~~ |

---

## Shipped (recent commits)

| Commit | Description |
|--------|-------------|
| 4a2080c | Wall kicks + line clear flash -- closes #3 #4 |
| be798e9 | Soft drop on backward gesture -- closes #2 |
| 55bbc55 | Lock delay 250ms grace before piece commit -- closes #1 |
| 571aaa0 | Boundary visual polish (green/red, opacity, bracket) |
| f1ffe21 | Full screen fix -- no black bar on iOS |
| 0a3b9ef | Boundary counter fencepost fix + DEBUG_PIECES mode |

---

## Rules & Conventions

- No em-dashes anywhere -- pre-commit hook blocks commits containing them
- Every game.html commit MUST update APP_COMMIT (short hash) and APP_BUILD_DATE (local time, never UTC)
- DEBUG_PIECES must be false before every push
- TEST_SPEED must be false before every push
- Always push with explicit token:

```bash
GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
```

---

## Changelog

| Date | Version | Notes |
|------|---------|-------|
| 2026-05-04 | v0.1 | Initial build plan |
| 2026-05-26 | v0.2 | v1 complete; bug tracker added |
| 2026-05-27 | v0.3 | Consolidated BUILD-PLAN.md + bug_report.md into DRIFT-DEV.md |
