# Roadmap — Ghosts Between Shifts

## Milestones

### M0 — Foundation (done in this slice)
- Project config, input map, autoloads (GameState, SaveManager, DialogueManager,
  SceneRouter, AudioDirector).
- Data-driven stats + activity catalog.
- Procedural placeholder art/audio.

### M1 — Vertical Slice (this deliverable)
- Main menu, town hub, room/workshop, tavern, mountain, ghost sequence.
- Six mini-games (waiter, arm-wrestling, Linux puzzle, printer repair, robotics,
  mountain exploration), one interaction each.
- Dialogue system + Mira Friday/Saturday scenes.
- Full weekend (Fri/Sat/Sun) with four endings.
- Save/load, README, ASSETS, testing checklist, Linux export docs.

### M2 — Depth
- More customers, orders, and languages in the waiter loop.
- Arm-wrestling meta: opponents, tournaments, injury recovery arc.
- Expanded Linux puzzles (multi-step incidents), package/service trees.
- Printer job queue with reputation economy.
- More robotics builds (sensors, PWM, feedback loops).

### M3 — World & Story
- Full week/month calendar; more NPCs and side arcs.
- Branching Mira arc consequences carried across weeks.
- Additional ghost sequences tied to specific stat/emotional states.
- Localization pass (BG/EN), accessibility options.

### M4 — Production Polish
- Original soundtrack integration (metal/deathcore/punk/guitar/dark folk flute).
- Hand-authored art replacing placeholders (keeping the palette).
- Steam/itch Linux + Windows + web export pipeline, controller rumble.

## Risk List

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Scope creep on sim depth | High | Data-driven catalog; ship slice first |
| Mira arc read as manipulative | High | Respectful writing, boundaries, review pass |
| Fake terminal mistaken for real | Med | Pure in-memory sim, no OS calls, documented |
| Placeholder art feels unfinished | Med | Consistent palette + theme; polish is M4 |
| Balancing sleep/energy economy | Med | Central tunables in stats_config.json |
| Godot version drift | Low | Pin 4.3 stable; document export templates |
| Controller parity gaps | Low | Named actions; test both paths |

## Extending the Vertical Slice

1. **Add an activity**: append to `activities` in `data/stats_config.json`
   (hours, energy, effects, optional `minigame` scene). No code change to hub.
2. **Add dialogue**: drop a `dialogue_*.json` tree; reference it from a story
   beat or NPC interaction.
3. **Add a mini-game**: create `scenes/minigames/<name>.tscn` + script,
   emit a result dict, call `SceneRouter.return_to_hub()`, and link it from an
   activity's `minigame` field.
4. **Add a story beat/day**: extend `data/story_*.json` and the phase enum in
   `GameState`.
5. **Add an ending**: extend `GameState.evaluate_ending()` weighting and the
   ending copy table.
6. **Real audio**: replace `AudioDirector` cue stubs with streams; keep cue
   names stable.
