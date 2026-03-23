# LICENSES

## Tool / model: OpenCode CLI / GPT-5.4

- Vendor: OpenAI
- Plan used: local CLI assignment environment
- URL to terms/license: `https://openai.com/policies/terms-of-use/`
- License summary relevant to this class project: the generated output was produced in response to my prompts/specs for this project and then manually edited locally before shipping
- Commercial use allowed: user-generated output is generally usable by the user subject to OpenAI terms and policy; verify your own account/institution terms if submitting elsewhere
- Attribution required: not by default under the standard terms cited above
- Restrictions or unclear areas: normal OpenAI policy restrictions still apply; this repo avoids copyrighted characters, logos, and derivative franchise branding
- Date checked: `2026-03-23`

## Tool / model: Pillow

- Vendor: Pillow Team / Python Imaging Library maintainers
- Plan used: local Python package already installed in the environment
- URL to terms/license: `https://pillow.readthedocs.io/en/stable/about.html`
- License summary relevant to this class project: open-source image-processing library used only for local post-processing and sheet export
- Commercial use allowed: yes, per Pillow's open-source licensing
- Attribution required: no attribution added in-game; license notice retained here for documentation
- Restrictions or unclear areas: none relevant to this class submission
- Date checked: `2026-03-23`

## Tool / model: Python standard library (`wave`, `struct`, `math`, `random`)

- Vendor: Python Software Foundation
- Plan used: local Python runtime
- URL to terms/license: `https://docs.python.org/3/license.html`
- License summary relevant to this class project: used for procedural WAV synthesis and local automation only
- Commercial use allowed: yes
- Attribution required: no
- Restrictions or unclear areas: none relevant here
- Date checked: `2026-03-23`

## Tool / model: JetBrains Mono Nerd Font (local rasterization helper)

- Vendor: JetBrains / Nerd Fonts project
- Plan used: system-installed font package for local text rasterization into PNG UI art
- URL to terms/license: `https://www.jetbrains.com/lp/mono/` and `https://github.com/ryanoasis/nerd-fonts`
- License summary relevant to this class project: used only during local post-processing to rasterize headline text into shipping PNGs; no standalone font file is redistributed in this repo
- Commercial use allowed: typically yes, but verify the specific packaged font license in your distro/environment before reuse outside class
- Attribution required: not in-game for this submission; documented here instead
- Restrictions or unclear areas: local package provenance can vary, so re-check if you export the font file itself
- Date checked: `2026-03-23`

## Asset Originality Notes

- `player_sheet` - Checked against Bubble Bobble player silhouettes; changed the body to a reef hatchling with fin crest, bubble muzzle flare, and different torso proportions; manually reduced resemblance by avoiding the original horn/body shape.
- `enemy_sheet` - Checked against the cloned repo's robot enemy; changed to a coral shell walker with visor eye and different feet; manually widened shell/body separation to avoid the prior look.
- `bubble_orb_sheet` - Checked against common plain arcade bubble sprites; used a glass-ring reef look with moving star sparkle; manually removed any copied inner highlights.
- `bubble_trap_sheet` - Checked against the original trap orb frames; used a coral star core and warm halo instead of the source trapped sprite interior; manually boosted the core to keep the trapped state unique.
- `background_sheet` - Checked against the original cavern backgrounds and other arcade cave scenes; built original reef layers and coral forests; manually simplified clutter to keep them gameplay-safe.
- `block_tiles` - Checked against the cloned repo's stone blocks; changed to sea-glass tiles with coral trim and distinct highlight arcs; manually kept edges tile-safe and non-derivative.
- `title_screen` - Checked against Bubble Bobble logos and known arcade mastheads; used new wording (`REEF POP RALLY`) and original layout; manually shortened copy after overflow instead of mimicking franchise title treatment.
- `prompt_sheet` - Checked against generic insert-coin/start prompts; used a custom rounded badge and bubble sweep; manually balanced the overlay so the text remained readable.
- `game_over_screen` - Checked against standard franchise game-over cards; used original wording (`DIVE AGAIN`) and a different panel composition; manually trimmed copy to avoid reproducing the source screen structure.
- `hud_panel` - Checked against the original HUD and common sci-fi bars; used a reef-glass stripe pattern and warm cap; manually reduced texture density for readability.
- `life_icon` - Checked against standard heart/life emblems and the source project; derived from the new hero instead of the original sprite; manually removed extra details that felt too close to the old face.
- `project_icon` - Checked against the old config icon; used a new badge and reef hatchling portrait; manually brightened the face so it read as an original launcher icon.
- `jump_sfx` - Checked against stock game-audio packs and known arcade jumps; synthesized from scratch with no sampling; manually softened the attack to keep it distinct.
- `fire_sfx` - Checked against laser/blaster tropes; kept it bubble-glass and airy rather than weapon-like; manually reduced square-wave harshness.
- `trap_sfx` - Checked against magic-capture stock sounds; built a short crystalline shimmer from scratch; manually shortened the tail to keep it gameplay-oriented.
- `pop_sfx` - Checked against balloon-pop stock recordings; generated from noise plus synth envelope instead of sampled Foley; manually trimmed the scratchy raw burst.
- `hurt_sfx` - Checked against stock damage buzzers; synthesized a short descending buzz from scratch; manually reduced the abrasive edge.
- `clear_sfx` - Checked against recognizable arcade jingles; wrote a new four-note arpeggio; manually lowered the harmonic stack so it stayed short and original.
- `game_over_sfx` - Checked against well-known failure stings; wrote a new descending cue with no sampled material; manually shortened the ending.
- `start_sfx` - Checked against generic menu confirmation bleeps; wrote a separate confirm cue so it did not duplicate jump/fire; manually trimmed the decay.
- `reef_loop_music` - Checked against commercial chiptune themes and Bubble Bobble melodies; wrote a new 12-second loop with an original melody/bass pattern; manually rebalanced the arp and set explicit loop behavior in code.

## Non-AI Source Assets Used

- No third-party stock images, stock audio samples, or copyrighted character art were imported into the shipping asset pack.
- The old `assets/sprites/cavern/` files remain in the repo only as legacy source material from the clone and are no longer referenced by gameplay scripts.
