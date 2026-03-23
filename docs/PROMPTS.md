# PROMPTS

## Project Info

- Base project/repo: `bubble-bobble-godot`
- Final submission date: `2026-03-23`
- Godot version used for validation: `4.5.2.stable`
- Target platform/export: Linux desktop; export not committed, see `res://docs/EXPORT.md`
- Visual direction goal: original "glass reef arcade" pack with bright coral, teal creature silhouettes, and clean 2D readability at small sizes
- Audio direction goal: synthetic arcade/chiptune replacement with short, clean SFX and one looping music bed
- Gameplay rule preserved: movement constants, hitboxes, collisions, bubble logic, round flow, and timings were not changed; only asset references, import behavior, UI visuals, and audio glue were added
- Validation commands used during integration: `godot4 --headless --path . --import --quit`, `godot4 --headless --path . --quit-after 120`, `godot4 --headless --path . --script res://tools/runtime_smoke.gd`
- Hypothesis under test: current GenAI tools are not production-ready for game asset production because they need cleanup, are hard to control, and do not reliably yield consistent shippable results

### asset_id: player_sheet

- Type: `sprite_sheet`; final: `res://assets_ai/processed/visual/player/player_sheet.png`; raw: `res://assets_ai/raw/visual/player_sheet_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering on `2026-03-23`
- Prompt: "Create an original cute reef hatchling hero for a single-screen arcade platformer: aqua body, cream belly, orange fins, readable side-view sprite sheet with idle, run, blow, recoil, and fall poses, 64 px readability, no copyrighted mascots"; negative: "no Bubble Bobble dragons, no logos, no photorealism, no extra limbs, no blurred outlines"
- Seed / settings: deterministic procedural render; 5x3 sheet; raw `96x96` cells; processed `64x64` cells; palette quantized to `48` colors
- Iterations / chosen output / manual edits: `4`; kept the sheet with the cleanest muzzle and foot silhouettes, then aligned eye height, reduced the blow flare, and tuned sprite scale in code; manual edit time `35` min
- Problems / import / originality: pose drift and tiny feet at small sizes; nearest filter forced in code and default lossless PNG import; reef fins and muzzle flare keep it visually distinct from the arcade source character

### asset_id: enemy_sheet

- Type: `sprite_sheet`; final: `res://assets_ai/processed/visual/enemy/enemy_sheet.png`; raw: `res://assets_ai/raw/visual/enemy_sheet_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering
- Prompt: "Original coral walker enemy with a shell-like body, visor eye, squat arcade silhouette, four walking frames per direction, readable at 64 px"; negative: "no known Bubble Bobble robots, no copyrighted mascots, no realistic shading, no noisy backgrounds"
- Seed / settings: deterministic procedural render; `4x2` sheet; raw `96x96` cells; processed `64x64` cells; palette quantized to `44` colors
- Iterations / chosen output / manual edits: `3`; chose the version with the clearest feet and visor, then widened the leg swing and brightened the visor for contrast; manual edit time `18` min
- Problems / import / originality: leg motion flattened when downscaled; nearest filter in code and default lossless PNG import; crab-shell proportions and visor styling avoid the original enemy silhouette

### asset_id: bubble_orb_sheet

- Type: `sprite_sheet`; final: `res://assets_ai/processed/visual/bubble/orb_sheet.png`; raw: `res://assets_ai/raw/visual/bubble_orb_sheet_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering
- Prompt: "Seven-frame bright reef bubble projectile with aqua glass rim, white sparkle, and light pulse"; negative: "no lens flare overload, no muddy transparency, no photographic bubbles"
- Seed / settings: deterministic procedural render; `7x1` sheet; raw `48x48` cells; processed `32x32` cells; palette quantized to `32` colors
- Iterations / chosen output / manual edits: `2`; kept the version with the cleanest highlights, then reduced glow radius and retuned sprite scale in code; manual edit time `10` min
- Problems / import / originality: early glow pass blurred the rim too much; nearest filter in code and default lossless PNG import; the glass-ring treatment is original and not copied from the source orb art

### asset_id: bubble_trap_sheet

- Type: `sprite_sheet`; final: `res://assets_ai/processed/visual/bubble/trap_sheet.png`; raw: `res://assets_ai/raw/visual/bubble_trap_sheet_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering
- Prompt: "Eight-frame trapped bubble with coral halo, warm star core, and rhythmic shimmer, readable when scaled down in an arcade scene"; negative: "no copied trap orb art, no noisy particles, no unreadable interiors"
- Seed / settings: deterministic procedural render; `8x1` sheet; raw `96x96` cells; processed `64x64` cells; palette quantized to `34` colors
- Iterations / chosen output / manual edits: `3`; kept the version that still read as a trapped state at small scale, then pushed the star core and reduced outer haze; manual edit time `12` min
- Problems / import / originality: the trapped state looked too similar to the free bubble at first; nearest filter in code and default lossless PNG import; coral star core creates a distinct original trapped-bubble motif

### asset_id: background_sheet

- Type: `bg`; final: `res://assets_ai/processed/visual/environment/background_sheet.png`; raw: `res://assets_ai/raw/visual/background_sheet_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering
- Prompt: "Four background variants for a reef-cavern arcade room: layered hills, coral forests, bubble clusters, bold color shifts per round, flat enough for gameplay readability"; negative: "no detailed perspective scene painting, no copyrighted environments, no clutter over gameplay lanes"
- Seed / settings: seeds `140`, `157`, `174`, `191`; `2x2` atlas of `480x270` cells; processed sheet kept at `960x540`; quantized to `64` colors
- Iterations / chosen output / manual edits: `3`; chose the set with the strongest separation between rounds, then reduced noise and simplified the silhouettes behind platforms; manual edit time `24` min
- Problems / import / originality: early passes competed with gameplay readability; nearest filter in code and default lossless PNG import; all scenes use original coral and bubble motifs rather than any copied cavern backdrop

### asset_id: block_tiles

- Type: `tileset`; final: `res://assets_ai/processed/visual/environment/block_tiles.png`; raw: `res://assets_ai/raw/visual/block_tiles_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering
- Prompt: "Four sea-glass platform tiles with coral accent trim, arcade readability, hard edges for TileMap use, and no seams"; negative: "no soft painterly edges, no broken silhouettes, no copied stone blocks"
- Seed / settings: deterministic procedural render; `4x1` atlas of `32x32` tiles; raw enlarged to `256x64` for inspection; processed kept at `128x32`
- Iterations / chosen output / manual edits: `2`; chose the set with the cleanest corner highlights, then rebuilt the TileSet atlas setup and restored full collision polygons after smoke testing; manual edit time `14` min
- Problems / import / originality: initial atlas integration lost physics-layer collision setup; TileSet uses full `32x32` regions, nearest filtering, and default lossless PNG import; sea-glass trim differs from the original block art

### asset_id: title_screen

- Type: `ui_icon`; final: `res://assets_ai/processed/visual/ui/title_screen.png`; raw: `res://assets_ai/raw/visual/title_screen_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering and local text rasterization
- Prompt: "Title screen art for an original reef bubble arcade game, wide composition, bold slanted lettering, coral foreground, large readable title, no logos from existing franchises"; negative: "no Bubble Bobble logo, no copyrighted typography, no unreadable text"
- Seed / settings: seed `212`; full-screen `960x540`; processed quantized to `72` colors
- Iterations / chosen output / manual edits: `4`; the first title copy overflowed, so I shortened the line, reduced the headline treatment, and re-ran the image; manual edit time `20` min
- Problems / import / originality: text layout was hard to control and required a second pass; nearest filter in code and default lossless PNG import; the title wording and letter styling are original and not derived from the Bubble Bobble logo

### asset_id: prompt_sheet

- Type: `ui_icon`; final: `res://assets_ai/processed/visual/ui/prompt_sheet.png`; raw: `res://assets_ai/raw/visual/prompt_sheet_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering and local text rasterization
- Prompt: "Ten-frame animated press-start sign, neon reef bubble passing behind dark panel, clean arcade readability"; negative: "no copied insert-coin graphics, no illegible text, no noisy spark particles"
- Seed / settings: deterministic procedural render; `5x2` atlas of `320x96` cells; processed size `1600x192`; quantized to `40` colors
- Iterations / chosen output / manual edits: `2`; kept the sheet with the clearest word spacing, then balanced the bubble overlay so the text remained readable; manual edit time `12` min
- Problems / import / originality: animated overlays easily blocked text; nearest filter in code and default lossless PNG import; the badge and bubble motion are original UI art

### asset_id: game_over_screen

- Type: `ui_icon`; final: `res://assets_ai/processed/visual/ui/game_over_screen.png`; raw: `res://assets_ai/raw/visual/game_over_screen_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering and local text rasterization
- Prompt: "Game-over screen art for the same reef arcade pack, pink dusk palette, heavy slanted headline, readable restart message"; negative: "no borrowed game-over card layouts, no franchise logos, no unreadable script fonts"
- Seed / settings: seed `318`; full-screen `960x540`; processed quantized to `72` colors
- Iterations / chosen output / manual edits: `3`; a longer subtitle overflowed, so I shortened the copy, reduced the supporting line weight, and re-ran the asset; manual edit time `14` min
- Problems / import / originality: long baked-in text was hard to fit cleanly; nearest filter in code and default lossless PNG import; wording, palette, and layout are original

### asset_id: hud_panel

- Type: `ui_icon`; final: `res://assets_ai/processed/visual/ui/hud_panel.png`; raw: `res://assets_ai/raw/visual/hud_panel_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering
- Prompt: "Compact HUD panel with glass-reed stripes, warm top accent, readable under score text, consistent with reef arcade pack"; negative: "no generic sci-fi chrome, no copyrighted panel art, no busy texture"
- Seed / settings: deterministic procedural render; processed `430x96`; quantized to `32` colors
- Iterations / chosen output / manual edits: `2`; kept the cleaner stripe layout, then rebuilt the HUD to use a textured panel and separate life icons; manual edit time `9` min
- Problems / import / originality: too much internal detail reduced label contrast at first; nearest filter in code and default lossless PNG import; the panel motif is original and not copied from the source UI

### asset_id: life_icon

- Type: `ui_icon`; final: `res://assets_ai/processed/visual/ui/life_icon.png`; raw: `res://assets_ai/raw/visual/life_icon_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering
- Prompt: "Small life icon derived from the new reef hatchling hero, inside a tiny bubble, readable at 20-32 px"; negative: "no copied life-heart icons, no generic emojis, no muddy edges"
- Seed / settings: deterministic procedural render; raw `48x48`; processed `32x32`; quantized to `30` colors
- Iterations / chosen output / manual edits: `2`; kept the icon with the most readable face, then reduced clutter and switched HUD lives from text count to icons; manual edit time `7` min
- Problems / import / originality: too much detail disappeared below 32 px; nearest filter in code and default lossless PNG import; the icon is derived from the new original player pack

### asset_id: project_icon

- Type: `ui_icon`; final: `res://assets_ai/processed/visual/ui/project_icon.png`; raw: `res://assets_ai/raw/visual/project_icon_raw.png`
- Tool / model: OpenCode `openai/gpt-5.4` with Python/Pillow raster rendering
- Prompt: "Project icon using the reef hatchling face over a deep-ocean badge, strong silhouette at launcher size"; negative: "no copied platform icons, no logos, no text"
- Seed / settings: deterministic procedural render; raw `192x192`; processed `128x128`; quantized to `36` colors
- Iterations / chosen output / manual edits: `2`; kept the version with the clearest face silhouette, then updated `project.godot` to point at the new icon; manual edit time `8` min
- Problems / import / originality: the first badge was too dark and lost the face; default lossless PNG import; the final icon is a new character badge rather than a reused sprite crop from the old pack

### asset_id: jump_sfx

- Type: `sfx`; final: `res://assets_ai/processed/audio/sfx/jump.wav`; raw: `res://assets_ai/raw/audio/jump_raw.wav`
- Tool / model: OpenCode `openai/gpt-5.4` with Python `wave` procedural synthesis
- Prompt: "Short rising arcade jump chirp with upbeat start, no harsh click, readable over music"; negative: "no realistic Foley, no muddy reverb, no clipping"
- Seed / settings: seed `601`; mono WAV; `22050` Hz; `0.18` s; fade in/out and peak-normalized to `0.78`
- Iterations / chosen output / manual edits: `2`; the first pass clicked at the head, so I added envelope shaping and normalization; manual edit time `6` min
- Problems / import / originality: transient clicks on the raw generation; imported as WAV, default sample import, triggered from `Player.gd`; original synthetic chirp

### asset_id: fire_sfx

- Type: `sfx`; final: `res://assets_ai/processed/audio/sfx/fire.wav`; raw: `res://assets_ai/raw/audio/fire_raw.wav`
- Tool / model: OpenCode `openai/gpt-5.4` with Python `wave` procedural synthesis
- Prompt: "Glassy bubble-shot puff with short attack and descending finish"; negative: "no gunshot, no explosion, no distortion"
- Seed / settings: seed `602`; mono WAV; `22050` Hz; `0.20` s; fade in/out and peak-normalized to `0.78`
- Iterations / chosen output / manual edits: `2`; kept the lighter airy version and softened the square-wave edge; manual edit time `7` min
- Problems / import / originality: early versions sounded too much like a laser; imported as WAV and triggered from `Player.gd`; original synthetic bubble-shot timbre

### asset_id: trap_sfx

- Type: `sfx`; final: `res://assets_ai/processed/audio/sfx/trap.wav`; raw: `res://assets_ai/raw/audio/trap_raw.wav`
- Tool / model: OpenCode `openai/gpt-5.4` with Python `wave` procedural synthesis
- Prompt: "Warm crystalline capture shimmer for enemy trapped in a bubble"; negative: "no dramatic spell sound, no long tail, no metallic clang"
- Seed / settings: seed `603`; mono WAV; `22050` Hz; `0.30` s; fade in/out and peak-normalized to `0.78`
- Iterations / chosen output / manual edits: `2`; kept the warmer pass and shortened the tail so it did not mask gameplay; manual edit time `8` min
- Problems / import / originality: long sustain cluttered the mix; imported as WAV and triggered from `Bubble.gd`; original synthesized trap cue

### asset_id: pop_sfx

- Type: `sfx`; final: `res://assets_ai/processed/audio/sfx/pop.wav`; raw: `res://assets_ai/raw/audio/pop_raw.wav`
- Tool / model: OpenCode `openai/gpt-5.4` with Python `wave` procedural synthesis
- Prompt: "Tiny bubble-pop burst with bright attack and quick decay"; negative: "no balloon sample, no realistic liquid splash, no clipping"
- Seed / settings: seed `604`; mono WAV; `22050` Hz; `0.16` s; fade in/out and peak-normalized to `0.78`
- Iterations / chosen output / manual edits: `2`; chose the version with less noise and shortened the decay; manual edit time `5` min
- Problems / import / originality: raw noise burst was too scratchy; imported as WAV and triggered from `Bubble.gd`; original synthesized pop

### asset_id: hurt_sfx

- Type: `sfx`; final: `res://assets_ai/processed/audio/sfx/hurt.wav`; raw: `res://assets_ai/raw/audio/hurt_raw.wav`
- Tool / model: OpenCode `openai/gpt-5.4` with Python `wave` procedural synthesis
- Prompt: "Descending buzzy damage cue, readable but short enough not to stall the action"; negative: "no gore, no realistic scream, no long reverb"
- Seed / settings: seed `605`; mono WAV; `22050` Hz; `0.36` s; fade in/out and peak-normalized to `0.78`
- Iterations / chosen output / manual edits: `2`; the first pass was too harsh, so I lowered the square-wave bite and smoothed the envelope; manual edit time `7` min
- Problems / import / originality: easy to become overly abrasive; imported as WAV and triggered from `Player.gd`; original synthetic damage cue

### asset_id: clear_sfx

- Type: `sfx`; final: `res://assets_ai/processed/audio/sfx/clear.wav`; raw: `res://assets_ai/raw/audio/clear_raw.wav`
- Tool / model: OpenCode `openai/gpt-5.4` with Python `wave` procedural synthesis
- Prompt: "Short four-note round-clear arpeggio that feels celebratory without becoming a full jingle"; negative: "no copyrighted fanfare, no long reverb, no vocals"
- Seed / settings: seed `606`; mono WAV; `22050` Hz; `0.70` s; fade in/out and peak-normalized to `0.78`
- Iterations / chosen output / manual edits: `3`; the first pass was too loud relative to other SFX, so I reduced the harmonic stack and kept a shorter arpeggio; manual edit time `9` min
- Problems / import / originality: balancing a celebratory cue against the rest of the mix was tricky; imported as WAV and triggered from `Level01.gd`; original note sequence

### asset_id: game_over_sfx

- Type: `sfx`; final: `res://assets_ai/processed/audio/sfx/game_over.wav`; raw: `res://assets_ai/raw/audio/game_over_raw.wav`
- Tool / model: OpenCode `openai/gpt-5.4` with Python `wave` procedural synthesis
- Prompt: "Descending arcade failure sting, final but still brief"; negative: "no copied death jingle, no horror hit, no long sustain"
- Seed / settings: seed `607`; mono WAV; `22050` Hz; `0.95` s; fade in/out and peak-normalized to `0.78`
- Iterations / chosen output / manual edits: `3`; the first pass lingered too long, so I shortened the contour and lowered the buzzy layer; manual edit time `10` min
- Problems / import / originality: getting a clear ending without making the cue cheesy took multiple passes; imported as WAV and triggered from `Level01.gd`; original failure sting

### asset_id: start_sfx

- Type: `sfx`; final: `res://assets_ai/processed/audio/sfx/start.wav`; raw: `res://assets_ai/raw/audio/start_raw.wav`
- Tool / model: OpenCode `openai/gpt-5.4` with Python `wave` procedural synthesis
- Prompt: "Short confirm/start chirp for menu accept and restart"; negative: "no UI click sample pack, no harsh beep, no voice"
- Seed / settings: seed `608`; mono WAV; `22050` Hz; `0.22` s; fade in/out and peak-normalized to `0.78`
- Iterations / chosen output / manual edits: `2`; kept the brighter arpeggio and trimmed its tail so repeated restart presses stayed clean; manual edit time `5` min
- Problems / import / originality: early pass felt too close to the jump cue; imported as WAV and triggered from menu/game-over screens; original confirm cue

### asset_id: reef_loop_music

- Type: `music`; final: `res://assets_ai/processed/audio/music/reef_loop.wav`; raw: `res://assets_ai/raw/audio/reef_loop_raw.wav`
- Tool / model: OpenCode `openai/gpt-5.4` with Python `wave` procedural synthesis
- Prompt: "12-second looping reef-arcade chiptune bed with light melody, bass pulse, and airy hat texture, non-vocal, loops cleanly"; negative: "no licensed melody references, no vocals, no large reverb wash, no clipping"
- Seed / settings: deterministic synth pattern; mono WAV; `22050` Hz; `12.0` s; normalized to `0.72`; loop mode enabled in `AudioManager.gd`
- Iterations / chosen output / manual edits: `4`; I adjusted the melody contour, reduced the arp brightness, and enabled explicit loop settings in code so the end wrapped cleanly; manual edit time `22` min
- Problems / import / originality: loop polish and balance took the most audio iteration; imported as WAV, routed to the `Music` bus, and looped in code; original melody and arrangement written for this project
