# Handoff - Tetris iOS - 2026-06-06

## What this is
Personal two-player iOS Tetris game (jimjimjimmy/tetris), MacFQ code machine. This session focused on adding background music (BGM) to gameplay.

## Current state
- BGM is working on device - `[sfx] bgm playing` confirmed in Xcode console
- BGM audio file: `preview/assets/Sound fx/Music/bgm.m4a` (ominous ticking clock, M4A/AAC)
- BGM plays when game starts, pauses when paused, stops on menu/game over
- BGM volume is still too loud - iOS ignores `audio.volume` JS property; baking 25% into the audio file via Python audioop + afconvert did not produce audible difference
- Game does NOT pause when Settings or Info screen is opened (known bug, not yet fixed)
- SFX (non-music sounds) status: user still looking for better SFX files

## Files changed this session

| File | Status | What changed |
|------|--------|-------------|
| preview/index.html | committed | BGM routed through sfx object; bgmPlay/bgmStop/bgmPause/bgmVolume methods added; BGM useEffect added to TetrisGame2P; gesture handlers call bgmPlay on user interaction |
| preview/assets/Sound fx/Music/bgm.m4a | committed | Converted from WAV (unsupported by WKWebView) to M4A; re-encoded at 25% amplitude (may not have taken effect - needs verification) |
| preview/assets/Sound fx/Music/bgm.wav | committed | Original WAV retained in repo |

## Uncommitted work
Only untracked SFX candidate files the user has been browsing. Not part of the build. Safe to ignore.

## Open questions / decisions pending
- BGM volume: iOS ignores `audio.volume` JS. The 25% bake via Python audioop + afconvert did not seem to work. Need to verify m4a was actually re-encoded at lower amplitude, or try ffmpeg for volume reduction.
- Game pause on Settings/Info open: when user taps Settings or Info icon, the game continues running. Should pause the game tick and BGM.
- SFX: user still selecting better sound effect files from candidates in `preview/assets/Sound fx/`.

## What to do next
1. Fix BGM volume - verify the m4a amplitude was actually reduced, or re-encode using a different tool. Test on device.
2. Pause game when Settings or Info screen is opened.
3. SFX selection - user to pick files; wire them in once selected.

## How to resume

```bash
# On MacFQ (code machine):
cd "/Users/jimmyche/Library/CloudStorage/Dropbox/04 Projects/AI Shared/Tetris"
git pull

# On Gandalf (build machine):
cd ~/Developer/tetris && git pull && npx cap sync ios
# Copy to DerivedData (Xcode caches web assets - must do this every time):
cp ios/App/App/public/index.html ~/Library/Developer/Xcode/DerivedData/App-cxxgmxbgxoonhecemrbvkjfgirae/Build/Products/Debug-iphoneos/App.app/public/index.html
cp "ios/App/App/public/assets/Sound fx/Music/bgm.m4a" ~/Library/Developer/Xcode/DerivedData/App-cxxgmxbgxoonhecemrbvkjfgirae/Build/Products/Debug-iphoneos/App.app/public/assets/Sound\ fx/Music/bgm.m4a
# Then Run in Xcode
```

## Machine / account notes
- Handoff generated on MacFQ
- Gandalf is build-only - never commit/push from Gandalf
- Push command (jimjimjimmy personal account):
  ```bash
  GITHUB_TOKEN=$(gh auth token --hostname github.com -u jimjimjimmy 2>/dev/null) && git push "https://jimjimjimmy:${GITHUB_TOKEN}@github.com/jimjimjimmy/tetris.git" main
  ```
- DerivedData path on Gandalf: `~/Library/Developer/Xcode/DerivedData/App-cxxgmxbgxoonhecemrbvkjfgirae/Build/Products/Debug-iphoneos/App.app/public/`
