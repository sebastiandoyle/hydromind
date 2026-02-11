#!/usr/bin/env python3
"""
Create 5 stylized App Store screenshots for iPhone (1290x2796).
Each screenshot has a gradient background, marketing text at top,
and a centered app screenshot with rounded corners and shadow in the lower portion.
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Constants
OUTPUT_WIDTH = 1290
OUTPUT_HEIGHT = 2796
RAW_DIR = "/Users/sebastiandoyle/Developer/HydroMind/raw_screenshots"
OUT_DIR = "/Users/sebastiandoyle/Developer/HydroMind/fastlane/screenshots/en-AU"

# Brand colors
COLOR_DEEP_BLUE = (0, 102, 204)    # #0066CC
COLOR_AQUA = (0, 204, 204)         # #00CCCC

# Screenshot definitions: (raw_file, headline, subtitle, output_name)
SCREENSHOTS = [
    ("dashboard.png",   "Track Every Sip",            "Stay on top of your daily hydration goals",     "1_6.5_inch.png"),
    ("paywall.png",     "Unlock Your Potential",       "Premium insights to transform your habits",     "2_6.5_inch.png"),
    ("history.png",     "See Your Progress",           "Weekly trends and detailed analytics",           "3_6.5_inch.png"),
    ("onboarding1.png", "Stay Hydrated, Stay Sharp",   "Smart hydration tracking made simple",          "4_6.5_inch.png"),
    ("settings.png",    "Fully Customizable",          "Set goals, units, and reminders your way",      "5_6.5_inch.png"),
]

# Font setup
FONT_PATHS = [
    "/System/Library/Fonts/SFCompactRounded.ttf",
    "/System/Library/Fonts/SFNS.ttf",
    "/System/Library/Fonts/SFCompact.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
]

FONT_BOLD_PATHS = [
    "/System/Library/Fonts/SFNSRounded.ttf",
    "/System/Library/Fonts/SFCompactRounded.ttf",
    "/System/Library/Fonts/SFNS.ttf",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
]


def find_font(paths, size):
    """Try each font path and return the first that works."""
    for path in paths:
        try:
            font = ImageFont.truetype(path, size)
            return font
        except (OSError, IOError):
            continue
    return ImageFont.load_default()


def create_gradient(width, height, color_top, color_bottom):
    """Create a vertical gradient image from color_top to color_bottom."""
    img = Image.new("RGB", (width, height))
    pixels = img.load()
    for y in range(height):
        ratio = (y / height) ** 0.85
        r = int(color_top[0] + (color_bottom[0] - color_top[0]) * ratio)
        g = int(color_top[1] + (color_bottom[1] - color_top[1]) * ratio)
        b = int(color_top[2] + (color_bottom[2] - color_top[2]) * ratio)
        for x in range(width):
            pixels[x, y] = (r, g, b)
    return img


def round_corners(img, radius):
    """Apply rounded corners to an image, returning RGBA."""
    img = img.convert("RGBA")
    w, h = img.size
    mask = Image.new("L", (w, h), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), (w - 1, h - 1)], radius=radius, fill=255)
    img.putalpha(mask)
    return img


def add_shadow(img, offset=(0, 15), blur_radius=40, shadow_color=(0, 0, 0, 100)):
    """Add a drop shadow behind an RGBA image."""
    w, h = img.size
    pad = blur_radius * 2 + abs(offset[0]) + abs(offset[1])
    canvas_w = w + pad * 2
    canvas_h = h + pad * 2

    shadow = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
    shadow_shape = Image.new("RGBA", (w, h), shadow_color)
    shadow_shape.putalpha(img.getchannel("A"))
    shadow.paste(shadow_shape, (pad + offset[0], pad + offset[1]))
    shadow_blurred = shadow.filter(ImageFilter.GaussianBlur(radius=blur_radius))
    shadow_blurred.paste(img, (pad, pad), img)

    return shadow_blurred, pad


def draw_centered_text(draw, text, y, font, fill, canvas_width):
    """Draw text centered horizontally at given y position."""
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    x = (canvas_width - text_width) // 2
    draw.text((x, y), text, font=font, fill=fill)


def create_screenshot(raw_file, headline, subtitle, output_file):
    """Create a single stylized App Store screenshot."""
    print(f"  Creating {output_file}...")

    # Create gradient background
    bg = create_gradient(OUTPUT_WIDTH, OUTPUT_HEIGHT, COLOR_DEEP_BLUE, COLOR_AQUA)
    bg = bg.convert("RGBA")

    # Add a subtle decorative glow at top center
    glow = Image.new("RGBA", (OUTPUT_WIDTH, OUTPUT_HEIGHT), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    center_x = OUTPUT_WIDTH // 2
    for r in range(600, 0, -2):
        alpha = int(15 * (1 - r / 600))
        glow_draw.ellipse(
            [center_x - r, 100 - r // 2, center_x + r, 100 + r // 2],
            fill=(255, 255, 255, alpha)
        )
    bg = Image.alpha_composite(bg, glow)

    # Load and process raw screenshot
    raw_path = os.path.join(RAW_DIR, raw_file)
    raw_img = Image.open(raw_path).convert("RGBA")

    # Text area: top ~28%, screenshot area: bottom ~72%
    text_area_height = int(OUTPUT_HEIGHT * 0.28)
    screenshot_area_height = OUTPUT_HEIGHT - text_area_height

    # Calculate scale to fit screenshot with padding
    padding_x = 100
    available_width = OUTPUT_WIDTH - (padding_x * 2)
    available_height = screenshot_area_height - 60

    raw_w, raw_h = raw_img.size
    scale_w = available_width / raw_w
    scale_h = available_height / raw_h
    scale = min(scale_w, scale_h)

    new_w = int(raw_w * scale)
    new_h = int(raw_h * scale)
    raw_resized = raw_img.resize((new_w, new_h), Image.LANCZOS)

    # Round corners
    raw_rounded = round_corners(raw_resized, 50)

    # Add shadow
    raw_with_shadow, shadow_pad = add_shadow(
        raw_rounded, offset=(0, 20), blur_radius=45, shadow_color=(0, 0, 0, 120)
    )

    # Center screenshot in the lower portion
    shadow_w, shadow_h = raw_with_shadow.size
    paste_x = (OUTPUT_WIDTH - shadow_w) // 2
    paste_y = text_area_height + (screenshot_area_height - shadow_h) // 2 + 20

    if paste_y + shadow_h > OUTPUT_HEIGHT:
        paste_y = OUTPUT_HEIGHT - shadow_h

    bg.paste(raw_with_shadow, (paste_x, paste_y), raw_with_shadow)

    # Draw text
    draw = ImageDraw.Draw(bg)
    headline_font = find_font(FONT_BOLD_PATHS, 105)
    subtitle_font = find_font(FONT_PATHS, 58)

    headline_y = int(OUTPUT_HEIGHT * 0.08)
    subtitle_y = headline_y + 140

    # Headline with subtle text shadow
    draw_centered_text(draw, headline, headline_y + 4, headline_font, (0, 0, 0, 50), OUTPUT_WIDTH)
    draw_centered_text(draw, headline, headline_y, headline_font, (255, 255, 255, 255), OUTPUT_WIDTH)

    # Subtitle
    draw_centered_text(draw, subtitle, subtitle_y + 3, subtitle_font, (0, 0, 0, 40), OUTPUT_WIDTH)
    draw_centered_text(draw, subtitle, subtitle_y, subtitle_font, (255, 255, 255, 210), OUTPUT_WIDTH)

    # Save
    final = bg.convert("RGB")
    output_path = os.path.join(OUT_DIR, output_file)
    final.save(output_path, "PNG", optimize=True)
    print(f"    Saved: {output_path} ({final.size[0]}x{final.size[1]})")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print("Creating stylized App Store screenshots...")
    print(f"  Output size: {OUTPUT_WIDTH}x{OUTPUT_HEIGHT}")
    print(f"  Output dir:  {OUT_DIR}")
    print()

    for raw_file, headline, subtitle, output_file in SCREENSHOTS:
        create_screenshot(raw_file, headline, subtitle, output_file)

    print()
    print("All 5 screenshots created successfully!")


if __name__ == "__main__":
    main()
