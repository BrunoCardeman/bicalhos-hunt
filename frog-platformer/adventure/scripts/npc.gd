extends StaticBody2D

@export var dialogue_resource: DialogueResource
@onready var area = $Area2D
@onready var label = $Label

var player_nearby = false
var dialogue_open = false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	label.visible = false

func _on_body_entered(body):
	if body.name == "player":
		player_nearby = true
		label.visible = true

func _on_body_exited(body):
	if body.name == "player":
		player_nearby = false
		label.visible = false

func _process(_delta):
	if player_nearby and not dialogue_open and Input.is_action_just_pressed("ui_accept"):
		dialogue_open = true
		var title: String
		if GlobalData.jogou_minigame_snake:
			title = "avaliar_reputacao"
		elif GlobalData.falou_com_vivi_snake:
			title = "perguntar_de_novo"
		else:
			title = "start"
		DialogueManager.show_dialogue_balloon(dialogue_resource, title)
		DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

func _on_dialogue_finished(_resource):
	dialogue_open = false
	if GlobalData.ir_para_snake:
		GlobalData.ir_para_snake = false
		get_tree().change_scene_to_file("res://Corredor/scenes/Main.tscn")
