extends Control
class_name GradientBackdrop
## A cheap vertical-gradient backdrop drawn procedurally (no image assets).

@export var top_color: Color = Color(0.02, 0.03, 0.06)
@export var bottom_color: Color = Color(0.06, 0.09, 0.14)
@export var vignette: bool = true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var colors := PackedColorArray([top_color, top_color, bottom_color, bottom_color])
	var pts := PackedVector2Array([
		r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y),
	])
	draw_polygon(pts, colors)
	if vignette:
		for i in 6:
			var a := 0.04 * (i + 1)
			var m := 40.0 * (6 - i)
			draw_rect(Rect2(Vector2(m, m), size - Vector2(m, m) * 2.0),
				Color(0, 0, 0, a), false, 8.0)
