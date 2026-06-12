extends Area2D
class_name Obstacle

@export var grupo_extra := "obstaculo"

func _ready() -> void:
	add_to_group("elemento_dinamico")
	add_to_group(grupo_extra)
