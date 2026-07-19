# Ghosts Between Shifts

A narrative **life-simulation RPG** built in **Godot 4.x (GDScript), 2D**, about
**Yasen** — 22, Bulgarian-Turkish — living in a fictional Balkan town modeled on
Kardzhali. Between waiter shifts he tries to build a life: programming/Linux,
electronics/robotics, 3D printing, arm-wrestling, languages, the mountain, the
dog — and one weekend, Mira. Time and sleep are the real currency; the best
ending does not magically erase the pain.

> UI and story text are in **Bulgarian**. Everything runs on **Linux**
> (developed and tested on Godot **4.3-stable**). All assets are original,
> procedural placeholders. No paid services, no copyrighted media.

The game is a **vertical slice**: one full weekend (Friday / Saturday / Sunday)
with six mini-games, a dialogue system, two ghost sequences, and four endings.

## Requirements

- **Godot 4.3** (or newer 4.x) — standard build, GDScript. No C#/Mono needed.
- Linux (Arch, Ubuntu, etc.). GL Compatibility renderer (works on modest GPUs).

### Install Godot on Arch Linux
```bash
sudo pacman -S godot          # community repo
# or Flatpak:
flatpak install flathub org.godotengine.Godot
```
### Install Godot on Ubuntu/Debian
```bash
sudo snap install godot-4      # or download from https://godotengine.org/download
```
Or just grab the official binary:
```bash
curl -L -o godot.zip https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip
unzip godot.zip && chmod +x Godot_v4.3-stable_linux.x86_64
```

## Run

From this directory (`ghosts-between-shifts/`):
```bash
# Editor:
godot -e .
# Play directly:
godot .
# Headless smoke test (no window):
godot --headless -s res://tests/smoke.gd
```
(Replace `godot` with `./Godot_v4.3-stable_linux.x86_64` if you downloaded the
binary.)

Target resolution is **1920×1080**; the UI scales responsively (`canvas_items`
stretch) to other resolutions.

## Controls (keyboard **and** controller)

| Action | Keyboard | Controller |
|--------|----------|-----------|
| Confirm / advance | Enter / Space | A / Cross |
| Cancel / back | Esc | B / Circle |
| Navigate menus | Arrows / WASD | D-pad / Left stick |
| Interact | E | A |
| Toggle stats panel | Tab | Select |
| Mini-game action | Space | A |
| Mini-game left/right/up/down | A/D/W/S or arrows | D-pad |

Input actions are defined in `project.godot` under `[input]` and can be remapped
there.

## How to play

1. **New game** from the main menu.
2. In the **town hub** pick activities — each costs **hours** and **energy**.
   The **★-marked** activity advances the story for the current phase.
3. Do the weekend's objectives (shown at the top of the hub). Mini-games return
   you to the hub with a result that scales your stat gains.
4. **Sleep** when prompted. Staying up late / low energy lowers sleep quality,
   which lowers next-day **concentration** (smaller skill gains, weaker
   mini-game performance, shakier emotional control).
5. On **Sunday** you face an inner confrontation: choose what Yasen will build
   and what emotional boundary he sets. That decides the ending:
   **THE LOOP · THE ARMOR · THE OPEN DOOR · THE PATH**.

Save/Load uses a single slot in `user://saves/` (`Запази` in the hub,
`Продължи` on the main menu).

## Project layout

See `docs/ARCHITECTURE.md`. Design and roadmap in `docs/GAME_DESIGN.md` and
`docs/ROADMAP.md`. Asset inventory and licenses in `ASSETS.md`.

## Linux export

You need the **export templates** matching your Godot version (one-time):
- Editor → *Editor → Manage Export Templates → Download and Install*, **or**
```bash
curl -L -o templates.tpz https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz
# then install via the editor's Manage Export Templates -> Install from File
```
A ready `export_presets.cfg` (Linux/X11, x86_64) ships in this folder. Export:
```bash
# headless CLI export (templates must be installed):
godot --headless --export-release "Linux/X11" ./build/ghosts-between-shifts.x86_64
./build/ghosts-between-shifts.x86_64
```
Or from the editor: *Project → Export → Linux/X11 → Export Project*.

## Testing checklist

Automated (headless): `godot --headless -s res://tests/smoke.gd` — validates
config, all dialogue trees, save/load, the four endings, story wiring, and that
every scene instantiates. Expect `Failures: 0`.

Manual golden path:
- [ ] Main menu → New game starts at the hub (Friday).
- [ ] Each ★ objective launches its mini-game and returns with a result toast.
- [ ] **Waiter**: order shows then hides; correct items serve; RU/UK/EN reply
      appears only with enough language skill; failures raise stress.
- [ ] **Arm-wrestling**: timing in the green zone builds advantage; red zone
      risks injury; it is *not* button-mashing.
- [ ] **Linux puzzle**: `systemctl status printerd` → `ls -l /etc/printerd` →
      `chmod 644 …` → `systemctl restart printerd` → solved. No real commands run.
- [ ] **Printer repair**: correct diagnosis + fix + price affects money/rep.
- [ ] **Robotics**: only external supply + common ground + PWM signal succeeds.
- [ ] **Mountain**: reckless choices can injure; reaching the top restores calm.
- [ ] Mira Friday scene → ghost sequence #1 → sleep → Saturday.
- [ ] Mira Saturday (restrained) scene → ghost sequence #2 → sleep → Sunday.
- [ ] Sunday confrontation choices → one of the four endings.
- [ ] Sleep quality visibly changes next-day concentration in the HUD.
- [ ] Stats panel (Tab) shows all 17 stats; controller can navigate everything.

## Known limitations

- Vertical slice only: one weekend, one interaction per mini-game.
- Art and audio are **procedural placeholders** (drawn shapes, generated tone
  beds); no hand-authored art or music yet (see `ROADMAP.md` M4).
- Bulgarian text only; no localization pass yet.
- Sleep model caps the day at 24:00, so "late" bedtime is represented near the
  end of the day rather than past midnight.
- No controller rumble / haptics; no accessibility options yet.
- Linux export requires manually installing Godot export templates.

## License / assets

Original code and procedural assets. See `ASSETS.md`.
