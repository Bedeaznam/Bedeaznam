# "Старата къща" ashtray — Y7

A barrel-shaped ashtray modelled from the reference photo (~9 cm wide, curved
bulging body, cigarette-rest notches on the rim), with the height lowered to
**4 cm** as requested and raised Cyrillic side text **"СТАРАТА КЪЩА"** for a
2-colour **white** print on Bambu Lab / AMS.

Default size:
- outer ⌀ ~90 mm, height 40 mm, wall ~3 mm, floor 4 mm, 3 cigarette notches.

## Files
- `ashtray.scad` — parametric source
- `ashtray.stl` — body + text fused (single object; paint the letters white)
- `ashtray_body.stl` — body only
- `ashtray_text.stl` — the raised letters only (load as the white part)
- `renders/` — previews

## Print white text on Bambu Lab (2 colours)
Two easy ways:

**A) Two STLs (cleanest):** In Bambu Studio import `ashtray_body.stl`, then
right-click → *Add part* → import `ashtray_text.stl` (it drops in at the same
origin, already sitting on the surface). Assign the base filament to the body
and **white** to the text. Slice — AMS swaps colour only for the letters.

**B) One STL + paint:** Import `ashtray.stl`, use the *Colour Painting* tool and
paint the raised letters white (or set a height-range/filament change at the
text band). The letters stand out `text_emb` mm so they're easy to select.

Print **upright, no supports**. 0.2 mm layers, 3 walls, 15 % infill. PLA/PETG
are fine — an ashtray sees heat, so PETG (or a metal-look PLA) holds up better
than standard PLA to a hot cigarette; keep the cavity generous.

## Personalize (`ashtray.scad`)
- `D_max`, `H` — width and height
- `wall`, `floor_t` — thickness
- `notches`, `notch_r` — cigarette rests
- `text_str` — change the wording (Cyrillic OK)
- `text_size`, `text_emb`, `text_z`, `text_arc`, `text_face` — the side text
- `text_font` — any installed font

## Re-export
```bash
openscad -o ashtray.stl ashtray.scad
openscad -o ashtray_body.stl -D 'part="body"' ashtray.scad
openscad -o ashtray_text.stl -D 'part="text"' ashtray.scad
```
