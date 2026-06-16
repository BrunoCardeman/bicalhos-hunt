extends Area2D

var main_dialogue = preload("res://dialog_vivi.dialogue")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	DialogueManager.show_dialogue_balloon(main_dialogue, "start", [self])
func ir_para_o_platformer():
	get_tree().change_scene_to_file("res://platformer/scenes/platformer.tscn")
