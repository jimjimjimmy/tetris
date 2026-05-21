# Tetris Game - Ideas & Future Features

---

## THE NORTH STAR CONCEPT (BIG IDEA - core vision)

The game is a communication app with a game at its heart.

**The core loop:**
- You want to video chat with someone
- You have to earn it by playing
- The better you play, the longer your chat time
- Lose territory = lose chat time
- Win = extend the call
- The game IS the conversation

**Why this is different:**
Not "play a game then chat" - the tension of the board IS the tension
of the relationship. You are literally fighting for time with someone.
The shared board mechanic becomes a metaphor - two people, one space,
both trying to hold their ground.

**Use cases:**
- Long distance couples - earn your facetime
- Friends who want to catch up but need a reason to stay on
- Speed dating - chemistry + skill combined
- Kids earning screen time with parents
- Anyone who wants connection with a little stakes attached

**The business model:**
- Free: limited chat time banked per day
- Premium: unlimited chat time, or start with more time banked
- The game is the paywall but it never feels like one

**App Store category:** Social Networking, not Games.
This changes everything about how it is marketed and discovered.

**The name DRIFT still works:**
Drifting toward each other. Drifting apart.
The wind mechanic, the balloon physics, the territory - all of it
becomes metaphor for connection and distance.

**Everything serves this:**
- Planetary environments = different contexts for different relationships
- Real-world weather = shared conditions, you are both in the same world
- Opponent face cam = you see each other while you fight for time
- Territorial decay = no one dominates forever, the game stays close
- Haptic feedback = physical sensation of connection through the screen

---

## Territorial Decay (confirmed mechanic)

Each row cleared is worth slightly less territory over time. Prevents death spirals
and keeps matches at a comfortable pace without favoring either player.

Decay curve should feel gentle - exact values TBD during playtesting.
General shape: starts at full value (1 row per clear), gradually tapers toward
a floor (maybe 0.25 or 0.5 per clear). Never reaches zero - clears always
matter, just less dramatically over time.

Implementation note: track total clears per player, apply decay curve to
territory shift amount per clear.

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

## Game Design Philosophy - Transparency

Every outcome is traceable to a fixed rule. No hidden modifiers, no secret
difficulty scaling, no RNG that feels rigged. If you lose, you can point to
exactly why. Rules are public and verifiable.

Levels introduce new dimensions of fixed rules - not hidden advantages.
Each level adds one new rule. Players learn the system incrementally.

"Fair by design" - a real differentiator in a world of manipulative game mechanics.

---

## Real-World Conditions (BIG IDEA)

Use real-world environmental data as the source of "unpredictable" conditions.
Transparent but genuinely surprising - the rule is fixed, the outcome varies
because the real world varies. Players can verify the conditions against their
weather app. Personal and location-specific.

**Wind speed** -> lateral drift strength on pieces
**Wind direction** -> which way pieces drift left or right
**Temperature** -> piece fall/float speed (hot air rises faster, cold air is denser)
**Humidity** -> lock delay (sticky air, pieces settle slower)
**Time of day** -> subtle boundary starting position variation
**Moon phase** -> decay curve variation (full moon = stronger buoyancy,
  new moon = heavier pieces). Poetic, verifiable, completely out of player control.

**Multiplayer question to resolve:** when two players are in different locations,
whose weather conditions apply? Options:
- Server location (neutral)
- Average of both players' conditions
- Each player experiences their own conditions (asymmetric - interesting)
- Random coin flip between the two players' locations

**Implementation note:** use a weather API at game start to fetch local conditions.
Cache for the duration of the match so conditions don't change mid-game.
Show the conditions to both players before the match starts - full transparency.

---

## Wind (confirmed future mechanic)

Horizontal drift applied to pieces as they rise/fall. Direction and strength
sourced from real-world wind data (see Real-World Conditions above).

Wind indicator UI showing direction and strength - players can see exactly
what they are dealing with before and during the match.
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

## Planetary Environments (BIG IDEA)

Each planet/environment sets the physics rules for the match. Completely
transparent - "you are on Jupiter, here are Jupiter's rules." No mystery,
no hidden modifiers. Just science.

Players select or are assigned an environment. Rules are displayed before
the match starts so both players know exactly what they are dealing with.

**Earth** - standard conditions, balanced starting point. Default environment.
**Moon** - low gravity, pieces float very slowly, long hang time
**Mars** - thin atmosphere, low gravity, pieces feel light and drift easily
**Pluto** - minimal gravity, fierce cold wind, pieces float unpredictably
**Jupiter** - crushing gravity, pieces fall/rise fast, strong atmospheric turbulence
**Venus** - extreme pressure, pieces lock faster, thick atmosphere slows drift
**Saturn** - ring interference, wind shifts direction frequently
**The Sun** - intense everything, maximum speed, maximum chaos. Hardest mode.
**Deep Space** - zero gravity, no wind, pure puzzle. Slowest, most strategic.

**Physics parameters per environment:**
- Gravity strength -> piece fall/float speed
- Atmospheric density -> drift resistance and wind effect
- Wind speed -> lateral drift strength
- Temperature -> lock delay
- Pressure -> territorial decay rate

**Connection to real-world data:**
Your actual GPS location could map to a planetary zone, or players
choose their environment at the start screen. Could also unlock
environments as you progress.

**Narrative tie-in:**
Connects to the solar system defense concept - you are literally
fighting on different battlegrounds across the solar system.
Each environment is a different front in the war.

---

## Opponent Face Cam (BIG IDEA - v3 social feature)

Use the front-facing camera to show the opponent's live video feed
behind their pieces on the shared board.

**The concept:**
- Opponent's camera feed sits behind their territory at low opacity
  (10-15%) - barely there, just a presence
- Or only flashes briefly when territory shifts - a glimpse of their
  reaction at the most tense moment
- Or a small face cam window in the corner of their territory

**Why it works:**
Seeing your opponent's face react in real time as you steal their
territory is pure gold. The reaction moment when you clear 3 rows
and push the boundary is the killer feature - shareable, memorable,
social.

**Design options:**
- Full bleed behind opponent territory at low opacity
- Small window in corner of opponent territory
- Flash on territory shift only
- Toggle on/off in settings (privacy consideration)

**Implementation:**
- Capacitor + AVFoundation on iOS
- WebRTC for real-time peer-to-peer video
- Requires camera permission from both players
- Works in multiplayer mode only

**Retention mechanic:**
Watching someone's face react to losing territory is exactly the kind
of moment people screenshot and share. Built-in viral loop.

Could be a premium feature or unlock after N games played.

---

## iOS (v3)

- Gesture controls: swipe left/right to move, tap to rotate,
  swipe up/down for buoyancy boost
- Capacitor wrapper
- App Store assets (icon, splash, screenshots)
- Game Center integration
