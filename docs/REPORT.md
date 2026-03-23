# REPORT

## Setup

- Base game/project: `bubble-bobble-godot`
- Godot version: `4.5.2.stable`
- Test platform: Linux, headless validation in the local CLI environment
- Goal: replace the clone's visual and audio assets with an original AI-generated pack while preserving gameplay
- Asset direction: "glass reef arcade" visuals plus short synthetic/chiptune audio

## Gameplay Parity Checks

- Player movement timing: unchanged; `move_speed`, `jump_velocity`, `gravity_strength`, `fire_cooldown`, and invulnerability values in `res://scripts/game/Player.gd` were left intact.
- Jump feel / arc: unchanged; only jump SFX was added at the same input event.
- Hitboxes / collisions: unchanged collision shapes for player, enemy, and bubble; the TileSet collision polygon remains a full `32x32` block in `res://scripts/game/Level01.gd`.
- Enemy behavior: unchanged patrol logic, wall/edge turn logic, and trap/pop flow.
- Pickup / projectile timing: unchanged bubble spawn position, travel speeds, upward float, and pop scoring.
- Win / lose conditions: unchanged round-clear and game-over logic.

## Validation Run Log

- Import validation: `godot4 --headless --path . --import --quit`
- Main scene smoke test: `godot4 --headless --path . --quit-after 120`
- Gameplay startup smoke test: `godot4 --headless --path . --script res://tools/runtime_smoke.gd`
- Integration issue found and fixed: the first TileSet-atlas pass lost collision layer setup; I fixed `res://scripts/game/Level01.gd` so tiles are created after the source is attached to the TileSet.
- Remaining note: the CLI smoke harness exits with a generic ObjectDB/resource-in-use warning on forced shutdown, but the project imports and the main/runtime startup paths complete without script/runtime errors after the tile fix.

## Asset Replacement Coverage

- Player sprites / animations: replaced with `res://assets_ai/processed/visual/player/player_sheet.png`
- Enemy sprites / animations: replaced with `res://assets_ai/processed/visual/enemy/enemy_sheet.png`
- Bubble / trapped-bubble sprites: replaced with `res://assets_ai/processed/visual/bubble/orb_sheet.png` and `res://assets_ai/processed/visual/bubble/trap_sheet.png`
- Tileset / level art: replaced with `res://assets_ai/processed/visual/environment/block_tiles.png`
- Backgrounds: replaced with `res://assets_ai/processed/visual/environment/background_sheet.png`
- UI: replaced title art, prompt animation, game-over art, HUD panel, life icon, and project icon under `res://assets_ai/processed/visual/ui/`
- SFX count: `8`
- Music count: `1` looping track

## Evidence Collected

### Visual assets

- What worked: once I locked a shared palette and silhouette language, sheet-based assets could be kept coherent across player, enemy, UI, and tiles.
- What failed: early versions of the title and game-over screens had overflowing text; the first player sheet had feet and muzzle effects that collapsed at `64x64`; early backgrounds were too busy behind gameplay lanes.
- Cleanup required: I downscaled raw renders, quantized palettes, shortened on-image copy, retuned sprite scales in code, and rebuilt the TileSet atlas integration by hand.
- Iteration / control issues: pose and text layout were hard to control directly; the title/game-over art required extra passes purely to make text fit cleanly.
- Consistency issues: without explicit cleanup, the player, bubble, and background outputs drifted in detail density; a shared palette and repeated manual tuning were needed to make the pack feel like one game.

### Audio assets

- What worked: short synthetic SFX were easy to map to discrete gameplay events, and the looped music bed fit the arcade pace once normalized.
- What failed: raw SFX often clicked at the start/end, and several cues initially overlapped conceptually (for example, the start chirp sounded too much like jump/fire).
- Cleanup required: every cue needed envelope cleanup, loudness normalization, and some harmonic simplification; the music loop also needed explicit looping logic in `res://scripts/core/AudioManager.gd`.
- Looping / mixing issues: the first music pass was too bright and did not feel loop-safe enough; round-clear was initially too loud compared to the rest of the mix.
- Consistency issues: even with procedural synthesis, getting a family of sounds that felt related but non-redundant took multiple passes.

## Time Cost

- Total generation time: about `90` minutes across raster/audio scripting and reruns
- Total manual cleanup time: about `150` minutes across tuning, integration, and documentation
- Asset with highest cleanup cost: `player_sheet` on the visual side and `reef_loop_music` on the audio side
- Asset with most failed iterations: `title_screen` / `game_over_screen` for text fit and `reef_loop_music` for balance/loop polish

## Conclusion On The Hypothesis

The evidence from this project supports the hypothesis. I was able to replace the clone's assets with AI-generated originals, but the raw outputs were not ready to ship directly. The player sheet needed silhouette cleanup, the UI backgrounds needed text-layout fixes, the tile atlas needed manual integration work, and every audio cue needed envelope or loudness cleanup before it felt usable.

Control and iteration were the biggest production problems. The places that look simple in the final result - consistent animation poses, a clean prompt badge, a title card with readable text, and a loop that restarts smoothly - took repeated manual correction. The assets became usable only after I constrained them heavily with shared palettes, deterministic sheet layouts, code-side scaling, and explicit audio loop setup.

So the final game is playable and documented, but the process still backs the assignment's claim: current GenAI workflows can produce a workable base, yet they are still cleanup-heavy and not reliable enough to treat as push-button production-ready asset generation.
