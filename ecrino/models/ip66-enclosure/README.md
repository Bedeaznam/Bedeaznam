# 3D printable outdoor enclosure — 250 x 200 x 150 mm (IP66 style)

Parametric OpenSCAD model built to the supplied drawings. Sized for a Bambu Lab
H2S (350 x 320 x 325 mm build volume) — every part fits without splitting.

## Dimensions

| | |
|---|---|
| Overall | 250 (h) x 200 (w) x 150 (d) mm |
| Base / lid split | base 132 mm + lid 18 mm |
| Wall / floor | 4 mm |
| Usable interior | ~212 x 162 mm between the corner pillars |
| Gasket groove | 3 mm wide x 8 mm deep, in the base rim |
| Lid screws | 4x M4, countersunk, into the corner pillars (Ø3.4 self tapping) |
| Mounting plate | 210 x 160 x 3 mm, 4x Ø4.5 |
| Standoffs | M4, 8 mm tall, Ø10 |
| Wall mounting holes | 4x Ø6 through the floor |
| Cable entry | M20 gland, Ø20.5 hole in the bottom wall, with a boss |

## Files

| File | Print orientation |
|---|---|
| `base.stl` | opening up — no supports |
| `lid.stl` | logo face **down** on the plate — no supports, smooth outer face |
| `plate.stl` | flat (or cut from 3 mm aluminium instead) |
| `gasket.stl` | print in TPU 95A if you do not have an 3 x 8 mm EPDM cord |

## Print settings

- Material: **ASA** (UV resistant, -40…+80 °C). ABS or PC also work; PLA does not last outdoors.
- Enclosed chamber, 0.2 mm layers, 4 walls, 20-30 % infill, brim, fan 20-30 %.
- No supports needed in either orientation.
- ASA on this footprint (200 x 250) needs the chamber closed and no draught, otherwise the corners lift.

## Two-colour logo

The lid is printed face down, so the engraved `7Y` sits in the **first layers**.
In Bambu Studio just colour-paint the engraved area (or use a filament change at
layer 4) and the AMS gives a flush two-colour logo — no support, no seam.

Want the hexagon logo from your renders instead of `7Y`? Send the SVG/PNG and it
goes in as a `surface()`/`import()` outline at the same depth.

## Sealing

The lid tongue (2.6 x 6.5 mm) presses the gasket into the 3 x 8 mm groove in the
base rim. With an EPDM cord or the TPU gasket plus the 4 M4 screws this reaches
IP65-66 in practice; printed plastic is not certified — do not rely on a rating
without a real test.

## Parameters

Everything is at the top of `enclosure.scad`: `OW`, `OL`, `OD`, `wall`, `lid_h`,
`groove_w`, `groove_d`, `pl_w`, `pl_l`, `sto_h`, `gl_d`, `logo`.

Export a part with:

```bash
openscad -o base.stl -D part=\"base\" enclosure.scad
```
