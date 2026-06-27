extends Control



@export var label_resultado: Label 
@export var label_pontos: Label 
@export var label_vidas: Label 

func _ready() -> void:
	match GlobalData.resultado_di:
		"venceu":
			label_resultado.text = "Você venceu!"
		"perdeu":
			label_resultado.text = "Você perdeu..."
		_:
			label_resultado.text = ""
	
	label_pontos.text = "Pontos: " + str(GlobalData.pontos_di)
	label_vidas.text = "Vidas restantes: " + str(GlobalData.vidas_restantes_di)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://platformer/scenes/platformer.tscn")


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://rdc/scenes/pre_platformer.tscn")
