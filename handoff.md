# Handoff - RVAL / Tetris (jimjimjimmy/tetris) - 2026-08-02

## What this is

RVAL - two-player territorial Tetris, Capacitor iOS wrap. This session (on
Gandalf, working from the Dropbox copy at `~/Dropbox/04 Projects/AI Shared/Tetris`,
builds run from `~/Developer/tetris`): built a full "Drift" prototype feature
(solo-only, Settings > Game > Drift, default OFF) end-to-end - board/piece
wraparound mechanic, parallax starfield, several rounds of bugfixes from live
device testing, and a screen-transition timing increase + consolidation
refactor. All work is on branch `feature/drift-cylinder`, NOT merged to `main`.

## Current state

**Working and verified (live device + browser testing throughout):**
- Drift mechanic: the whole shared board (locked stack + both active pieces)
  scrolls one column every 2.2s and wraps at the seam (col 9 <-> col 0,
  Pac-Man style, true straddling mid-crossing - not a teleport).
- Player input (left/right/rotate/hard-drop/soft-drop) stays responsive while
  a piece is near or crossing the seam - this took a second bugfix pass after
  on-device testing surfaced it (see commit `2ff016b`).
- Gravity/lock, AI rotate/slide stepping, boundary-eviction-on-line-clear, and
  the ghost-piece preview are all wrap-aware too - each was a separate bug
  found via on-device "glitchy" reports and fixed one at a time (`34b85b3`).
- Parallax starfield (two layers, random scatter via seeded PRNG -> SVG
  data-URI background, NOT a repeating CSS tile - the first version looked
  like a visible grid and was rejected) behind the board AND on the start
  screen (both Single + 2 Players tabs), all gated on the same Drift toggle.
- Screen-transition slide+fade (Settings, Instructions, both start tabs,
  online/join-code screen) distance increased to 2.5x original, duration to
  2x original, and CONSOLIDATED into shared constants so a future retune is a
  2-4 value edit instead of hunting down 7+ call sites.

**Known non-issue explained, not a bug:** mid-session, one duration edit only
landed on the "Single" start-screen tab's `di()` and silently missed the
"2 Players" tab's near-identical block (they're NOT a shared component -
two separately-written blocks that differ only in indentation, documented as
intentional in CLAUDE.md). Caught and fixed same session; also root-caused
the user's EARLIER report ("2 players updated, main screen didn't") to this
exact same class of bug from an even earlier edit. The consolidation refactor
should prevent this recurring.

**Untested / pending decision - App icon:** an updated app-icon PNG was
dropped in `assets/App Icon.png` and flattened (alpha stripped) into
`ios/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png` in BOTH
clones, but deliberately left UNCOMMITTED - user is still testing it on
device. Flagged TWICE that the source image looks like it's cropped from a
repeating tile (content cut off at the left and/or right edge in both
versions provided so far) - this will likely look broken once iOS masks it
small with rounded corners. Do not commit until the user confirms a version
that reads as a clean, self-contained mark.

## Files changed this session

| File | Status | What changed |
|------|--------|-------------|
| `preview/app.jsx` | committed (many commits, `feature/drift-cylinder`) | Drift mechanic, wrap-aware collision/AI/eviction/ghost, starfield generator + both render sites, transition constants (`TRANSITION_MS`/`TRANSITION_SLOW_MS`), player-input wrap fixes |
| `preview/app.js` | committed | Rebuilt output, paired with every `app.jsx` commit per repo convention |
| `preview/index.html` | committed | `driftStarsFar`/`driftStarsNear` keyframes, transition keyframes + `--transition-dist`/`--transition-dist-slow` CSS custom properties |
| `ios/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png` | **UNCOMMITTED** in both clones | Test app icon (flattened, alpha stripped) - see "pending decision" above |
| `assets/App Icon.png` | untracked | Source of the test icon, user-provided, current version has the same "cropped tile" concern as the first |
| `store-screenshots/6.5-display/02-countdown.png`, `03-keypad.png` | untracked | Pre-existing, unrelated to this session, never touched |

## Uncommitted work

Only the app icon (see above). Everything else from this session is
committed and pushed to `origin/feature/drift-cylinder` (HEAD: `bfc90ea`).

## Open questions / decisions pending

1. **App icon**: does the user want to crop/recenter the source image so it
   reads as one self-contained mark before it ships, or are they fine with
   the cropped-tile look? Flagged twice, not yet answered either way.
2. **`feature/drift-cylinder` -> `main`**: this entire Drift feature (11+
   content commits) has not been merged. Confirm with the user before merging
   - it's a solo-only prototype behind a default-OFF toggle, so it's low risk,
   but merge timing is the user's call.
3. **`main` has moved independently**: `origin/main` is 18 commits ahead of
   where `feature/drift-cylinder` branched (App Store screenshots, etc. - see
   `ce78580`, `b045c8c`). Any future merge should account for that drift.
4. **Online/multiplayer sync for Drift**: explicitly out of scope this whole
   session (user chose "single-player first" early on). If Drift ever needs
   to work in networked 2P, that's unstarted - would need boundary/piece sync
   extended to cover the drift tick too.

## What to do next

1. Wait for the user's verdict on the app icon (cropped-tile concern) before
   committing it.
2. If/when they approve an icon, commit it as its own small commit (source
   PNG + the flattened xcassets PNG), separate from the Drift feature commits.
3. Ask the user whether `feature/drift-cylinder` should be merged to `main`
   yet, or stay as a branch for more testing first.
4. No other loose ends from this session - Drift + starfield + transitions
   are all committed, pushed, and synced into the Developer build clone.

## How to resume

```bash
cd ~/Developer/tetris   # the actual build clone - NEVER build from Dropbox
git status --short      # confirm the app-icon PNG is still the only uncommitted diff
git log --oneline -1    # should show bfc90ea (or later) on feature/drift-cylinder
git branch --show-current  # should show feature/drift-cylinder
```

To pick up editing from the Dropbox copy (where this session ran):
```bash
cd "/Users/jimmy/Dropbox/04 Projects/AI Shared/Tetris"
git pull
npm run build   # only if you edit preview/app.jsx - see CLAUDE.md's REQUIRED stamp workflow
```

To test on device: open `~/Developer/tetris/ios/App/App.xcodeproj` in Xcode,
select Shadowfax, Run. Settings > Game > Drift (default OFF) turns on both
the board mechanic and the starfield.

## Machine / account notes

- Generated on **Gandalf**, working from the Dropbox copy
  (`/Users/jimmy/Dropbox/04 Projects/AI Shared/Tetris`) for edits, with
  `~/Developer/tetris` as the actual build clone (per CLAUDE.md convention).
  Both clones are in sync as of this handoff except for the uncommitted app
  icon, which exists identically (uncommitted) in both.
- Personal repo; push with the explicit token form:
  ```bash
  GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
  git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" feature/drift-cylinder
  ```
- Every `app.jsx`-touching commit this session followed the repo's REQUIRED
  two-commit stamp pattern (content commit -> copy hash -> bump
  `APP_COMMIT`/`APP_BUILD_DATE` -> rebuild -> second commit). Current stamp:
  `bfc90ea` is the bump commit; `APP_COMMIT` in code reads the content commit
  one behind it (`415dff7`), which is the documented convention, not a bug.
