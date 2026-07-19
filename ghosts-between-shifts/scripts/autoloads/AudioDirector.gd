extends Node
## AudioDirector — procedural placeholder ambience + named cues.
## Real original tracks can be dropped into res://assets/audio and mapped here
## without changing gameplay code. No copyrighted audio is used.

var _player: AudioStreamPlayer
var _current_cue: String = ""

# Cue -> generator params (procedural tone beds). Kept intentionally minimal.
const CUES := {
	"menu":     { "hz": 110.0, "vol": -20.0 },
	"tavern":   { "hz": 146.83, "vol": -22.0 },
	"mountain": { "hz": 98.0, "vol": -24.0 },
	"ghost":    { "hz": 65.41, "vol": -18.0 },
	"workshop": { "hz": 130.81, "vol": -24.0 },
}

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)


func play_cue(cue: String) -> void:
	if cue == _current_cue:
		return
	_current_cue = cue
	var params: Dictionary = CUES.get(cue, CUES["menu"])
	_player.stream = _make_tone(float(params["hz"]))
	_player.volume_db = float(params["vol"])
	_player.play()


func stop() -> void:
	_current_cue = ""
	_player.stop()


# Generates a short, looping low sine bed as an original placeholder track.
func _make_tone(hz: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var seconds := 2.0
	var count := int(sample_rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var t := float(i) / sample_rate
		# Detuned dual-sine with slow tremolo for an atmospheric, melancholic bed.
		var env := 0.5 + 0.5 * sin(TAU * 0.25 * t)
		var s := 0.6 * sin(TAU * hz * t) + 0.4 * sin(TAU * hz * 1.5 * t)
		var v := int(clampf(s * env * 0.35, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, v)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = count
	wav.data = data
	return wav
