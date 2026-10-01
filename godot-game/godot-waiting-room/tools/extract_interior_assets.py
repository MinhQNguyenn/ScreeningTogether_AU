#!/usr/bin/env python3
"""Extract categorized 48x48 pixel-art objects from VectoRaith's atlas sheets.

The 16x16 sheets are used only as topology maps. Pixel data is copied from the
corresponding 48x48 Classic sheets, so no resampling is applied to exported art.
Original atlas files are never modified.
"""

from __future__ import annotations

import csv
import json
import shutil
from collections import Counter
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = PROJECT_ROOT / "assets" / "Interior Tileset Pack - Essentials"
OUTPUT_ROOT = PROJECT_ROOT / "assets" / "extracted_objects"
BASE_TILE_SIZE = 16
EXPORT_TILE_SIZE = 48
SCALE = EXPORT_TILE_SIZE // BASE_TILE_SIZE
MIN_COMPONENT_PIXELS = 16
PADDING = SCALE


PALETTES = {
    "1": {
        "default": "vectoraith_tileset_interior_essentials_1_48x48.png",
        "birch": "vectoraith_tileset_interior_essentials_1_birch_48x48.png",
        "ebony": "vectoraith_tileset_interior_essentials_1_ebony_48x48.png",
        "redwood": "vectoraith_tileset_interior_essentials_1_redwood_48x48.png",
    },
    "2": {
        "default": "vectoraith_tileset_interior_essentials_2_48x48.png",
        "birch": "vectoraith_tileset_interior_essentials_2_birch_48x48.png",
        "ebony": "vectoraith_tileset_interior_essentials_2_ebony_48x48.png",
        "redwood": "vectoraith_tileset_interior_essentials_2_redwood_48x48.png",
    },
    "3": {
        "default": "vectoraith_tileset_interior_essentials_3_48x48.png",
        "birch": "vectoraith_tileset_interior_essentials_3_birch_48x48.png",
        "ebony": "vectoraith_tileset_interior_essentials_3_ebony_48x48.png",
        "redwood": "vectoraith_tileset_interior_essentials_3_redwood_48x48.png",
    },
    "electronics": {
        "default": "vectoraith_tileset_interior_essentials_electronics_48x48.png",
        "birch_white": "vectoraith_tileset_interior_essentials_electronics_birch-white_48x48.png",
        "ebony_metallic": "vectoraith_tileset_interior_essentials_electronics_ebony-metallic_48x48.png",
        "redwood_black": "vectoraith_tileset_interior_essentials_electronics_redwood-black_48x48.png",
    },
}


BASE_FILES = {
    "1": "vectoraith_tileset_interior_essentials_1.png",
    "2": "vectoraith_tileset_interior_essentials_2.png",
    "3": "vectoraith_tileset_interior_essentials_3.png",
    "electronics": "vectoraith_tileset_interior_essentials_electronics.png",
}


# Broad semantic groups are intentionally stable across colour variants. The
# component number is retained in each filename so every crop is traceable.
CATEGORY_IDS = {
    "1": {
        "electronics": {1, 18, 34, 36, 43, 55},
        "cabinets_and_shelves": {2, 13, 14, 25, 26, 29, 30, 31, 32, 46, 74},
        "doors_and_windows": {3, 4, 8, 9, 51},
        "rugs": {5},
        "chairs": {6, 42, 44, 45, 53, 54, 59, 76},
        "storage_containers": {7, 24, 75},
        "fireplaces": {10},
        "wall_decor_and_signs": {11, 12, 15, 16, 17, 19, 20, 21, 22, 28, 60, 61, 62, 63, 64, 65, 66, 67, 82, 83},
        "plants_and_flowers": {23, 35, 48, 49, 72, 79, 80, 81, 85},
        "lighting": {33, 38, 39, 40, 68, 70, 78},
        "sofas_and_beds": {41, 56, 57, 69, 71, 77, 84},
        "tables": {50, 58, 73},
    },
    "2": {
        "electronics": {1, 2},
        "kitchen": {3, 6, 7, 11, 16, 19, 23, 26},
        "chairs": {4, 21, 27, 36},
        "storage_containers": {5, 17, 18, 24, 28, 30, 40, 41, 42, 44, 45, 46, 47, 48, 51, 52, 53, 54, 55},
        "plants_and_flowers": {12, 13, 15, 22, 34, 35, 50, 56},
        "food_and_tableware": {9, 10, 20, 25, 33, 43},
        "wall_decor_and_signs": {31, 32, 72},
        "lighting": {29, 57},
        "tables": {49, 58, 59, 60},
        "doors_and_windows": {61, 62, 63, 64},
        "cabinets_and_shelves": {65, 66, 67, 68, 69, 70, 71, 73, 74},
    },
    "3": {
        "room_structures": {1, 13},
        "fireplaces": {2, 14, 31, 54, 55},
        "tools_and_weapons": {3, 4, 8, 10, 11, 16, 17, 18, 23, 26, 27, 28, 32, 34, 37, 42, 43, 44, 48, 49, 86, 91},
        "cabinets_and_shelves": {5, 6, 9, 20, 47, 58, 61, 65, 66, 67, 68, 69, 70},
        "doors_and_windows": {7, 50, 51, 52, 53},
        "storage_containers": {12, 15, 24, 29, 30, 33, 35, 36, 38, 39, 41, 45, 46, 56, 57, 59, 60, 62, 63, 75},
        "wall_decor_and_signs": {19, 21, 22, 64, 84, 85, 90},
        "lighting": {72},
        "plants_and_flowers": {74, 82, 87},
        "tables": {71, 76, 83, 88, 89},
        "chairs": {77, 78, 79, 80, 81},
        "food_and_tableware": {73},
    },
    "electronics": {
        "chairs": {1, 4, 8, 9, 71, 73, 80, 90, 98, 103},
        "cabinets_and_shelves": {16, 17, 20, 32, 46, 66, 72, 74, 78, 79, 81, 88, 89, 96, 97, 99, 101, 102, 104},
        "tables": {25, 26, 30, 31, 48, 49, 60, 61},
        "wall_decor_and_signs": {10, 14, 22, 27, 28, 37, 41, 47, 53, 54, 59, 63, 64, 65, 75, 76, 77, 84, 107, 108, 109},
    },
}


CATEGORY_STEMS = {
    "cabinets_and_shelves": "cabinet_shelf",
    "chairs": "chair",
    "doors_and_windows": "door_window",
    "electronics": "electronic_device",
    "fireplaces": "fireplace",
    "food_and_tableware": "food_tableware",
    "kitchen": "kitchen_fixture",
    "lighting": "light",
    "misc_props": "misc_prop",
    "plants_and_flowers": "plant_flower",
    "room_structures": "room_structure",
    "rugs": "rug",
    "sofas_and_beds": "sofa_bed",
    "storage_containers": "storage_container",
    "tables": "table",
    "tools_and_weapons": "tool_weapon",
    "wall_decor_and_signs": "wall_decor_sign",
}


def category_lookup(sheet: str) -> dict[int, str]:
    result: dict[int, str] = {}
    for category, ids in CATEGORY_IDS.get(sheet, {}).items():
        for component_id in ids:
            if component_id in result:
                raise ValueError(f"Duplicate category for {sheet} component {component_id}")
            result[component_id] = category
    return result


def components_for(base_path: Path) -> list[dict[str, object]]:
    image = Image.open(base_path).convert("RGBA")
    alpha = np.asarray(image, dtype=np.uint8)[:, :, 3]
    count, labels, stats, _ = cv2.connectedComponentsWithStats(
        (alpha > 0).astype(np.uint8), connectivity=8
    )
    components: list[dict[str, object]] = []
    component_id = 0
    for label_id in range(1, count):
        x, y, width, height, area = (int(value) for value in stats[label_id])
        if area < MIN_COMPONENT_PIXELS:
            continue
        component_id += 1
        mask = Image.fromarray(
            np.where(labels == label_id, 255, 0).astype(np.uint8), mode="L"
        )
        components.append(
            {
                "component_id": component_id,
                "bbox": (x, y, x + width, y + height),
                "area": area,
                "mask": mask,
            }
        )
    return components


def crop_component(
    source: Image.Image, component: dict[str, object]
) -> tuple[Image.Image, tuple[int, int, int, int]]:
    mask = component["mask"]
    assert isinstance(mask, Image.Image)
    scaled_mask = mask.resize(source.size, Image.Resampling.NEAREST)
    source_alpha = source.getchannel("A")
    final_alpha = Image.fromarray(
        np.minimum(
            np.asarray(source_alpha, dtype=np.uint8),
            np.asarray(scaled_mask, dtype=np.uint8),
        ),
        mode="L",
    )
    isolated = source.copy()
    isolated.putalpha(final_alpha)

    left, top, right, bottom = component["bbox"]
    crop_box = (
        max(0, int(left) * SCALE - PADDING),
        max(0, int(top) * SCALE - PADDING),
        min(source.width, int(right) * SCALE + PADDING),
        min(source.height, int(bottom) * SCALE + PADDING),
    )
    return isolated.crop(crop_box), crop_box


def make_preview(default_exports: list[tuple[Path, str]]) -> None:
    if not default_exports:
        return
    columns = 12
    cell_width = 150
    cell_height = 126
    rows = (len(default_exports) + columns - 1) // columns
    preview = Image.new(
        "RGBA", (columns * cell_width, rows * cell_height), (31, 36, 44, 255)
    )
    draw = ImageDraw.Draw(preview)
    for index, (path, label) in enumerate(default_exports):
        sprite = Image.open(path).convert("RGBA")
        sprite.thumbnail((112, 88), Image.Resampling.NEAREST)
        column = index % columns
        row = index // columns
        x = column * cell_width + (cell_width - sprite.width) // 2
        y = row * cell_height + 4 + (88 - sprite.height) // 2
        preview.alpha_composite(sprite, (x, y))
        draw.text(
            (column * cell_width + 4, row * cell_height + 96),
            label[:23],
            fill=(232, 238, 245, 255),
        )
    catalog_dir = OUTPUT_ROOT / "_catalog"
    catalog_dir.mkdir(parents=True, exist_ok=True)
    preview.save(catalog_dir / "catalog_default.png")


def write_readme(total: int, counts: Counter[str]) -> None:
    category_lines = "\n".join(
        f"- `{category}/`: {count} PNG files"
        for category, count in sorted(counts.items())
    )
    text = f"""# Extracted Interior Objects

Generated from the 48x48 Classic edition of VectoRaith's **Interior Tileset
Pack - Essentials**. The source atlases remain unchanged.

- Exported PNG files: {total}
- Colour families: default, birch/birch-white, ebony/ebony-metallic,
  redwood/redwood-black. A variant is skipped when that source region is empty.
- Each PNG has a transparent background and one connected visual sprite group.
- The source sheet and connected-component number are retained in filenames.
- `_catalog/catalog_default.png` is a visual index of the default variants.
- `manifest.csv` and `manifest.json` contain source and crop metadata.

## Categories

{category_lines}

## Naming

Example: `chair_set1_c006_birch.png`

- `chair`: broad semantic type
- `set1`: source atlas set
- `c006`: stable connected-component number in that set
- `birch`: colour/material variant

## License reminder

These files are derivatives of the purchased VectoRaith asset pack. They may be
used and modified in the game project, but must not be redistributed, resold,
or sublicensed as standalone assets. Credit remains with VectoRaith.
"""
    (OUTPUT_ROOT / "README.md").write_text(text, encoding="utf-8")


def main() -> None:
    classic_16 = SOURCE_ROOT / "16x16" / "Classic"
    classic_48 = SOURCE_ROOT / "48x48" / "Classic"
    for required in (classic_16, classic_48):
        if not required.is_dir():
            raise FileNotFoundError(required)

    if OUTPUT_ROOT.exists():
        shutil.rmtree(OUTPUT_ROOT)
    OUTPUT_ROOT.mkdir(parents=True)

    manifest: list[dict[str, object]] = []
    default_exports: list[tuple[Path, str]] = []
    category_counts: Counter[str] = Counter()

    for sheet, palette_files in PALETTES.items():
        base_path = classic_16 / BASE_FILES[sheet]
        components = components_for(base_path)
        categories = category_lookup(sheet)

        for palette, source_name in palette_files.items():
            source_path = classic_48 / source_name
            source = Image.open(source_path).convert("RGBA")
            expected_size = (256 * SCALE, 256 * SCALE)
            if source.size != expected_size:
                raise ValueError(
                    f"Unexpected size for {source_path}: {source.size}, expected {expected_size}"
                )

            for component in components:
                component_id = int(component["component_id"])
                category = categories.get(component_id, "misc_props")
                stem = CATEGORY_STEMS[category]
                set_label = f"set{sheet}" if sheet != "electronics" else "electronics"
                filename = (
                    f"{stem}_{set_label}_c{component_id:03d}_{palette}.png"
                )
                destination_dir = OUTPUT_ROOT / category
                destination_dir.mkdir(parents=True, exist_ok=True)
                destination = destination_dir / filename

                crop, crop_box = crop_component(source, component)
                # A small number of optional details do not exist in every
                # electronics palette. Do not create misleading empty PNGs.
                if crop.getchannel("A").getbbox() is None:
                    continue
                crop.save(destination, optimize=True)
                category_counts[category] += 1

                left, top, right, bottom = crop_box
                entry = {
                    "file": destination.relative_to(OUTPUT_ROOT).as_posix(),
                    "category": category,
                    "sheet": sheet,
                    "component_id": component_id,
                    "palette": palette,
                    "source": source_path.relative_to(PROJECT_ROOT).as_posix(),
                    "source_crop_x": left,
                    "source_crop_y": top,
                    "source_crop_width": right - left,
                    "source_crop_height": bottom - top,
                    "output_width": crop.width,
                    "output_height": crop.height,
                }
                manifest.append(entry)
                if palette == "default":
                    default_exports.append(
                        (destination, f"{set_label} c{component_id:03d} {category}")
                    )

    fieldnames = list(manifest[0].keys())
    with (OUTPUT_ROOT / "manifest.csv").open(
        "w", encoding="utf-8", newline=""
    ) as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(manifest)
    (OUTPUT_ROOT / "manifest.json").write_text(
        json.dumps(manifest, indent=2), encoding="utf-8"
    )

    make_preview(default_exports)
    write_readme(len(manifest), category_counts)
    print(f"Exported {len(manifest)} PNG files to {OUTPUT_ROOT}")
    print(f"Default objects catalogued: {len(default_exports)}")
    for category, count in sorted(category_counts.items()):
        print(f"  {category}: {count}")


if __name__ == "__main__":
    main()
