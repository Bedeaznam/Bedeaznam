extends Control
## Ending screen — evaluates GameState and shows one of four states. The best
## ending (THE PATH) does not magically erase the pain.

const GradientBackdropScene := preload("res://scripts/ui/gradient_backdrop.gd")

const ENDINGS := {
	"LOOP": {
		"title": "THE LOOP",
		"color": Color(0.5, 0.52, 0.58),
		"text": "Понеделник идва като всеки понеделник. Смяната те поглъща отново. "
			+ "Нищо не се е счупило — но нищо и не се е отворило. Кучето те чака на вратата, "
			+ "а ти вече мислиш за поръчките.",
	},
	"ARMOR": {
		"title": "THE ARMOR",
		"color": Color(0.6, 0.62, 0.7),
		"text": "Станал си по-силен, по-дисциплиниран, по-твърд. Ръката ти вече не трепери. "
			+ "Но си затворил нещо вътре. Бронята пази — и от студа, и от топлината. "
			+ "Уважаваш Мира от разстояние, което сам избра.",
	},
	"OPEN_DOOR": {
		"title": "THE OPEN DOOR",
		"color": Color(0.95, 0.6, 0.3),
		"text": "Още не знаеш точно какво строиш, но не си затворил сърцето си. "
			+ "Надеждата е останала. Вратата стои открехната — към хора, към възможности, "
			+ "към една по-истинска версия на теб.",
	},
	"PATH": {
		"title": "THE PATH",
		"color": Color(0.55, 0.8, 0.55),
		"text": "Избираш занаят и си слагаш ясна граница. Болката не изчезва с магия — "
			+ "но сега тя сочи нанякъде. Знаеш какво правиш утре и защо. "
			+ "„Ако откриеш какво наистина искаш и аз съм част от него, знаеш къде да ме намериш.\"",
	},
}

func _ready() -> void:
	AudioDirector.play_cue("ghost")
	var key := GameState.evaluate_ending()
	var data: Dictionary = ENDINGS.get(key, ENDINGS["OPEN_DOOR"])
	_build_ui(key, data)


func _build_ui(key: String, data: Dictionary) -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var backdrop := GradientBackdropScene.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.top_color = Color(0.02, 0.02, 0.05)
	backdrop.bottom_color = data["color"] * 0.25
	add_child(backdrop)

	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_CENTER)
	vb.custom_minimum_size = Vector2(1200, 0)
	vb.add_theme_constant_override("separation", 22)
	add_child(vb)

	var kicker := Label.new()
	kicker.text = "КРАЙ НА VERTICAL SLICE-А"
	kicker.add_theme_font_size_override("font_size", 20)
	kicker.modulate = Color(0.7, 0.75, 0.85)
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(kicker)

	var title := Label.new()
	title.text = String(data["title"])
	title.add_theme_font_size_override("font_size", 72)
	title.modulate = data["color"]
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)

	var body := Label.new()
	body.text = String(data["text"])
	body.add_theme_font_size_override("font_size", 26)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(1200, 0)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(body)

	var stats_line := Label.new()
	stats_line.text = "Самоуважение %d · Надежда %d · Емоц. стабилност %d · Привързаност %d" % [
		GameState.get_stat("selfrespect"), GameState.get_stat("hope"),
		GameState.get_stat("emotional"), GameState.get_stat("attachment")]
	stats_line.add_theme_font_size_override("font_size", 20)
	stats_line.modulate = Color(0.7, 0.75, 0.85)
	stats_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(stats_line)

	var btn := Button.new()
	btn.text = "Към главното меню"
	btn.custom_minimum_size = Vector2(360, 56)
	btn.pressed.connect(func(): SceneRouter.goto("res://scenes/main_menu/MainMenu.tscn"))
	var center := CenterContainer.new()
	center.add_child(btn)
	vb.add_child(center)
	btn.grab_focus()
