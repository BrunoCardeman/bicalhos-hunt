extends Area2D

var main_dialogue = preload("res://rdc/dialog_vivi.dialogue")
var saida_dialogue = preload("res://rdc/dialog_vivi_saida.dialogue")
var rdc_balloon = preload("res://rdc/scenes/rdc_balloon.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(_body: Node2D) -> void:
	DialogueManager.show_dialogue_balloon_scene(rdc_balloon, main_dialogue, "start", [self])
func ir_para_o_platformer():
	get_tree().change_scene_to_file("res://platformer/scenes/platformer.tscn")
func _ready() -> void:
	if GlobalData.voltou_do_platformer:
		GlobalData.voltou_do_platformer = false
		DialogueManager.show_dialogue_balloon_scene(rdc_balloon, saida_dialogue, "saida_" + GlobalData.resultado_di, [self])
