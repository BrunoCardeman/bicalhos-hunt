extends Node2D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		print("ESC pressionado! Voltando ao mapa...")
		get_tree().change_scene_to_file("res://map/scenes/mapa.tscn")
