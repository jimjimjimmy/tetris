# Handoff - Tetris (Rival) - 2026-07-04

## What this is
Personal 2-player mobile Tetris (`jimjimjimmy/tetris`), Capacitor iOS wrap.
Generated on the CODE machine (`/Users/jimmyche/.../Dropbox/.../Tetris`).
This session: swapped in the new ARCH RIVAL logo lockup and removed the now-dead
`@capacitor/keyboard` plugin. Both committed + pushed.

## Current state
HEAD = `aa122e2`; footer/APP_COMMIT = `1cbe0bd`. Local == origin/main (pushed).

Landed this session (newest first):
- **`aa122e2`** - stamp bump (APP_COMMIT `1cbe0bd`, build date `2026-07-04T21:57:14`).
- **`1cbe0bd`** - two changes in one content commit:
  - **ARCH RIVAL logo** (Figma `390:7389`, "Arch Rival" variant in Start Screen
    `390:7258`): `RivalLogo` is now a 220 x 69.805 two-path inline SVG - grey
    "ARCH" (white `#ffffff` @ `fillOpacity 0.3`, top) stacked over orange "RIVAL"
    (`#FF6600`, bottom). Replaced the old single-line 220 x 31.95 wordmark.
    Wrapper `top` moved 391 -> 346 on BOTH the Single + 2 Players tabs. Verified
    pixel-exact in the browser preview (measured top 346, w 220, h 69.8,
    centeredX 201). DIFF vs Figma: none.
  - **Removed `@capacitor/keyboard`**: the plugin dep (package.json /
    package-lock.json), the `Keyboard: { resize: "none" }` block in
    `capacitor.config.json`, the native keyboard-pin `useEffect` in `app.jsx`,
    and the dead input-focus early-return in `FullscreenGame.recalc`. All dead
    since the Enter-Code screen switched to the in-app numeric keypad (no OS
    keyboard is ever summoned). App boots clean, no console errors.

## Gandalf build note (IMPORTANT - dep removed this session)
Gandalf already pulled + ran `cap sync` successfully: `cap sync` correctly shows
only 3 plugins (haptics, splash-screen, status-bar) - `@capacitor/keyboard` is
gone from the iOS project, so the build is fine. BUT the `npm install` step
errored (`EINVALIDTAGNAME`) because the pasted command had an inline `#` comment
and zsh interactive does NOT treat `#` as a comment - npm read `#` as a package
arg. No harm done (npm rejected before touching node_modules), but a stale
`node_modules/@capacitor/keyboard` folder is still on disk (unreferenced, does
not affect the build). To tidy it, re-run `npm install` with NO inline comments.

## Files changed this session
| File | Status | What changed |
|------|--------|-------------|
| preview/app.jsx | committed | New ARCH RIVAL `RivalLogo` SVG; both logo wrappers top 391->346; removed keyboard effect + recalc input guard; stamp bump |
| preview/app.js | committed | Compiled output (npm run build) |
| capacitor.config.json | committed | Removed `Keyboard: { resize: "none" }` |
| package.json / package-lock.json | committed | Removed `@capacitor/keyboard` dep |
| CLAUDE.md | committed | Updated `RivalLogo` entry to the Arch Rival lockup (220x69.805, top 346) |
| store-screenshots/ | UNTRACKED | 3 App Store PNGs (01-gameplay/02-countdown/03-keypad), now flattened to no-alpha, 1320x2868. Left untracked. |

## Uncommitted work
Only `store-screenshots/` is untracked. Tree is otherwise clean.

## Open questions / decisions pending
1. `store-screenshots/` - still untracked. Decided this session that git vs
   gitignore does NOT affect App Store upload (you upload via App Store Connect
   / Transporter from disk). Leaving untracked. Revisit only if you want them
   versioned for Gandalf.
2. App Store screenshots: all 3 are 1320x2868 (iPhone 6.9" required size) and
   were flattened to strip the macOS alpha channel (Apple wants no alpha).
   Ready to upload. If App Store Connect asks for iPad shots, either add 13"
   iPad screenshots (2064x2752 / 2048x2732) or set `TARGETED_DEVICE_FAMILY = 1`
   (iPhone-only) so it stops asking - NOT yet checked which the project uses.

## What to do next
1. On Gandalf: `npm install` (clean, no comment) to prune the leftover
   `node_modules/@capacitor/keyboard`, then rebuild to Shadowfax and confirm the
   ARCH RIVAL logo shows on the start screen.
2. Device-verify the earlier-session online flow that was never eyeballed on
   hardware: in-app keypad, START IN countdown, 2-device pause -> forfeit.
3. Continue online polish: Connection-Failed / timeout state (proposed, not
   built); reconnect + rematch-consent (deferred).

## How to resume
On the CODE machine (this one):
```bash
cd "/Users/jimmyche/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris"
git pull
# edit preview/app.jsx -> npm run build -> bump APP_COMMIT + APP_BUILD_DATE -> build again -> commit BOTH
```
On Gandalf (build-only clone, NOT the Dropbox copy):
```bash
cd ~/Developer/tetris
git pull
npm install
npx cap sync ios
npx cap open ios   # build to Shadowfax
```

## Machine / account notes
- Generated on the CODE machine. Gandalf is build-only (`~/Developer/tetris`).
- Personal repo - push with the explicit token form:
```bash
GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null)
git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
```
