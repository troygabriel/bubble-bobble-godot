from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "assets_ai" / "raw"
PROCESSED_DIR = ROOT / "assets_ai" / "processed"

TAU = math.tau
SAMPLE_RATE = 22050


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def load_font(size: int, italic: bool = False) -> ImageFont.FreeTypeFont:
    choices = [
        "/usr/share/fonts/TTF/JetBrainsMonoNLNerdFont-ExtraBoldItalic.ttf" if italic else "/usr/share/fonts/TTF/JetBrainsMonoNLNerdFont-ExtraBold.ttf",
        "/usr/share/fonts/TTF/JetBrainsMonoNLNerdFont-BoldItalic.ttf" if italic else "/usr/share/fonts/TTF/JetBrainsMonoNLNerdFont-Bold.ttf",
        "/usr/share/fonts/Adwaita/AdwaitaSans-Italic.ttf" if italic else "/usr/share/fonts/Adwaita/AdwaitaSans-Regular.ttf",
    ]
    for choice in choices:
        path = Path(choice)
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


def alpha_paste(base: Image.Image, overlay: Image.Image, xy: tuple[int, int]) -> None:
    base.alpha_composite(overlay, xy)


def add_noise(image: Image.Image, amount: int, seed: int) -> Image.Image:
    rng = random.Random(seed)
    noise = Image.new("L", image.size)
    pixels = noise.load()
    for y in range(image.height):
        for x in range(image.width):
            pixels[x, y] = max(0, min(255, 128 + rng.randint(-amount, amount)))
    softened = noise.filter(ImageFilter.GaussianBlur(radius=max(1, amount // 8)))
    return ImageChops.overlay(image.convert("RGBA"), Image.merge("RGBA", (softened, softened, softened, Image.new("L", image.size, 255))))


def gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    image = Image.new("RGBA", size)
    draw = ImageDraw.Draw(image)
    width, height = size
    for y in range(height):
        t = y / max(1, height - 1)
        color = tuple(int(top[i] * (1.0 - t) + bottom[i] * t) for i in range(3)) + (255,)
        draw.line((0, y, width, y), fill=color)
    return image


def quantize_rgba(image: Image.Image, colors: int) -> Image.Image:
    alpha = image.getchannel("A")
    rgb = image.convert("RGB").quantize(colors=colors, method=Image.Quantize.FASTOCTREE).convert("RGBA")
    rgb.putalpha(alpha)
    return rgb


def save_image(raw_image: Image.Image, processed_size: tuple[int, int], raw_path: Path, processed_path: Path, colors: int = 40) -> None:
    ensure_parent(raw_path)
    ensure_parent(processed_path)
    raw_image.save(raw_path)
    processed = raw_image.resize(processed_size, Image.Resampling.LANCZOS)
    processed = quantize_rgba(processed, colors=colors)
    processed.save(processed_path)


def draw_glow(draw: ImageDraw.ImageDraw, center: tuple[float, float], radius: float, color: tuple[int, int, int, int], rings: int = 4) -> None:
    cx, cy = center
    for idx in range(rings, 0, -1):
        ring_radius = radius * (idx / rings)
        alpha = int(color[3] * (idx / rings) * 0.35)
        fill = (color[0], color[1], color[2], alpha)
        draw.ellipse((cx - ring_radius, cy - ring_radius, cx + ring_radius, cy + ring_radius), fill=fill)


def coral_shape(draw: ImageDraw.ImageDraw, base_x: float, base_y: float, scale: float, palette: dict[str, tuple[int, int, int]], seed: int) -> None:
    rng = random.Random(seed)
    branches = 5
    for branch in range(branches):
        offset = (branch - (branches - 1) / 2) * 18 * scale
        height = rng.uniform(42, 78) * scale
        width = rng.uniform(8, 12) * scale
        color = palette["coral"] if branch % 2 == 0 else palette["coral_alt"]
        draw.rounded_rectangle((base_x + offset - width / 2, base_y - height, base_x + offset + width / 2, base_y), radius=width / 2, fill=color + (220,))
        tip_y = base_y - height
        draw.ellipse((base_x + offset - 12 * scale, tip_y - 10 * scale, base_x + offset + 12 * scale, tip_y + 10 * scale), fill=color + (235,))


def bubble_cluster(draw: ImageDraw.ImageDraw, width: int, height: int, seed: int, color: tuple[int, int, int]) -> None:
    rng = random.Random(seed)
    for _ in range(24):
        radius = rng.randint(6, 26)
        x = rng.randint(0, width)
        y = rng.randint(0, height)
        alpha = rng.randint(18, 60)
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), outline=color + (alpha,), width=max(1, radius // 8))


def star(draw: ImageDraw.ImageDraw, center: tuple[float, float], radius: float, inner_radius: float, fill: tuple[int, int, int, int]) -> None:
    points = []
    for idx in range(10):
        angle = -math.pi / 2 + idx * math.pi / 5
        current_radius = radius if idx % 2 == 0 else inner_radius
        points.append((center[0] + math.cos(angle) * current_radius, center[1] + math.sin(angle) * current_radius))
    draw.polygon(points, fill=fill)


def render_player_frame(size: int, stance: str, facing: int, phase: int) -> Image.Image:
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    outline = (18, 26, 38, 255)
    body = (76, 198, 180, 255)
    body_shadow = (38, 124, 126, 255)
    belly = (240, 233, 197, 255)
    fin = (246, 139, 91, 255)
    eye_white = (251, 251, 246, 255)
    pupil = (25, 31, 44, 255)
    glow = (197, 245, 248, 120)

    bob = [0, 2, 0, -1][phase % 4] if stance.startswith("run") else 0
    foot_shift = [0, -5, 2, 6][phase % 4] if stance.startswith("run") else 0
    tail_shift = [0, -3, 1, 3][phase % 4] if stance.startswith("run") else 0
    jump_shift = -6 if stance.startswith("fall") else 0
    recoil_shift = -4 if stance.startswith("recoil") else 0
    breath_shift = 3 if stance.startswith("blow") else 0

    shadow_y = size - 12
    draw.ellipse((18, shadow_y - 4, size - 18, shadow_y + 6), fill=(7, 14, 22, 72))

    base_y = 48 + bob + jump_shift
    tail = [
        (18 + recoil_shift, base_y + 14),
        (6 + recoil_shift, base_y + 4 + tail_shift),
        (4 + recoil_shift, base_y + 18 + tail_shift),
        (16 + recoil_shift, base_y + 24),
    ]
    draw.polygon(tail, fill=body_shadow, outline=outline)
    star(draw, (9 + recoil_shift, base_y + 12 + tail_shift), 8, 4, fin)

    draw.rounded_rectangle((18 + recoil_shift, base_y - 8, 48 + recoil_shift, base_y + 34), radius=15, fill=body, outline=outline, width=4)
    draw.rounded_rectangle((20 + recoil_shift, base_y + 4, 42 + recoil_shift, base_y + 29), radius=10, fill=belly, outline=(0, 0, 0, 0))

    muzzle = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    muzzle_draw = ImageDraw.Draw(muzzle)
    muzzle_draw.rounded_rectangle((40 + recoil_shift, base_y - 6, 60 + recoil_shift + breath_shift, base_y + 14), radius=9, fill=body, outline=outline, width=4)
    muzzle_draw.ellipse((46 + recoil_shift, base_y + 2, 58 + recoil_shift + breath_shift, base_y + 10), fill=belly)
    image = Image.alpha_composite(image, muzzle)

    eye_y = base_y + (2 if stance.startswith("recoil") else -1)
    draw.ellipse((43 + recoil_shift, eye_y - 6, 54 + recoil_shift, eye_y + 4), fill=eye_white, outline=outline, width=2)
    draw.ellipse((48 + recoil_shift, eye_y - 2, 53 + recoil_shift, eye_y + 3), fill=pupil)

    fin_base_y = base_y - 10
    for idx in range(3):
        spike = [
            (25 + idx * 8 + recoil_shift, fin_base_y + 6),
            (29 + idx * 8 + recoil_shift, fin_base_y - 10 - idx * 2),
            (34 + idx * 8 + recoil_shift, fin_base_y + 6),
        ]
        draw.polygon(spike, fill=fin, outline=outline)

    arm_y = base_y + (8 if stance.startswith("fall") else 10)
    arm = [
        (34 + recoil_shift, arm_y),
        (46 + recoil_shift, arm_y + (-10 if stance.startswith("blow") else -2)),
        (53 + recoil_shift + breath_shift, arm_y + 6),
        (42 + recoil_shift, arm_y + 12),
    ]
    draw.polygon(arm, fill=body_shadow, outline=outline)

    left_foot = (26 + recoil_shift, base_y + 32 + foot_shift)
    right_foot = (42 + recoil_shift, base_y + 32 - foot_shift)
    for center in (left_foot, right_foot):
        draw.ellipse((center[0] - 8, center[1] - 5, center[0] + 8, center[1] + 6), fill=fin, outline=outline, width=3)

    if stance.startswith("blow"):
        draw_glow(draw, (62 + recoil_shift, base_y + 2), 9, glow)
        draw.ellipse((56 + recoil_shift, base_y - 4, 68 + recoil_shift, base_y + 8), outline=(203, 246, 250, 210), width=3)
    elif stance.startswith("recoil"):
        star(draw, (56 + recoil_shift, base_y + 1), 8, 4, (255, 241, 175, 180))
    elif stance.startswith("fall"):
        draw.line((22 + recoil_shift, base_y + 20, 10 + recoil_shift, base_y + 2), fill=(209, 247, 255, 150), width=4)

    if facing < 0:
        image = ImageOps.mirror(image)
    return image


def render_enemy_frame(size: int, phase: int, facing: int) -> Image.Image:
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    outline = (25, 20, 30, 255)
    shell = (229, 109, 84, 255)
    shell_shadow = (172, 64, 60, 255)
    visor = (111, 234, 214, 255)
    core = (250, 236, 180, 255)
    feet = (255, 180, 92, 255)

    wobble = [0, 1, 0, -1][phase % 4]
    leg_shift = [-8, -2, 4, 8][phase % 4]

    draw.ellipse((16, size - 18, size - 16, size - 8), fill=(7, 14, 22, 80))
    draw.rounded_rectangle((16, 24 + wobble, 48, 56 + wobble), radius=16, fill=shell, outline=outline, width=4)
    draw.rounded_rectangle((18, 30 + wobble, 46, 54 + wobble), radius=13, fill=shell_shadow)
    draw.rounded_rectangle((24, 34 + wobble, 42, 49 + wobble), radius=8, fill=core)
    draw.rounded_rectangle((34, 27 + wobble, 56, 49 + wobble), radius=10, fill=shell, outline=outline, width=4)
    draw.rounded_rectangle((38, 31 + wobble, 52, 44 + wobble), radius=6, fill=visor)
    draw.ellipse((42, 35 + wobble, 48, 41 + wobble), fill=(20, 33, 38, 255))

    for idx in range(3):
        spike = [
            (19 + idx * 9, 27 + wobble),
            (24 + idx * 9, 14 - idx),
            (29 + idx * 9, 27 + wobble),
        ]
        draw.polygon(spike, fill=feet, outline=outline)

    leg_positions = [(22, 58), (32, 60), (42, 58), (52, 60)]
    for index, (x, y) in enumerate(leg_positions):
        stretch = leg_shift if index % 2 == 0 else -leg_shift
        draw.line((x, y + wobble, x + stretch * 0.35, y + 10), fill=outline, width=4)
        draw.ellipse((x - 5 + stretch * 0.35, y + 8, x + 5 + stretch * 0.35, y + 16), fill=feet, outline=outline, width=2)

    if facing > 0:
        image = ImageOps.mirror(image)
    return image


def render_orb_frame(size: int, phase: int) -> Image.Image:
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    center = size / 2
    radius = size * 0.32 + phase * 0.18
    draw_glow(draw, (center, center), radius * 1.4, (147, 240, 255, 110), rings=5)
    draw.ellipse((center - radius, center - radius, center + radius, center + radius), outline=(192, 245, 255, 235), width=max(2, size // 14), fill=(137, 211, 248, 55))
    draw.ellipse((center - radius * 0.55, center - radius * 0.72, center + radius * 0.1, center - radius * 0.05), fill=(255, 255, 255, 80))
    sparkle_x = center + math.cos(phase * 0.7) * radius * 0.35
    sparkle_y = center - math.sin(phase * 0.9) * radius * 0.25
    star(draw, (sparkle_x, sparkle_y), size * 0.11, size * 0.05, (255, 255, 255, 190))
    return image


def render_trap_frame(size: int, phase: int) -> Image.Image:
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    center = size / 2
    radius = size * 0.34
    hue_shift = phase * 8
    outer = (255, min(235, 180 + hue_shift), 208, 220)
    inner = (255, 251, 215, 90)
    draw_glow(draw, (center, center), radius * 1.55, (255, 186, 203, 120), rings=6)
    draw.ellipse((center - radius, center - radius, center + radius, center + radius), outline=outer, width=max(2, size // 18), fill=inner)
    draw.ellipse((center - radius * 0.52, center - radius * 0.52, center + radius * 0.52, center + radius * 0.52), fill=(255, 216, 140, 46))
    star(draw, (center, center + 1), size * 0.18, size * 0.09, (222, 94, 84, 170))
    ring_offset = math.sin(phase * 0.7) * size * 0.04
    draw.arc((center - radius * 0.72, center - radius * 0.76 + ring_offset, center + radius * 0.72, center + radius * 0.56 + ring_offset), start=198, end=336, fill=(255, 255, 255, 185), width=max(2, size // 22))
    return image


def render_background_cell(size: tuple[int, int], palette: dict[str, tuple[int, int, int]], seed: int) -> Image.Image:
    image = gradient(size, palette["sky_top"], palette["sky_bottom"])
    draw = ImageDraw.Draw(image, "RGBA")
    width, height = size

    bubble_cluster(draw, width, height, seed, palette["bubble"])

    for layer in range(5):
        y = height * (0.45 + layer * 0.12)
        alpha = 70 + layer * 24
        color = palette["reef"] + (alpha,)
        points = []
        for idx in range(9):
            x = idx * width / 8
            wobble = math.sin(idx * 0.9 + layer * 1.5 + seed * 0.01) * 18
            points.append((x, y + wobble))
        points.append((width, height))
        points.append((0, height))
        draw.polygon(points, fill=color)

    for idx in range(7):
        coral_shape(draw, 80 + idx * 58, height - 24, 1.0 + (idx % 3) * 0.14, palette, seed + idx)

    for idx in range(6):
        cx = 70 + idx * 72
        cy = 54 + int(math.sin(seed * 0.17 + idx) * 14)
        draw_glow(draw, (cx, cy), 18 + idx % 3 * 4, palette["bubble"] + (110,), rings=4)
    return image


def render_screen(size: tuple[int, int], palette: dict[str, tuple[int, int, int]], title: str, subtitle: str, mood: str, seed: int) -> Image.Image:
    image = gradient(size, palette["sky_top"], palette["sky_bottom"])
    draw = ImageDraw.Draw(image, "RGBA")
    width, height = size

    for idx in range(8):
        stripe_x = idx * 122 - 30
        stripe_color = palette["stripe"] + (38 + idx * 6,)
        draw.polygon([(stripe_x, 0), (stripe_x + 90, 0), (stripe_x + 150, height), (stripe_x + 40, height)], fill=stripe_color)

    for idx in range(12):
        center = (70 + idx * 80, 60 + (idx % 3) * 28)
        draw_glow(draw, center, 28 + (idx % 2) * 8, palette["bubble"] + (85,), rings=4)

    for idx in range(10):
        coral_shape(draw, 54 + idx * 92, height - 30, 1.18 + (idx % 2) * 0.14, palette, seed + idx * 7)

    panel = Image.new("RGBA", (640, 220), (0, 0, 0, 0))
    panel_draw = ImageDraw.Draw(panel, "RGBA")
    panel_draw.rounded_rectangle((0, 0, 640, 220), radius=42, fill=(8, 16, 30, 194), outline=(196, 247, 248, 72), width=4)
    panel_draw.rounded_rectangle((0, 0, 640, 24), radius=42, fill=palette["accent"] + (230,))
    panel = panel.filter(ImageFilter.GaussianBlur(radius=0.3))
    alpha_paste(image, panel, (160, 44))

    title_font = load_font(88, italic=True)
    subtitle_font = load_font(28)
    mood_font = load_font(30, italic=True)

    draw.text((192, 92), title, font=title_font, fill=(248, 248, 238, 255), stroke_width=5, stroke_fill=(12, 26, 44, 255))
    draw.text((196, 188), subtitle, font=subtitle_font, fill=(196, 238, 246, 255), stroke_width=1, stroke_fill=(10, 18, 26, 255))
    draw.text((198, 228), mood, font=mood_font, fill=palette["accent"] + (255,), stroke_width=2, stroke_fill=(16, 18, 25, 255))

    draw.rounded_rectangle((592, 318, 904, 472), radius=26, fill=(8, 16, 30, 190), outline=(255, 255, 255, 46), width=3)
    draw.rounded_rectangle((592, 318, 904, 332), radius=26, fill=palette["accent"] + (230,))
    draw.text((620, 360), "REBUILD THE ROOM", font=load_font(30), fill=(248, 244, 228, 255))
    draw.text((620, 400), "Trap, pop, repeat.", font=load_font(24), fill=(208, 229, 237, 255))
    draw.text((620, 432), "Original AI-generated pack", font=load_font(20), fill=(255, 207, 150, 255))
    return image


def render_prompt_frame(size: tuple[int, int], phase: int, text: str) -> Image.Image:
    width, height = size
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    pulse = 18 + int(abs(math.sin(phase * 0.6)) * 12)
    accent = (97 + phase * 8, 224 - phase * 3, 214, 255)
    draw.rounded_rectangle((8, 8, width - 8, height - 8), radius=28, fill=(7, 15, 30, 210), outline=accent, width=4)
    draw.rounded_rectangle((20, 18, width - 20, height - 18), radius=22, outline=(255, 255, 255, 42), width=2)
    for idx in range(5):
        x = 34 + idx * 58 + phase * 6
        draw.line((x, 18, x + 40, height - 18), fill=(255, 255, 255, 18), width=3)
    draw_glow(draw, (width * 0.5, height * 0.5), pulse + 18, (128, 251, 241, 100), rings=5)
    font = load_font(34, italic=True)
    bbox = draw.textbbox((0, 0), text, font=font, stroke_width=3)
    text_x = (width - (bbox[2] - bbox[0])) // 2
    text_y = (height - (bbox[3] - bbox[1])) // 2 - 4
    draw.text((text_x, text_y), text, font=font, fill=(250, 247, 239, 255), stroke_width=3, stroke_fill=(11, 22, 33, 255))
    return image


def render_hud_panel(size: tuple[int, int]) -> Image.Image:
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    width, height = size
    draw.rounded_rectangle((0, 0, width - 1, height - 1), radius=22, fill=(9, 14, 28, 210), outline=(212, 247, 248, 48), width=3)
    draw.rounded_rectangle((0, 0, width - 1, 14), radius=22, fill=(255, 200, 112, 245))
    for idx in range(12):
        x = 18 + idx * 30
        draw.line((x, 14, x + 18, height - 12), fill=(255, 255, 255, 14), width=2)
    draw.rounded_rectangle((16, 22, width - 16, height - 16), radius=16, outline=(255, 255, 255, 24), width=2)
    return image


def render_life_icon(size: int) -> Image.Image:
    frame = render_player_frame(size, "still", 1, 0)
    bubble = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(bubble)
    draw_glow(draw, (size * 0.5, size * 0.52), size * 0.42, (140, 246, 255, 100), rings=5)
    draw.ellipse((3, 3, size - 3, size - 3), outline=(192, 245, 255, 200), width=2, fill=(106, 180, 228, 28))
    alpha_paste(bubble, frame.resize((int(size * 0.9), int(size * 0.9)), Image.Resampling.LANCZOS), (int(size * 0.05), int(size * 0.05)))
    return bubble


def render_project_icon(size: int) -> Image.Image:
    bg = gradient((size, size), (18, 46, 70), (7, 13, 25))
    draw = ImageDraw.Draw(bg, "RGBA")
    draw_glow(draw, (size * 0.5, size * 0.5), size * 0.42, (108, 238, 235, 110), rings=5)
    for idx in range(7):
        draw.arc((10 + idx * 3, 10 + idx * 3, size - 10 - idx * 3, size - 10 - idx * 3), start=15 + idx * 10, end=190 + idx * 12, fill=(255, 255, 255, 15 + idx * 6), width=2)
    sprite = render_player_frame(int(size * 0.82), "still", 1, 0)
    alpha_paste(bg, sprite, (int(size * 0.08), int(size * 0.14)))
    return bg


def compose_sheet(frames: list[Image.Image], columns: int, rows: int, cell_size: tuple[int, int]) -> Image.Image:
    width, height = cell_size
    sheet = Image.new("RGBA", (columns * width, rows * height), (0, 0, 0, 0))
    for idx, frame in enumerate(frames):
        x = (idx % columns) * width
        y = (idx // columns) * height
        alpha_paste(sheet, frame, (x, y))
    return sheet


def write_wav(path: Path, samples: list[float], stereo: bool = False) -> None:
    ensure_parent(path)
    with wave.open(str(path), "wb") as wav_file:
        wav_file.setnchannels(2 if stereo else 1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        frames = bytearray()
        if stereo:
            for left, right in samples:
                frames += struct.pack("<hh", max(-32767, min(32767, int(left * 32767))), max(-32767, min(32767, int(right * 32767))))
        else:
            for sample in samples:
                frames += struct.pack("<h", max(-32767, min(32767, int(sample * 32767))))
        wav_file.writeframes(frames)


def apply_fade(samples: list[float], fade_in: float, fade_out: float) -> list[float]:
    total = len(samples)
    result = []
    for index, sample in enumerate(samples):
        in_gain = 1.0 if fade_in <= 0 else min(1.0, index / max(1, int(fade_in * SAMPLE_RATE)))
        out_gain = 1.0
        fade_out_samples = int(fade_out * SAMPLE_RATE)
        if fade_out_samples > 0 and index >= total - fade_out_samples:
            out_gain = max(0.0, (total - index) / fade_out_samples)
        result.append(sample * in_gain * out_gain)
    return result


def normalize(samples: list[float], target: float = 0.8) -> list[float]:
    peak = max(0.001, max(abs(sample) for sample in samples))
    gain = target / peak
    return [max(-0.98, min(0.98, sample * gain)) for sample in samples]


def synth_sfx(name: str, duration: float, seed: int) -> tuple[list[float], list[float]]:
    rng = random.Random(seed)
    total = int(duration * SAMPLE_RATE)
    raw = []
    for index in range(total):
        t = index / SAMPLE_RATE
        progress = t / duration
        sample = 0.0
        if name == "jump":
            freq = 340 + progress * 240
            sample = math.sin(TAU * freq * t) * (1.0 - progress) ** 1.4
            sample += 0.25 * math.sin(TAU * (freq * 2.01) * t) * (1.0 - progress) ** 2.0
        elif name == "fire":
            freq = 460 - progress * 210
            sample = math.sin(TAU * freq * t) * (1.0 - progress) ** 1.9
            sample += 0.18 * (1 if math.sin(TAU * freq * 0.5 * t) >= 0 else -1) * (1.0 - progress) ** 2.2
        elif name == "trap":
            freq = 300 + math.sin(progress * math.pi * 3.0) * 120
            sample = math.sin(TAU * freq * t) * (1.0 - progress) ** 1.25
            sample += 0.32 * math.sin(TAU * (freq * 1.5) * t + 0.4) * (1.0 - progress) ** 1.8
        elif name == "pop":
            burst = (rng.random() * 2.0 - 1.0) * (1.0 - progress) ** 3.0
            sample = burst * 0.5 + math.sin(TAU * (260 - progress * 120) * t) * (1.0 - progress) ** 2.8 * 0.4
        elif name == "hurt":
            freq = 320 - progress * 190
            square = 1.0 if math.sin(TAU * freq * t) >= 0 else -1.0
            sample = square * (1.0 - progress) ** 1.2 * 0.48
            sample += math.sin(TAU * (freq * 0.5) * t) * (1.0 - progress) ** 1.5 * 0.3
        elif name == "clear":
            notes = [392.0, 523.25, 659.25, 783.99]
            segment = int(progress * len(notes))
            freq = notes[min(segment, len(notes) - 1)]
            sample = math.sin(TAU * freq * t) * (1.0 - progress * 0.35)
            sample += 0.2 * math.sin(TAU * freq * 2.0 * t)
        elif name == "game_over":
            freq = 310 - progress * 180
            sample = math.sin(TAU * freq * t) * (1.0 - progress) ** 0.9
            sample += 0.18 * (1.0 if math.sin(TAU * freq * 0.49 * t) >= 0 else -1.0) * (1.0 - progress) ** 1.6
        elif name == "start":
            notes = [523.25, 659.25, 783.99]
            step = min(len(notes) - 1, int(progress * len(notes)))
            freq = notes[step]
            sample = math.sin(TAU * freq * t) * (1.0 - progress) ** 1.4
        raw.append(sample * 0.55)
    processed = normalize(apply_fade(raw, 0.004, 0.03), target=0.78)
    return raw, processed


NOTE_FREQUENCIES = {
    "C4": 261.63,
    "D4": 293.66,
    "E4": 329.63,
    "F4": 349.23,
    "G4": 392.00,
    "A4": 440.00,
    "B4": 493.88,
    "C5": 523.25,
    "D5": 587.33,
    "E5": 659.25,
    "G5": 783.99,
    "A5": 880.00,
}


def synth_music(duration: float = 12.0) -> tuple[list[float], list[float]]:
    total = int(duration * SAMPLE_RATE)
    beat = 0.25
    melody = ["E5", "G5", "A5", "G5", "E5", "D5", "C5", "D5", "E5", "G5", "A5", "C5", "E5", "D5", "C5", "B4"]
    bass = ["A4", "A4", "F4", "F4", "G4", "G4", "E4", "E4"]
    processed = []
    raw = []
    for index in range(total):
        t = index / SAMPLE_RATE
        melody_step = int((t / beat)) % len(melody)
        bass_step = int((t / (beat * 2))) % len(bass)
        beat_progress = (t % beat) / beat
        bass_progress = (t % (beat * 2)) / (beat * 2)

        melody_freq = NOTE_FREQUENCIES[melody[melody_step]]
        bass_freq = NOTE_FREQUENCIES[bass[bass_step]] * 0.5
        chord_root = NOTE_FREQUENCIES[bass[bass_step]]
        arp_freq = chord_root * [1.0, 1.5, 2.0, 1.5][int((t / (beat / 2)) % 4)]

        lead_env = (1.0 - beat_progress) ** 1.2
        bass_env = (1.0 - bass_progress) ** 0.8
        hat_env = max(0.0, 1.0 - ((t % (beat / 2)) / (beat / 2)) * 4.0)

        lead = math.sin(TAU * melody_freq * t) * lead_env * 0.26
        arp = (1.0 if math.sin(TAU * arp_freq * t) >= 0 else -1.0) * lead_env * 0.08
        bass_voice = math.sin(TAU * bass_freq * t) * bass_env * 0.24
        hat_noise = math.sin(index * 12.9898) * hat_env * 0.03

        sample = lead + arp + bass_voice + hat_noise
        raw.append(sample * 0.7)
        processed.append(sample)
    processed = normalize(apply_fade(processed, 0.02, 0.02), target=0.72)
    return raw, processed


def build_visuals() -> None:
    player_frames = []
    player_order = [
        ("still", 1, 0),
        ("run", -1, 0),
        ("run", -1, 1),
        ("run", -1, 2),
        ("run", -1, 3),
        ("run", 1, 0),
        ("run", 1, 1),
        ("run", 1, 2),
        ("run", 1, 3),
        ("blow", -1, 0),
        ("blow", 1, 0),
        ("recoil", -1, 0),
        ("recoil", 1, 0),
        ("fall", -1, 0),
        ("fall", 1, 0),
    ]
    for stance, facing, phase in player_order:
        player_frames.append(render_player_frame(96, stance, facing, phase))
    player_sheet = compose_sheet(player_frames, 5, 3, (96, 96))
    save_image(player_sheet, (320, 192), RAW_DIR / "visual/player_sheet_raw.png", PROCESSED_DIR / "visual/player/player_sheet.png", colors=48)

    enemy_frames = [render_enemy_frame(96, phase, -1) for phase in range(4)] + [render_enemy_frame(96, phase, 1) for phase in range(4)]
    enemy_sheet = compose_sheet(enemy_frames, 4, 2, (96, 96))
    save_image(enemy_sheet, (256, 128), RAW_DIR / "visual/enemy_sheet_raw.png", PROCESSED_DIR / "visual/enemy/enemy_sheet.png", colors=44)

    orb_frames = [render_orb_frame(48, phase) for phase in range(7)]
    orb_sheet = compose_sheet(orb_frames, 7, 1, (48, 48))
    save_image(orb_sheet, (224, 32), RAW_DIR / "visual/bubble_orb_sheet_raw.png", PROCESSED_DIR / "visual/bubble/orb_sheet.png", colors=32)

    trap_frames = [render_trap_frame(96, phase) for phase in range(8)]
    trap_sheet = compose_sheet(trap_frames, 8, 1, (96, 96))
    save_image(trap_sheet, (512, 64), RAW_DIR / "visual/bubble_trap_sheet_raw.png", PROCESSED_DIR / "visual/bubble/trap_sheet.png", colors=34)

    background_palettes = [
        {"sky_top": (10, 36, 58), "sky_bottom": (5, 11, 22), "reef": (16, 67, 74), "bubble": (98, 212, 230), "coral": (232, 118, 82), "coral_alt": (255, 179, 94), "stripe": (171, 236, 245), "accent": (255, 192, 96)},
        {"sky_top": (52, 39, 78), "sky_bottom": (14, 12, 28), "reef": (68, 61, 116), "bubble": (164, 181, 255), "coral": (255, 126, 144), "coral_alt": (255, 183, 118), "stripe": (202, 199, 255), "accent": (255, 143, 105)},
        {"sky_top": (16, 60, 52), "sky_bottom": (8, 20, 19), "reef": (28, 92, 74), "bubble": (146, 246, 215), "coral": (255, 164, 104), "coral_alt": (251, 210, 129), "stripe": (195, 255, 234), "accent": (247, 224, 123)},
        {"sky_top": (54, 23, 30), "sky_bottom": (16, 8, 16), "reef": (87, 42, 58), "bubble": (254, 180, 215), "coral": (255, 120, 110), "coral_alt": (252, 183, 114), "stripe": (255, 214, 223), "accent": (255, 205, 118)},
    ]
    cells = [render_background_cell((480, 270), background_palettes[idx], 140 + idx * 17) for idx in range(4)]
    background_sheet = compose_sheet(cells, 2, 2, (480, 270))
    raw_bg = add_noise(background_sheet, amount=18, seed=177)
    raw_bg.save(RAW_DIR / "visual/background_sheet_raw.png")
    ensure_parent(PROCESSED_DIR / "visual/environment/background_sheet.png")
    quantize_rgba(background_sheet, colors=64).save(PROCESSED_DIR / "visual/environment/background_sheet.png")

    block_sheet = Image.new("RGBA", (128, 32), (0, 0, 0, 0))
    for idx, palette in enumerate(background_palettes):
        tile = Image.new("RGBA", (32, 32), palette["reef"] + (255,))
        tile_draw = ImageDraw.Draw(tile, "RGBA")
        tile_draw.rounded_rectangle((1, 1, 30, 30), radius=7, fill=tuple(max(0, c - 12) for c in palette["reef"]) + (255,), outline=palette["accent"] + (220,), width=2)
        tile_draw.arc((5, 4, 27, 26), start=180, end=350, fill=palette["bubble"] + (210,), width=2)
        tile_draw.line((6, 24, 26, 10), fill=(255, 255, 255, 40), width=2)
        tile_draw.ellipse((8, 8, 13, 13), fill=palette["coral"] + (210,))
        alpha_paste(block_sheet, tile, (idx * 32, 0))
    raw_block = block_sheet.resize((256, 64), Image.Resampling.NEAREST)
    raw_block.save(RAW_DIR / "visual/block_tiles_raw.png")
    block_sheet.save(PROCESSED_DIR / "visual/environment/block_tiles.png")

    title = render_screen((960, 540), background_palettes[0], "REEF POP RALLY", "Bubble-trap arcade study in a neon lagoon", "Press start and clear the lagoon.", 212)
    title_raw = add_noise(title, amount=14, seed=221)
    title_raw.save(RAW_DIR / "visual/title_screen_raw.png")
    quantize_rgba(title, colors=72).save(PROCESSED_DIR / "visual/ui/title_screen.png")

    over = render_screen((960, 540), background_palettes[3], "DIVE AGAIN", "The reef wants one more round", "Retry the room with the same rules.", 318)
    over_raw = add_noise(over, amount=16, seed=319)
    over_raw.save(RAW_DIR / "visual/game_over_screen_raw.png")
    quantize_rgba(over, colors=72).save(PROCESSED_DIR / "visual/ui/game_over_screen.png")

    prompt_frames = [render_prompt_frame((320, 96), idx, "PRESS START") for idx in range(10)]
    prompt_sheet = compose_sheet(prompt_frames, 5, 2, (320, 96))
    save_image(prompt_sheet, (1600, 192), RAW_DIR / "visual/prompt_sheet_raw.png", PROCESSED_DIR / "visual/ui/prompt_sheet.png", colors=40)

    hud_panel = render_hud_panel((430, 96))
    hud_panel_raw = add_noise(hud_panel, amount=10, seed=411)
    hud_panel_raw.save(RAW_DIR / "visual/hud_panel_raw.png")
    quantize_rgba(hud_panel, colors=32).save(PROCESSED_DIR / "visual/ui/hud_panel.png")

    life_icon = render_life_icon(48)
    save_image(life_icon, (32, 32), RAW_DIR / "visual/life_icon_raw.png", PROCESSED_DIR / "visual/ui/life_icon.png", colors=30)

    project_icon = render_project_icon(192)
    save_image(project_icon, (128, 128), RAW_DIR / "visual/project_icon_raw.png", PROCESSED_DIR / "visual/ui/project_icon.png", colors=36)


def build_audio() -> None:
    sfx_specs = [
        ("jump", 0.18, 601),
        ("fire", 0.20, 602),
        ("trap", 0.30, 603),
        ("pop", 0.16, 604),
        ("hurt", 0.36, 605),
        ("clear", 0.70, 606),
        ("game_over", 0.95, 607),
        ("start", 0.22, 608),
    ]
    for name, duration, seed in sfx_specs:
        raw, processed = synth_sfx(name, duration, seed)
        write_wav(RAW_DIR / f"audio/{name}_raw.wav", raw)
        write_wav(PROCESSED_DIR / f"audio/sfx/{name}.wav", processed)

    music_raw, music_processed = synth_music(12.0)
    write_wav(RAW_DIR / "audio/reef_loop_raw.wav", music_raw)
    write_wav(PROCESSED_DIR / "audio/music/reef_loop.wav", music_processed)


def main() -> None:
    build_visuals()
    build_audio()


if __name__ == "__main__":
    main()
