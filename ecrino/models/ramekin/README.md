# Fluted sauce ramekin / dip bowl — Y7

A parametric 3D-printable ramekin modelled from reference photos: a round
tapered bowl with vertical flutes, a rolled/flared rim and a recessed foot.

Default size (≈ standard small dip bowl):
- top ⌀ ~92 mm, bottom ⌀ ~62 mm, height ~47 mm (incl. rim), wall 2.6 mm.

## Files
- `ramekin.scad` — parametric source
- `ramekin.stl` — ready to slice
- `renders/` — preview images

## Print (Bambu Lab H2S)
- Filament: PLA/PETG. Prints **upright, no supports** (walls lean out ~15°).
- 0.2 mm layers, 3 walls, 10–15 % infill; the fluted outside hides layer lines.
- Optional: "vase mode" won't work here (it has a solid floor + rolled rim) —
  print normally.

> Food contact: PLA/PETG prints are not certified food-safe (layer gaps trap
> bacteria). Use a food-safe filament + food-safe epoxy/coating, or treat it as
> decorative / dry use.

## Personalize (`ramekin.scad`)
- `R_bot`, `R_top`, `H` — diameters and height
- `ribs`, `amp` — number of flutes and how far they stand out
- `wall`, `floor_t` — thickness
- `rim_r`, `rim_out` — the rolled lip
- `foot_recess`, `foot_ring` — the standing foot underneath

## Re-export STL
```bash
openscad -o ramekin.stl ramekin.scad
```
