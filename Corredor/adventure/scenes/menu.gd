extends Control

@onready var btn_jogar = $BotaoJogar
@onready var btn_sair = $BotaoSair

func _ready():
	btn_jogar.pressed.connect(_on_jogar)
	btn_sair.pressed.connect(_on_sair)

func _on_jogar():
	get_tree().change_scene_to_file("res://scenes/mundo1.tscn")

func _on_sair():
	get_tree().quit()
