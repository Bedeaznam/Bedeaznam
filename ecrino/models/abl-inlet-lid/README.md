# ABL 1154-210 caravan inlet — replacement hinged lid

Printable replacement for the front flap of the **ABL-Sursum 1154-210** flush-mount
16 A CEE caravan inlet (sold as "Inlet ABL Caravan 16 Amp Recessed").
ABL's own spare part for this flap is article **E154200** (Klappdeckel, series 1154).

## Dimensions of the inlet (published data)

| | h | w | d |
|---|---|---|---|
| Overall flange | 115 | 105 | 95 |
| Wall cut out | 90 | 80 | 80 |

Rated 16 A, 3-pin (2P+PE), 230 V, 6 h, IP44, made in Germany by ABL-Sursum.

**The lid itself is not dimensioned in any public ABL datasheet.** The model is
therefore parametric, with defaults derived from the 115 x 105 flange and from
photos of the part. Five values must be checked against the original — they are
marked `MEASURE` in `abl_lid.scad`:

| Parameter | Default | What to measure |
|---|---|---|
| `lid_w` | 105 | outer width, across the hinge |
| `lid_h` | 100 | outer height, top edge to bottom edge |
| `depth` | 11 | how far the lid stands off the flange |
| `pin_d` | 3.2 | hinge pin diameter (+0.2 clearance) |
| `knuckle_cc` | 85 | centre-to-centre spacing of the two hinge knuckles |
| `notch_w` / `notch_d` | 20 / 7 | the top-corner notches that clear the flange hinge lugs |

Edit them, then re-export:

```bash
openscad -o abl_lid.stl abl_lid.scad
```

## Files

- `abl_lid.scad` — parametric source
- `abl_lid.stl` — flat face; prints face-down with no supports (recommended)
- `abl_lid_crowned.stl` — with the 1.2 mm crown of the original; looks closer but
  the face is convex, so print it open-side-down or add a brim

## Shape

The original is not a flat plate but a shallow cover, so the model is built the
same way:

- gently crowned outer face with a 5 mm radius rolling into a perimeter skirt
  ~11 mm deep — the "pillow" silhouette of the original, not a chamfered plate
- stiffening ribs on the **inside** only, as on the moulded original
- small notches in the two top corners to clear the hinge lugs of the flange
- hinge knuckles sit **inside** against the top wall, so nothing protrudes past
  the outline; the pin bore is horizontal in the print, so it needs no support
  and no drilling
- drain slots and a finger recess along the bottom edge

The strip visible above the lid on photos of the assembled inlet belongs to the
flange, not to the lid (`band = 0`).

No `ABL` lettering is reproduced — that is their trademark.

## Printing

- Material: **ASA** or **PETG** — the part is exterior and sees UV and heat. PLA
  will warp and go brittle outdoors; PLA Wood is not suitable here.
- 0.2 mm layers, 3 walls, 30 % infill, **no supports**.
- Orientation: outer face flat on the bed, open side up. The 45 deg chamfer at
  the face edge makes this self-supporting and leaves the visible face smooth.
- The pin bore is modelled at 3.2 mm; ream to fit the original steel pin.
