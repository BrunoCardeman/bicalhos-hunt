extends Area2D

@export var target_scene: String = "res://scenes/mundo2.tscn"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "player":
		get_tree().change_scene_to_file(target_scene)
