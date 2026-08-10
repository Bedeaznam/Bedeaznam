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
| `lid_w` | 100 | lid width, across the hinge |
| `lid_h` | 96 | lid height, top edge to bottom edge |
| `lid_t` | 3.0 | plate thickness |
| `pin_d` | 3.2 | hinge pin diameter (+0.2 clearance) |
| `knuckle_cc` | 65 | centre-to-centre spacing of the two hinge knuckles |

Edit them, then re-export:

```bash
openscad -o abl_lid.stl abl_lid.scad
```

## Files

- `abl_lid.scad` — parametric source
- `abl_lid.stl` — plain plate; **prints flat, no supports**
- `abl_lid_sealed.stl` — same plus an inner sealing lip (`lip=1`), better water
  exclusion but needs light support under the plate

## Design notes

- The hinge knuckles sit on the top edge with the pin bore lying **in** the plate
  plane, so the part prints flat with the bore horizontal — no supports, and the
  bore does not need drilling out.
- The knuckle bosses thicken outwards only, for the same reason.
- Four moulded-style ribs across the width, and a finger tab on the bottom edge.

## Printing

- Material: **ASA** or **PETG** — the part is exterior and sees UV and heat. PLA
  will warp and go brittle outdoors; PLA Wood is not suitable here.
- 0.2 mm layers, 3 walls, 40 % infill, no supports (plain version).
- Orientation: plate flat on the bed, ribs facing up.
- The pin bore is modelled at 3.2 mm; ream to fit the original steel pin.
