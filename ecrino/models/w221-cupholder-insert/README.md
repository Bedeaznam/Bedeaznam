# Cup-holder insert — Mercedes S-Class W221 (2010)

A drop-in fluted (ribbed) tapered bowl for the W221 center-console cup-holder
well — modelled to match the user's own part. A rolled top rim rests on the
opening so it can't fall in, the body tapers inward toward the bottom, and
vertical flutes give it grip and the same look as the reference photo.

## ⚠️ Measure your car first (important)
Mercedes does **not** publish cup-holder dimensions, and the W221 holder is an
**adjustable spring-arm** unit — so there is no single official diameter. The
defaults in `cup_insert.scad` are an **estimate**:

- `hold_d = 74` mm — opening diameter of the round well
- `hold_depth = 60` mm — usable depth

Measure the actual opening (⌀) and depth of your holder with the spring arms
retracted, put those two numbers in the `.scad`, re-export, and the fit is
dialed in. Everything else (clearance, taper, wall, flange, notch) is derived
automatically.

## Two models here
- **`dual_cupholder.scad` / `.stl`** — replica of the OEM twin cup-holder unit
  (rounded rectangular bezel + two tapered wells + grip tabs), like the
  reference photo. Set `cup_d`, `cup_depth`, `center_spacing`.
- **`cup_insert.scad` / `.stl`** — a single fluted drop-in bowl for one well.

## Files
- `cup_insert.scad` / `dual_cupholder.scad` — parametric sources
- `cup_insert.stl` / `dual_cupholder.stl` — built with estimated defaults (verify fit!)
- `renders/` — previews

## Print (Bambu Lab H2S)
- PLA/PETG, or **TPU** if you want a soft grippy, rattle-free fit.
- Prints **upright, no supports** (the walls taper inward going down).
- 0.2 mm layers, 3 walls, 10–15 % infill; the flutes hide layer lines.
- If it's a hair too tight/loose after a test fit, nudge `fit_clear`
  (bigger = looser) rather than remeasuring.

## Parameters (`cup_insert.scad`)
- `hold_d`, `hold_depth` — your measured well (the only two you must set)
- `fit_clear` — how loose the drop-in fit is
- `taper` — how much the body narrows toward the bottom
- `wall`, `floor_t` — thickness
- `ribs`, `amp` — vertical flutes
- `rim_r`, `rim_out` — the rolled top rim that rests on the opening
- `foot_recess`, `foot_ring` — the standing foot underneath

## Re-export STL
```bash
openscad -o cup_insert.stl cup_insert.scad
```
