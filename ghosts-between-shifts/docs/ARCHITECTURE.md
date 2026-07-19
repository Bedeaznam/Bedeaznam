# Architecture — Ghosts Between Shifts

Godot 4.x, GDScript, 2D only. Linux-first (tested on Godot 4.3 stable).

## 1. Folder Structure

```
ghosts-between-shifts/
├── project.godot          # engine config, autoloads, input map, 1920x1080
├── icon.svg               # app icon (original)
├── default_env.tres       # 2D environment placeholder
├── theme.tres             # shared UI theme
├── docs/
│   ├── GAME_DESIGN.md
│   ├── ARCHITECTURE.md
│   └── ROADMAP.md
├── scenes/
│   ├── main_menu/         # MainMenu.tscn/.gd
│   ├── town_hub/          # TownHub.tscn/.gd (activity selection)
│   ├── room_workshop/     # Yasen's room + workbench
│   ├── tavern/            # tavern floor
│   ├── mountain/          # mountain trail
│   ├── ghost_sequence/    # surreal sequences
│   └── minigames/         # one .tscn per mini-game
├── scripts/
│   ├── autoloads/         # GameState, SaveManager, DialogueManager, SceneRouter, AudioDirector
│   ├── minigames/         # mini-game logic (if split from scenes)
│   └── ui/                # reusable UI widgets (DialogueBox, StatsPanel, HUD)
├── assets/
│   ├── fonts/  icons/  audio/  textures/   # procedural / original placeholders
├── data/
│   ├── stats_config.json  # stat metadata + activity definitions
│   ├── dialogue_*.json    # dialogue trees
│   └── story_*.json       # weekend beat scripts
└── saves/                 # .gitkeep only; runtime saves go to user://
```

## 2. Autoload Singletons

Registered in `project.godot` `[autoload]`, load order matters:

1. **GameState** — the simulation core. Holds day, hour, energy, all stats, money,
   flags, and the current story phase. Exposes:
   - `advance_time(hours, energy_cost)` — spends time/energy, may force sleep.
   - `apply_deltas(dict)` — clamped stat changes, emits `stats_changed`.
   - `sleep(bedtime_hour)` — computes sleep quality + next-day concentration
     penalty (`concentration_penalty` in 0..1) and advances the day.
   - `performance_multiplier()` — derived from Sleep/Emotional stability; used by
     mini-games to scale rewards and difficulty.
   - `evaluate_ending()` — returns one of `LOOP/ARMOR/OPEN_DOOR/PATH`.
   - Signals: `stats_changed`, `time_changed`, `day_changed`, `phase_changed`.

2. **SaveManager** — JSON save/load in `user://saves/`. `save_game(slot)`,
   `load_game(slot)`, `has_save(slot)`, `delete_save(slot)`. Serializes the whole
   `GameState` snapshot dictionary. Never writes outside `user://`.

3. **DialogueManager** — loads dialogue trees from `data/*.json`, walks nodes,
   filters choices by stat requirements, applies effects, emits
   `line_shown`, `choices_shown`, `dialogue_finished`. UI-agnostic; the
   `DialogueBox` widget renders it.

4. **SceneRouter** — safe scene transitions with a fade, keeps a return stack so
   mini-games/ghost sequences can pop back to the hub. `goto(path)`,
   `goto_packed(scene)`, `return_to_hub()`.

5. **AudioDirector** — plays procedural/placeholder ambience and stingers;
   exposes named cues (`menu`, `tavern`, `mountain`, `ghost`) so real tracks can
   be dropped in later without touching gameplay code.

## 3. Data-Driven Design

- **stats_config.json** — canonical list of stats (id, label BG/EN, min/max,
  default) and the activity catalog (id, label, hours, energy, stat effects,
  optional mini-game scene, requirements). `GameState` and `TownHub` read this so
  balancing needs no code changes.
- **dialogue_*.json** — node graph: `{ id, speaker, text, choices:[{text, goto,
  effects, requires}] }`. Localized text stored inline (BG primary).
- **story_*.json** — ordered weekend beats mapping phase -> scene/dialogue.

## 4. Scene Flow

```
MainMenu ──► TownHub ◄────────────┐
              │  (choose activity) │ return_to_hub()
              ├─► RoomWorkshop ─► LinuxPuzzle / RoboticsAssembly / PrinterRepair
              ├─► Tavern ───────► WaiterMinigame / DialogueBox(Mira)
              ├─► Mountain ─────► MountainExploration
              └─► GhostSequence  (triggered by story beats)
Sunday confrontation ──► Ending screen (LOOP/ARMOR/OPEN_DOOR/PATH)
```

`SceneRouter` owns transitions; `GameState.phase` drives which story beats fire
when the player returns to the hub.

## 5. UI

- Single shared `theme.tres`; dark palette.
- `HUD` shows Day/Hour/Energy/Sleep + money, always visible in hub/scenes.
- `StatsPanel` toggled with a key/controller button.
- `DialogueBox` renders `DialogueManager` output; fully keyboard+controller
  navigable.
- Anchors + containers for responsive scaling; `stretch_mode = canvas_items` at
  1920×1080 keeps it crisp on any resolution.

## 6. Input Map (keyboard + controller)

| Action | Keyboard | Controller |
|--------|----------|-----------|
| ui_accept | Enter / Space | A / Cross |
| ui_cancel | Esc | B / Circle |
| move_up/down/left/right | WASD / Arrows | D-pad / Left stick |
| interact | E | A |
| toggle_stats | Tab | Select |
| mg_action | Space | A |
| mg_left / mg_right | A/D / ←/→ | D-pad L/R |

Defined in `project.godot` `[input]`.

## 7. Determinism & Safety

- The Linux puzzle is a **pure simulation**: a fake in-memory filesystem and
  command parser. It never touches the OS and never runs real commands.
- Robotics wiring is validated against a data model (correct = servo on external
  supply with shared ground), so the "danger" is fictional.
- All randomness routed through a single seeded `RandomNumberGenerator` on
  `GameState` for reproducible tests.

## 8. Testing Hooks

- `--headless` import validates every scene/script parses.
- A `DebugConsole` (toggle) can jump phases and set stats for manual QA.
- See README "Testing checklist".
