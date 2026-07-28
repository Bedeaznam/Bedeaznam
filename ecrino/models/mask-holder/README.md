# Mask holder wand — Y7 (TPU / AMS)

A long flexible handle with a jaw at the tip that pinches the **edge of a mask
from the side**, so you can hold it without touching the fabric. Designed to be
printed in **TPU** (e.g. 95A) so the stick won't snap and the jaws stay springy.

## Files
- `mask_holder.scad` — parametric source
- `mask_holder_spec.stl` — **exact spec**: mouth 0.2 → inner 0.1 mm, relief 0.2 mm
- `mask_holder_printable.stl` — **FDM-safe**: mouth 0.7 → inner 0.35 mm, relief 1.4 mm
- `renders/` — preview images

## Important: slot size vs. FDM resolution
A 0.1–0.2 mm slot is **below what a 0.4 mm nozzle can print** — the slicer will
merge it into solid plastic and there will be no working gap. So:
- Print **`mask_holder_printable.stl`** for a wand that actually grips a mask.
- `mask_holder_spec.stl` is kept because you asked for the exact numbers, but it
  will not produce an open slot on a normal FDM printer.

Tune any value in the `.scad` and re-export (see below) if you want something in
between.

## Print (Bambu Lab H2S + AMS)
- Filament: **TPU 95A** (flexible → the ~21 cm stick bends instead of breaking).
- Slow it down: 15–25 mm/s, no/low retraction, direct-drive settings.
- Layer height 0.16–0.2 mm; 3 walls; 15 % infill.
- Orientation: stand the wand **upright** (jaw at top) so the two lips print as
  clean vertical walls and the slot stays open. No supports needed.
- The rounded end-knob prints flat on the bed as the first layer.

## How it works
The mask edge slides into the **V-shaped lead-in mouth**, down through the
**tapering pinch** (wide at the top, narrow deeper in), and the fabric bunches
into the **internal relief channel** at the bottom — the taper + relief lock it
so it doesn't slip out. Flexible TPU lets the lips flex open and clamp back.

## Personalize (`mask_holder.scad`)
- `rod_len` — stick length (default 210 mm, i.e. ≥ 20 cm)
- `rod_d` — stick diameter (thicker = stiffer)
- `clip_w` — how wide a span of the mask edge it grabs
- `mouth_gap` / `inner_gap` / `relief_gap` — the grip geometry
- `slot_depth` — how deep the mask sits in the jaw
- `printable` — `false` = exact spec, `true` = FDM-safe

## Re-export STL
```bash
openscad -o mask_holder_spec.stl      -D "printable=false" mask_holder.scad
openscad -o mask_holder_printable.stl -D "printable=true"  mask_holder.scad
```
