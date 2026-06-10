extends StaticBody2D

@export var dialogue_resource: DialogueResource
@onready var area = $Area2D
@onready var label = $Label

var player_nearby = false

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
	if player_nearby and Input.is_action_just_pressed("ui_accept"):
		DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
		DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

func _on_dialogue_finished(_resource):
	if not GlobalData.enemy2_defeated and GlobalData.has_sword:
		get_tree().change_scene_to_file("res://scenes/batalha2.tscn")
