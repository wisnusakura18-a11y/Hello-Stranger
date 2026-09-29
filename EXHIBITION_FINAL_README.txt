HELLO, STRANGER - SEVEN DAYS
FINAL EXHIBITION BUILD

WHAT IS IN THIS BUILD
- 7 day/level quest progression
- Day timer: 5:00 -> 4:30 -> 4:00 -> 3:30 -> 3:00 -> 2:30 -> 2:00
- NPCs randomized per day but stationary inside their own location zone
- Natural dialogue using the player's entered username
- Player name shown above the MC sprite
- E/Enter/Space interaction with NPCs/items
- 2-3+ quest objectives per day
- Find item + talk NPC + delivery + order + story logic question challenges
- Procedural cute yellow sparkle item visuals, so missing item art does not block the game
- Speed-based scoring aligned with the quest PDF: completion +300, time bonus +100..400, perfect +300, max 1000 per quest
- Game Over on timeout + Retry
- Day transition fade using Sunrise / Classroom / Sunset visuals
- Save/Load by username
- LAN shared save server for the exhibition
- Live leaderboard for PC C, auto refresh every 2 seconds
- Leaderboard shows SCORE, Q1-Q7 completed, TOTAL TIME, DAY. No rank column.
- Settings reduced to useful controls only: volume, fullscreen, LAN server address

3-PC EXHIBITION SETUP
PC C:
1. Double click START_LAN_SERVER_PC_C.bat
2. Run ipconfig and note the IPv4 address, e.g. 192.168.1.20
3. Keep the black server window open.
4. Open the game and switch to Leaderboard for the spectator screen.

PC A + PC B:
1. Open the game.
2. Settings -> LAN Server
3. Enter http://IP-PC-C:8765
4. Save Settings
5. Players can start with any username.
6. F5 saves the player's progress locally and to the shared LAN server.

LOAD GAME
Use the exact username that was used before. The game checks the LAN server first, then local save if LAN is unavailable.

IMPORTANT
The server is LAN-based for the school exhibition. All three PCs must be on the same network.
This folder contains the source project. Open project.godot with Godot 4.x.

V6 FIX + IN-GAME GUIDE
=======================
- Parser fix: no anonymous lambdas in the Godot scripts.
- Tutorial opens on first run and can be reopened from ? GUIDE.
- Tutorial explains WASD/Arrow, E interact, yellow sparkle items, the directional arrow, and speed-based scoring.
- Objective guidance shows zone + target + approximate distance; arrow points toward the active target.
- Screen-only HUD, tutorial, day transition, questions, game-over and epilogue are attached to the CanvasLayer so the camera cannot drag the UI away.
- Demo quest items are procedural: yellow sparkle/glow + simple icon shapes. These are placeholders for the team's final art assets.
- V6 is intended for Godot 4.3. No Godot executable is available in the build environment, so this package includes static validation only, not a claimed F6 runtime playtest.


V8 POLISH NOTES
- Warm brown/gold/cream visual language across gameplay, settings, load cards, leaderboard and tutorial.
- Player/NPC display names are compact; player name is taken from the entered username.
- WASD and arrow-key movement are both supported.
- Pause menu includes Save Progress, Settings, How to Play, Save & Exit and Close.
- Settings includes Master/Music/SFX, Fullscreen, Guide Arrow, Auto Save, Controls and Exhibition/LAN server URL.
- Load Game uses searchable player cards with avatar, Day, score and completed quest count.
- Leaderboard uses Player, Score, Q1-Q7, Total Time and Day, with auto-refresh.
- Quest item visuals remain procedural demo sparkles so replacement assets can be dropped in later without changing quest logic.
