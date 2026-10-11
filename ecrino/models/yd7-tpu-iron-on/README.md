# YD7 iron-on TPU logo (T-shirt / hoodie)

Flat TPU print of the YD7 monogram that is ironed onto fabric, the same technique as the
MakerWorld "Instagram logo for printing on a TPU shirt".

- `yd7_iron_on.stl`: 90 x 53 x 0.8 mm, reads correctly when placed bed-side down on the fabric.
- `yd7_iron_on_mirrored.stl`: mirrored copy, for placing the top side of the print on the fabric.
- `yd7_iron_on.scad`: parameters `width` (mm), `thickness`, `mirrored`.
- `yd7_outline.scad` is generated from `yd7_source.png` by `trace.py` (OpenCV contours); rerun it for a new logo image.

## Print
- **TPU 95A**, white (or any colour), textured or smooth PEI plate, no brim, no supports.
- 0.2 mm layers (4 layers = 0.8 mm, all solid), 2 walls, 20-25 mm/s.
- Strokes are ~7-8 mm wide at 90 mm, so a 0.6 mm nozzle works. The narrow slits between the letters
  are partly under 1 mm and may close at the tips; that is fine.
- Back print: set `width = 220`.

## Apply
1. Let the plate cool, peel the logo off.
2. Place it on the shirt (pre-ironed, flat, on a hard surface), smooth bed side down.
3. Cover with baking paper and press a hot iron (cotton setting, no steam) for ~1 min, moving slowly.
4. Let it cool completely before moving the shirt. Wash inside out, cold.
