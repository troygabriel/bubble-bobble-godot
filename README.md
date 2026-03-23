# Bubble Bobble Clone (Godot 4.x)

How to run:
- Open the project in Godot 4.x.
- Run `Main.tscn` or press Play from the editor.

Controls (InputMap):
- `move_left`: A / Left
- `move_right`: D / Right
- `jump`: W / Up
- `fire`: Space
- `start`: Enter / Space
- `restart`: R

Implemented features:
- [x] Player movement with run, jump, gravity, and wall/floor collision via `CharacterBody2D` + `move_and_slide()`
- [x] TileMap-based single-screen level with solid platforms
- [x] Bubble shooting in facing direction, horizontal travel, upward float, and despawn lifetime
- [x] 3-6 enemies with platform patrol, wall/edge turning, and player damage on contact
- [x] Bubble trapping mechanic that disables enemy behavior and carries the trapped enemy upward
- [x] Bubble popping on player touch, enemy removal, score gain, HUD updates, Game Over, and restart loop
- [x] Round progression that increases enemy count/speed after a clear

Bonus feature:
- [x] High-score persistence using `user://bubble_bobble_save.json`

Known bugs / limitations:
- There is only one room layout; later rounds reuse it with more/faster enemies.
- The project was validated headlessly in the CLI environment, but you should still do a full editor playthrough before final submission.

Project notes:
- Entry scene: `Main.tscn`
- Main gameplay logic lives in `scripts/game/Level01.gd`
- Best score is saved locally and loaded automatically on launch
- AI-generated source files live in `assets_ai/raw/`
- Final in-game AI assets live in `assets_ai/processed/`
- Assignment documentation lives in `docs/`
- `scripts/core/AiAssets.gd` centralizes visual asset references
- `scripts/core/AudioManager.gd` adds runtime audio buses and playback for the new SFX/music
