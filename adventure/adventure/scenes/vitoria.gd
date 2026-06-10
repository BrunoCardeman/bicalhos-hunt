extends Node2D

func _ready():
	$CanvasLayer/menu.pressed.connect(_on_menu)

func _on_menu():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
