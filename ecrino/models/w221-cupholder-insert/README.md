# Cup-holder insert — Mercedes S-Class W221 (2010)

A drop-in organizer / cup insert for the W221 center-console cup-holder well.
A flared flange rests on the rim so it can't fall in, soft vertical ribs grip
it centred, and a finger notch lets you reach in and lift it out. Same fluted
family as the ramekin.

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

## Files
- `cup_insert.scad` — parametric source
- `cup_insert.stl` — built with the estimated defaults (verify fit!)
- `renders/` — preview

## Print (Bambu Lab H2S)
- PLA/PETG, or **TPU** if you want a soft grippy, rattle-free fit.
- Prints **upright, no supports** (the walls taper inward going down, and the
  flange underside is a printable cone).
- 0.2 mm layers, 3 walls, 10–15 % infill.
- If it's a hair too tight/loose after a test fit, nudge `fit_clear`
  (bigger = looser) rather than remeasuring.

## Parameters (`cup_insert.scad`)
- `hold_d`, `hold_depth` — your measured well (the only two you must set)
- `fit_clear` — how loose the drop-in fit is
- `taper` — how much the body narrows toward the bottom
- `wall`, `floor_t` — thickness
- `ribs`, `amp` — grip ribs
- `flange_w`, `flange_drop` — the resting collar
- `notch`, `notch_w`, `notch_h` — the finger notch

## Re-export STL
```bash
openscad -o cup_insert.stl cup_insert.scad
```
