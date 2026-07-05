# RVAL - App Store Submission Worksheet

Copy-paste sheet for filling out App Store Connect. All fields approved 2026-07-04.

## App Information

| Field | Value |
|-------|-------|
| App Name | `RVAL` |
| Subtitle | `Two-player territorial Tetris` |
| Bundle ID | `com.typographic.drift` |
| Primary Category | Games > Puzzle |
| Secondary Category | Games > Casual |
| Content Rights | Does NOT contain third-party content |

## Version 1.0 Information

### Promotional Text (170 chars, updatable later)

```
Play head-to-head with a friend using a 4-digit room code, or take on the AI. Clear rows to push the boundary line and squeeze your rival out of the board.
```

### Description

```
RVAL is a two-player Tetris duel on a shared board.

Instead of racing for high scores, you're fighting for territory. Each row you clear pushes the boundary line into your opponent's side of the board. Squeeze them to zero rows to win. They're doing the same to you.

MODES
- Solo: pick your side, pick a difficulty, take on the AI.
- Online: share a 4-digit room code with a friend and play in real time.

CONTROLS
- Tap to rotate.
- Swipe left / right to move.
- Swipe up or down to hard-drop.

FEATURES
- Fully symmetric two-player rules: same pieces, same speed, no advantage.
- Boundary line moves live as rows clear - watch your territory grow or shrink.
- Five AI difficulty levels in solo.
- No accounts, no ads, no tracking.

For questions or feedback: rval@typographic.com
```

### Keywords (100 chars max)

```
tetris,puzzle,blocks,multiplayer,2player,online,arcade,tetromino,rival,duel,friend,head-to-head
```

### URLs

| Field | Value |
|-------|-------|
| Support URL | `https://jimjimjimmy.github.io/tetris/support.html` |
| Marketing URL | (leave blank) |
| Privacy Policy URL | `https://jimjimjimmy.github.io/tetris/privacy.html` |

### Version + Build

| Field | Value |
|-------|-------|
| Version | `1.0` |
| Build | `1` (bumps per TestFlight upload) |
| Copyright | `2026 Jimmy Chen` (App Store adds ©) |

## Screenshots

Upload from `store-screenshots/` in order:

1. `01-gameplay.png` (1320x2868)
2. `02-countdown.png` (1320x2868)
3. `03-keypad.png` (1320x2868)

iPad screenshots: not required (iPhone-only target).

## Age Rating Questionnaire

All answers **None / No**. Result: **4+**.

## Privacy - Data Collection

Answer: **"Data Not Collected"** on the Privacy questionnaire.

Rationale: no analytics, no accounts, no ads, no tracking SDKs. PartyKit relay traffic (room code + game moves) is transient and not persisted.

## Export Compliance

| Field | Value |
|-------|-------|
| Uses encryption | Yes (HTTPS only) |
| Exempt | Yes - standard iOS crypto only |
| `ITSAppUsesNonExemptEncryption` | `false` (already set in Info.plist) |

After the first submission answers this once, it will not re-prompt on subsequent builds.

## App Review Contact (private, only Apple sees)

| Field | Value |
|-------|-------|
| First name | Jimmy |
| Last name | Chen |
| Email | `rval@typographic.com` |
| Phone | (fill in) |
| Demo account | not required |

### Notes for reviewer

```
Two-player multiplayer connects via a 4-digit room code. To test the ONLINE mode, please install on two devices and enter the same room code on both. Solo mode is fully playable on a single device with no login.
```

## Pre-upload checklist

- [x] `TARGETED_DEVICE_FAMILY = "1"` (iPhone-only)
- [x] `ITSAppUsesNonExemptEncryption = false`
- [x] App icon 1024x1024, no alpha
- [x] Splash 2732x2732, no alpha
- [x] Support + Privacy pages live on GitHub Pages
- [x] Support email `rval@typographic.com` receiving mail
- [ ] Gandalf rebuild + Xcode General panel confirms iPad slot is gone
- [ ] Archive + upload via Xcode Cloud or Xcode Organizer to TestFlight
- [ ] Bump `CURRENT_PROJECT_VERSION` before each TestFlight upload
