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
- No audio is included.

Project notes:
- Entry scene: `Main.tscn`
- Main gameplay logic lives in `scripts/game/Level01.gd`
- Best score is saved locally and loaded automatically on launch
- Uses Bubble Bobble-style sprites adapted from the Cavern reference spriteset; no generative art is used
