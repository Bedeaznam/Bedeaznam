extends Control
## Generic visitable location (room/workshop, tavern, mountain). Ambiance +
## flavor text drawn procedurally; returns to the hub. Set `location_id` per scene.

@export var location_id: String = "room"

const GradientBackdropScene := preload("res://scripts/ui/gradient_backdrop.gd")
const HUDScene := preload("res://scripts/ui/HUD.gd")

const DATA := {
	"room": {
		"title": "Стаята / работилницата на Ясен",
		"flavor": "Тесен апартамент. 3D принтер бръмчи в ъгъла, лаптоп с отворен терминал, "
			+ "макари филамент, платка с наполовина запоени проводници. На стената — план "
			+ "за робот. Тук се раждат проектите между смените.",
		"top": Color(0.05, 0.06, 0.1), "bottom": Color(0.1, 0.08, 0.06),
	},
	"tavern": {
		"title": "Механата",
		"flavor": "Топла оранжева светлина, дим и глъч. Клиенти на няколко езика, звън на чаши. "
			+ "Малка сцена в дъното, където Мира пее петък и събота. Тук печелиш пари — и губиш нерви.",
		"top": Color(0.08, 0.05, 0.04), "bottom": Color(0.16, 0.09, 0.04),
	},
	"mountain": {
		"title": "Планината",
		"flavor": "Над града се издига билото. Букова гора, каменист сипей, мъгла между боровете. "
			+ "Тук дишаш. Тук мислите се подреждат — или се разпадат.",
		"top": Color(0.03, 0.06, 0.08), "bottom": Color(0.06, 0.12, 0.1),
	},
}

func _ready() -> void:
	var d: Dictionary = DATA.get(location_id, DATA["room"])
	if location_id == "tavern":
		AudioDirector.play_cue("tavern")
	elif location_id == "mountain":
		AudioDirector.play_cue("mountain")
	else:
		AudioDirector.play_cue("workshop")
	_build(d)


func _build(d: Dictionary) -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var backdrop := GradientBackdropScene.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.top_color = d["top"]
	backdrop.bottom_color = d["bottom"]
	add_child(backdrop)

	var hud := HUDScene.new()
	add_child(hud)

	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_CENTER)
	vb.custom_minimum_size = Vector2(1100, 0)
	vb.add_theme_constant_override("separation", 20)
	add_child(vb)

	var title := Label.new()
	title.text = String(d["title"])
	title.add_theme_font_size_override("font_size", 48)
	title.modulate = Color(1, 0.75, 0.4)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)

	var flavor := Label.new()
	flavor.text = String(d["flavor"])
	flavor.add_theme_font_size_override("font_size", 26)
	flavor.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flavor.custom_minimum_size = Vector2(1100, 0)
	flavor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(flavor)

	var btn := Button.new()
	btn.text = "Върни се в града"
	btn.custom_minimum_size = Vector2(320, 52)
	btn.pressed.connect(func(): SceneRouter.return_to_hub())
	var cc := CenterContainer.new()
	cc.add_child(btn)
	vb.add_child(cc)
	btn.grab_focus()
