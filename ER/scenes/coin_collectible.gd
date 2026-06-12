extends Area2D

func _ready() -> void:
	add_to_group("coletavel")
	add_to_group("elemento_dinamico")
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color(1, 0.84, 0.15, 1))
	draw_arc(Vector2.ZERO, 10.0, 0, TAU, 24, Color(1, 1, 0.6, 1), 2.0)
