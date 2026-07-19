# Ghosts Between Shifts — Game Design Document

> A narrative life-simulation RPG about work, discipline, longing, and the quiet
> choice of what to build with a life. 2D, GDScript, Godot 4.x. Linux-first.

## 1. High Concept

You are **Yasen**, 22, Bulgarian-Turkish, living in a fictional Balkan town
modeled loosely on Kardzhali. Between waiter shifts at a smoky tavern you try to
become something — an engineer, a programmer, someone strong enough to hold a
life together. Days are short. Energy is finite. Every choice costs time and
sleep, and sleep costs the next day's clarity.

Then **Mira**, a 38-year-old singer at the tavern, walks into your ordinary
exhaustion. The relationship opens something and then closes it. The game is not
about winning her; it is about what you decide to build once a door quietly
shuts.

The **ghosts** are not literal. They are the surreal residue of feeling — warped
versions of the tavern and the mountain trail, fragments of your own thoughts
that follow you between shifts.

## 2. Pillars

1. **Time and sleep are the real currency.** Staying up late and working early
   degrades concentration, performance, and emotional control the next day. The
   simulation should make you *feel* the cost of burning yourself.
2. **Skills are self-authorship.** Programming, electronics, 3D printing,
   languages, the body — each stat is a small vote for who Yasen becomes.
3. **Restraint over spectacle.** A stable, playable build beats visual polish.
4. **No magical healing.** The best ending does not erase the pain; it gives it
   a direction.

## 3. Themes

- Labor and dignity; the immigrant/minority working-class experience.
- Discipline as both armor and prison.
- Attachment, hope, and self-respect held in tension.
- The difference between being wanted and being chosen.

## 4. Characters

- **Yasen** — 22, Bulgarian-Turkish. Waiter by necessity, builder by hope.
  Quiet, stubborn, prone to overwork. The player.
- **Mira** — 38, tavern singer. Warm, magnetic, guarded, ultimately honest.
  She is *not* a villain. She distances herself with professional grace. The
  arc respects her autonomy and boundaries.
- **The dog** — Yasen's companion; the game's steady emotional anchor.
- **Tavern regulars** — Russian, Ukrainian, and English-speaking customers whose
  requests reward language skill.

Yasen's line, spoken to Mira: *"Ако откриеш какво наистина искаш и аз съм част
от него, знаеш къде да ме намериш."* ("If you find what you truly want and I'm
part of it, you know where to find me.")

## 5. Core Stats

Managed by the `GameState` autoload. Ranges 0–100 unless noted.

| Stat | Meaning |
|------|---------|
| Discipline | Consistency; unlocks harder activities |
| Physical strength | Raw power for arm-wrestling / mountain |
| Arm-wrestling technique | Wrist control, top roll, transitions |
| Technical knowledge | Diagnosis, engineering intuition |
| Programming | Coding / Linux puzzle skill |
| Electronics | Robotics, wiring, repair |
| Creativity | Design, problem framing |
| 3D-printing skill | Print success & repair |
| English / Russian / Ukrainian | Dialogue options & tips |
| Financial stability | Money buffer; failure raises stress |
| Sleep | Rest debt; drives next-day performance |
| Emotional stability | Buffer against stress spikes |
| Self-respect | Gates the healthiest choices |
| Attachment | Pull toward Mira |
| Hope | Belief a different life is possible |

Every activity **consumes time and energy** and shifts stats. Low `Sleep`
applies a **concentration penalty** that reduces skill gains and mini-game
performance and lowers `Emotional stability`.

## 6. Core Loop

```
Wake  ->  see Day/Hour/Energy/Sleep + stats
      ->  choose activity from the town hub (each costs hours + energy)
      ->  resolve activity (mini-game or interaction -> stat deltas)
      ->  repeat until hours/energy run out or you choose to sleep
Sleep ->  Sleep stat recovers based on bedtime; penalties computed
      ->  scripted story beats advance the weekend
```

Activities: waiter work, training, programming/Linux, languages, 3D printing,
electronics/robotics, reading, time with the dog, mountain, rest/sleep, and
contact with emotionally significant people.

## 7. Mini-Games (one each for the vertical slice)

- **Waiter work** — serve under time pressure, remember orders; some customers
  speak Russian/Ukrainian/English. Better language unlocks correct lines and
  bigger tips. Failure raises stress.
- **Arm-wrestling** — timing/positioning (wrist control, top roll, inside
  transition, pronation, endurance, injury risk). **Not** button-mashing.
- **Linux/programming puzzle** — a *simulated, sandboxed, fictional* terminal
  (find files, permissions, packages, a broken service, logs). It **never**
  executes real commands.
- **3D-printer repair** — one diagnostic interaction (spaghetti failure /
  clogged nozzle / warping) with pricing and reputation.
- **Robotics assembly** — wire a small desktop robot; the servo needs an
  external supply with common ground, **not** power straight from the MCU.
- **Mountain exploration** — emotional recovery, materials, hidden
  philosophical monologues; recklessness has consequences.

## 8. Story — Vertical Slice (one weekend)

- **Friday** — morning technical project, afternoon 3D-print order, evening
  shift, Mira arrives, first ghost sequence.
- **Saturday** — arm-wrestling training, a Russian/Ukrainian customer, a printer
  breakdown with diagnosis, second shift, a restrained conversation with Mira.
- **Sunday** — mountain walk with the dog, a final inner confrontation, and the
  choice of what Yasen will build and what emotional boundary he will set.

## 9. Endings (four states)

Determined by weighted stats at the Sunday confrontation:

- **THE LOOP** — nothing changes; the shifts swallow him again.
- **THE ARMOR** — he grows strong and disciplined but closes his heart.
- **THE OPEN DOOR** — he stays hopeful and open, without a clear direction yet.
- **THE PATH** — self-respect + hope + a concrete craft; the healthiest ending.
  It does **not** magically erase the pain — it points it somewhere.

## 10. Art & Audio Direction

- Dark, melancholic palette: black, deep blue, muted green, warm orange.
- All visuals are original procedural placeholders (drawn at runtime / generated
  textures). No copyrighted assets.
- Audio: placeholder/original short tracks or a structured slot for an original
  soundtrack (atmospheric metal / deathcore / punk / melancholic guitar / dark
  folk flute). No copyrighted music.

## 11. Input

Keyboard **and** controller via named input-map actions (see
`ARCHITECTURE.md`). Target resolution 1920×1080, responsive UI.
