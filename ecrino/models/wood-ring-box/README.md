# Wooden ring box — Y7 (tuned for PLA Wood)

A parametric, FDM-friendly engagement/wedding ring box designed for **wood-fill
PLA** (e.g. PLA Wood). Rounded rustic body, beveled lid with an engraved
tree-of-life, a real hinge (filament-pin) at the back and two magnets snapping
the front shut. Prints in **three parts, no supports**.

## Files
- `wood_ring_box.scad` — parametric source (edit sizes, magnets, engraving here)
- `base.stl` — tray: cavity, magnet pockets, two hinge knuckles
- `lid.stl` — beveled lid: engraved tree-of-life, magnet pockets, middle hinge knuckle
- `insert.stl` — insert core with a ring slot (flock it or wrap in velvet)
- `build_blend.py` / `wood_ring_box.blend` — ready-to-edit Blender scene + preview
- `renders/` — OpenSCAD + Blender preview images

## Print (Bambu Lab H2S)
- Filament: **PLA Wood** (matte, wood-fill). PLA/PETG also fine.
- Layer height: 0.2 mm; walls: 3+; infill: 15–20 % gyroid.
- **No supports** — every part prints flat.
- Orientation: `base` cavity-up, `lid` top-up, `insert` slot-up.
- Nozzle for wood-fill: 0.4 mm+ (0.6 mm reduces clogging); temp per spool.

## Wood finish
PLA Wood sands beautifully. After printing: sand 240→400 grit, then rub with a
little wood oil / stain / wax for a genuine timber look and to deepen the grain.

## Assembly
1. Press one 6 × 2 mm magnet into each pocket (2 in base, 2 in lid) — **check
   polarity** so they attract. Secure with a drop of CA glue.
2. Interleave the lid knuckle between the two base knuckles and push a
   **~45 mm off-cut of 1.75 mm filament** through as the hinge pin; trim flush.
   (A dab of glue on the outer knuckles only keeps the pin captive while the lid
   still swings freely.)
3. Flock the insert (flock powder + glue) or wrap it in velvet/suede, then drop
   it into the tray. The ring seats upright in the slot.

## Personalize (edit `wood_ring_box.scad`)
- `L`, `W`, `cavity_d`, `corner_r` — overall size / proportions
- `magnet_d`, `magnet_h` — match your magnets
- `pin_d` — hinge pin (1.95 for a 1.75 mm filament pin)
- `slot_w`, `slot_len`, `slot_depth` — ring slot fit
- Swap the `tree_of_life()` module for initials/date via `text()` if you prefer

## Re-export STL
```bash
for p in base lid insert; do
  openscad -o $p.stl -D "part=\"$p\"" wood_ring_box.scad
done
```

> The `assembly` preview shows the lid open — it is a visualization only, not a
> single printable body. Print `base`, `lid` and `insert` separately.
