# Assets & Licenses — Ghosts Between Shifts

All assets are **original** and created for this project. There are **no paid
services**, **no third-party art**, and **no copyrighted media**. Nearly
everything visual and audible is generated **procedurally at runtime**, so the
repository ships almost no binary asset files.

## Code
- All GDScript under `scripts/`, `scenes/`, and `tests/` is original, written for
  this project. License: same as the repository.

## Visual assets
| Asset | Source | Type | License |
|-------|--------|------|---------|
| `icon.svg` | Original | Hand-written SVG (app icon) | Project license |
| Backgrounds / gradients | `scripts/ui/gradient_backdrop.gd` | Procedural (drawn) | Project license |
| Ghost-sequence visuals | `scenes/ghost_sequence/GhostSequence.gd` (`_GhostArt`) | Procedural (drawn) | Project license |
| Arm-wrestling bar/marker | `scenes/minigames/ArmWrestling.gd` (`_ArmDraw`) | Procedural (drawn) | Project license |
| UI theme | `theme.tres` | Original StyleBoxes / colors | Project license |
| All in-game UI (menus, HUD, panels, dialogue) | Built in code | Procedural (Godot Controls) | Project license |

Fonts: the project uses Godot's **built-in default font** (no bundled font
files). It renders Cyrillic/Bulgarian correctly out of the box.

## Audio assets
| Asset | Source | Type | License |
|-------|--------|------|---------|
| Ambience / cue beds (`menu`, `tavern`, `mountain`, `ghost`, `workshop`) | `scripts/autoloads/AudioDirector.gd` | Procedural (generated `AudioStreamWAV` tone beds) | Project license |

No audio files are bundled. See `assets/audio/README.md` for how to add an
**original** soundtrack later (suggested direction: atmospheric metal /
deathcore / punk / melancholic guitar / dark-folk flute). Only original or
properly licensed audio may be added — never copyrighted tracks.

## Data
- `data/*.json` (stats config, dialogue trees) — original content.

## Third-party
- **Godot Engine 4.x** (MIT License) — the runtime/editor, not redistributed in
  this repo. Its built-in default font ships with the engine.

If any non-original asset is ever added, it must be listed here with its source
and license before being committed.
