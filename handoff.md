# Handoff - RVAL / Tetris (jimjimjimmy/tetris) - 2026-08-03

## What this is

RVAL - two-player territorial Tetris, Capacitor iOS wrap. This session (on
Gandalf): fixed a real tap-target bug, shipped the Drift feature from the
previous session's branch into `main` as v1.1 (build 4), and retired the
old Dropbox / two-machine workflow in favor of a single working copy.

## Current state

**Working and verified:**
- Fixed the reported bug: info/gear icons (and several other icon/text
  buttons) had a 24x24px or smaller tap target with zero padding -- on a
  real device thumb tap this read as "the app does nothing." Audited every
  icon/text button in the app and enlarged hit areas toward Apple's 44pt
  minimum via a padding+negative-margin technique (grows the invisible tap
  target without moving the visible icon/text by a single pixel). Verified
  geometrically (measured DOM rects) and visually (screenshot diff) in the
  browser preview -- zero visual regression anywhere touched.
- Fixed sites: home-screen Info/Gear icons (both Single + 2 Players tabs),
  in-game Info/Gear icons, online-screen Back button, Menu buttons (room-full,
  connection-lost, opponent-paused), Paused screen Resume/Restart/Quit,
  game-over screen's primary/secondary buttons, demo-complete Rematch button,
  and the Settings screen's Volume/Level digit buttons + ON/OFF/Low-Mid-High
  toggles (some of these were as narrow as 9px wide).
- Merged `feature/drift-cylinder` into `main` (23 commits: Drift mode, the
  starfield, screen-transition timing, the tap-target fixes, and the
  approved app icon). Clean merge, no conflicts.
- Bumped version to **v1.1 (build 4)** -- `APP_VERSION` in-app string,
  `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` in the Xcode project.
  Jimmy confirmed this should be a minor bump (Drift counts as a new
  feature even though it ships default-OFF).
- Retired the Dropbox / two-machine workflow. MacFQ is no longer used for
  this project; `~/Developer/tetris` (this clone) is now the ONLY working
  copy -- edit, build, and commit all happen here. Rewrote `CLAUDE.md`
  accordingly: replaced the SINGLE-WRITER handoff protocol and the
  `node_modules`-Dropbox-ignore workaround with a plain single-copy
  convention, keeping the old procedure as a condensed history note in
  case this ever goes multi-machine again.
- The old Dropbox copy (`~/Dropbox/04 Projects/AI Shared/Tetris`) is left
  on disk untouched, per Jimmy's call -- not deleted, just no longer used
  for anything. Do not edit or build from it.

**Not yet done:**
- Nothing has been built to device (Shadowfax) or archived since the merge
  and version bump. All verification this session was in the browser
  preview only.
- `SHOW_BUILD_STAMP` is still `true` (dev default). It MUST be flipped to
  `false`, rebuilt, and committed right before the actual App Store
  archive -- not done yet, intentionally (Jimmy isn't archiving yet).

## Files changed this session

| File | Status | What changed |
|------|--------|-------------|
| `preview/app.jsx` | committed (multiple commits, now on `main`) | Tap-target hit-area fixes (padding+negative-margin) on ~15 buttons; `ICON_HIT_PAD`/`TEXT_HIT_PAD` constants added; `APP_VERSION` bumped to v1.1; `APP_COMMIT`/`APP_BUILD_DATE` stamp bumps |
| `preview/app.js` | committed | Rebuilt output, paired with every `app.jsx` commit per repo convention |
| `ios/App/App.xcodeproj/project.pbxproj` | committed | `MARKETING_VERSION` 1.0->1.1, `CURRENT_PROJECT_VERSION` (build) 3->4 |
| `CLAUDE.md` | committed | Retired the Dropbox/two-machine section; replaced with single-copy convention + condensed history note |
| `assets/App Icon.png`, `ios/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png` | committed (carried over from prior session's branch) | Approved app icon, merged in from `feature/drift-cylinder` |
| `store-screenshots/6.5-display/02-countdown.png`, `03-keypad.png` | committed | Pre-existing screenshots, committed this session at Jimmy's request; unrelated to the other work |

## Uncommitted work

None. Working tree is clean, `main` is fully in sync with `origin/main`
(`4bcbf40`).

## Open questions / decisions pending

1. **Device testing**: none of this session's fixes (tap targets, Drift,
   v1.1) have been verified on Shadowfax yet -- only in the browser preview.
   Should happen before archiving.
2. **Feature branches now stale/mergeable**: `feature/drift-cylinder` and
   `feature/multiplayer` still exist as branches (both local and on
   origin). `feature/drift-cylinder` is now fully merged into `main` --
   safe to delete once Jimmy confirms he doesn't need it as a reference.
   `feature/multiplayer`'s relationship to `main` wasn't checked this
   session.
3. **App Store submission timing**: v1.1/build 4 is ready in the repo, but
   the actual archive/submit hasn't happened. When Jimmy's ready: flip
   `SHOW_BUILD_STAMP` to `false`, rebuild, commit, archive, then flip back
   to `true` afterward (see CLAUDE.md's "REQUIRED additional step before an
   App Store archive").
4. **Old Dropbox copy cleanup**: left on disk untouched at Jimmy's request
   ("leave it as-is, just stop using it"). He said he'd delete it manually
   later -- not blocking anything.

## What to do next

1. Start the next session rooted directly in `~/Developer/tetris` (not the
   Dropbox `AI Shared` folder) -- Jimmy specifically wants this so there's
   no more manual `cd`-ing for Tetris work.
2. Build to Shadowfax and smoke-test: the Drift toggle (Settings > Game),
   the previously-broken info/gear/menu taps, and general v1.1 sanity.
3. Once device-verified, flip `SHOW_BUILD_STAMP` to `false` per the archive
   checklist above, then Jimmy can archive/submit v1.1 (build 4) with the
   drafted release notes (Drift mode announcement + "fixed several buttons
   that were hard to tap").
4. Ask Jimmy whether to delete the now-fully-merged `feature/drift-cylinder`
   branch (local + origin).

## How to resume

```bash
cd ~/Developer/tetris
git pull                        # should already be at 4bcbf40 / clean
npm install && npx cap sync ios # only needed if node_modules is stale
# open ios/App/App.xcodeproj in Xcode -> Shadowfax -> Run
```

No other setup steps. This is the only working copy now -- no handoff
between machines needed.

## Machine / account notes

- Generated on **Gandalf**, from `~/Developer/tetris` -- the single working
  copy as of this session (MacFQ is retired for this project; the old
  Dropbox copy is untouched but unused).
- Personal repo; push with the explicit token form:
  ```bash
  GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
  git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
  ```
- The GitHub push had transient network trouble earlier in this session
  (HTTP 408 / RPC timeouts, unrelated to git or file size) -- if a push
  hangs or 408s, it's very likely the connection, not the repo; just retry.
