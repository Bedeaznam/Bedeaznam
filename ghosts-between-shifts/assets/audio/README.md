# Audio placeholders

The game currently generates **all** audio procedurally at runtime via the
`AudioDirector` autoload (`scripts/autoloads/AudioDirector.gd`) — short,
original atmospheric tone beds. No audio files ship here and **no copyrighted
music is used**.

## Adding an original soundtrack later
Drop `.ogg`/`.wav` tracks in this folder and map cue names in
`AudioDirector.CUES` / `play_cue()` to `AudioStreamPlayer.stream`. Keep cue
names stable (`menu`, `tavern`, `mountain`, `ghost`, `workshop`) so gameplay
code needs no changes.

Suggested original direction: atmospheric metal / deathcore / punk / melancholic
guitar / dark-folk flute. Only original or properly licensed audio.
