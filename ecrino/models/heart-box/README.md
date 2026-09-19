# Heart box (lidless base) + decorative lid — Y7

Two parametric 3D-printable models from one source:

- **`heart_base.stl`** — a heart-shaped box **without a lid**. An inner
  shoulder is left around the top so a lid can drop on and sit flush.
- **`heart_lid.stl`** — a matching heart lid with **feminine swirl / filigree
  curls** raised on top and a locating lip underneath that seats into the base.

Default size: ~110 mm wide heart, base 34 mm tall, 3 mm walls/floor.

## Files
- `heart_box.scad` — parametric source (one file, two parts via `part`)
- `heart_base.stl` — the lidless box
- `heart_lid.stl` — the decorated lid
- `renders/` — previews

## Print (Bambu Lab H2S)
- Both parts print **flat on the bed, no supports**.
- Base: openings up, prints as a simple walled heart bowl.
- Lid: top face up so the raised swirls come out crisp.
- PLA/PETG, 0.2 mm layers, 3 walls, 10–15 % infill.
- For a 2-colour look, paint the raised swirls a second colour in Bambu Studio
  (they stand `swirl_emb` mm above the lid, so they're easy to select).

## Fit
The lid lip drops into the base shoulder with `lip_gap` (0.4 mm) clearance.
If it's too tight/loose after a test print, tweak `lip_gap`.

## Personalize (`heart_box.scad`)
- `S` — overall heart width; `box_h` — base height
- `wall`, `floor_t` — thickness
- `lid_top`, `lip_h`, `lip_gap` — lid plate, lip depth, fit clearance
- `swirl_line`, `swirl_emb` — filigree stroke width and height
- edit `filigree()` to restyle the curls

## Export both parts
```bash
openscad -o heart_base.stl -D 'part="base"' heart_box.scad
openscad -o heart_lid.stl  -D 'part="lid"'  heart_box.scad
```
