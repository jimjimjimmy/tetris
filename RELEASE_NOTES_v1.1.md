# RVAL v1.1 Release Notes

## Highlights

**New: Drift mode (solo)**
A new single-player mode where the board scrolls continuously instead of pieces dropping into a static well. Includes a parallax starfield background and wrap-aware controls, so pieces and gestures behave correctly as the board scrolls past the seam.

**Bigger, easier-to-hit tap targets**
Icon and text buttons throughout the app were enlarged toward Apple's 44pt minimum touch target guideline, making the UI easier to use one-handed.

**Smoother screen transitions**
Slide transitions between screens are wider and slower, with distance/duration values consolidated into shared constants for consistency across the app.

**Starfield polish**
The start screen (both Single and 2 Players tabs) now shows a drift starfield background. The dot pattern was reworked from a repeating tile to a true random scatter, and visibility was boosted after the initial version rendered too faintly to notice.

## Fixes

- Fixed drift "straddle" glitches: pieces getting cropped, the AI opponent freezing, and false eviction triggers when a piece spans the wrap seam
- Made player-input gestures wrap-aware so drift controls behave correctly across the seam

## Also in this release

- Updated app icon (marked as a test version, may change again)
- New App Store screenshots for 6.5" displays (gameplay, start screen, 2-player room code flow, countdown, keypad)
- Version display relocated to Settings; debug build stamp gated off for App Store builds

## Build 5 (re-archive, no gameplay changes)

- Settings now shows the build number alongside the version (`v1.1 (5)`) -- the standard iOS "Version X (build N)" convention, matching what TestFlight shows per install
- Fixed the App target's Xcode project missing `DEVELOPMENT_TEAM`, which caused Xcode Cloud archives to come out unsigned and unable to be distributed

---
v1.1, build 5 - APP_COMMIT 67b6849
