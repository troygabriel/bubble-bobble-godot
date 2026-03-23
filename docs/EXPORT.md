# EXPORT

## Current State

- A prebuilt exported binary is not committed in this repo.
- The project imports and launches in Godot `4.5.2.stable` in the local environment.
- Gameplay startup was smoke-tested with `godot4 --headless --path . --script res://tools/runtime_smoke.gd`.

## Export Instructions

1. Open the project in Godot `4.5.2.stable`.
2. If this is the first checkout, let Godot import all files or run `godot4 --headless --path . --import --quit` first.
3. Confirm the project opens without errors and that `Main.tscn` runs.
4. Open `Project -> Export`.
5. Install the matching export templates if Godot prompts for them.
6. Add the platform preset you need for submission (Linux, Windows, etc.).
7. Export the build to a committed folder such as `build/`.

## Useful Validation Commands

- Import assets: `godot4 --headless --path . --import --quit`
- Launch the project briefly: `godot4 --headless --path . --quit-after 120`
- Launch the menu, start a round, and process a few gameplay frames: `godot4 --headless --path . --script res://tools/runtime_smoke.gd`

## Submission Notes

- Godot version: `4.5.2.stable`
- Export preset(s): not committed
- Extra runtime dependencies: none expected beyond standard Godot export templates
- Known platform-specific issues: none observed in headless validation; re-test audio on the target OS after export
- Last successful validation date: `2026-03-23`
