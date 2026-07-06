extends Node2D
const MAPA_SCENE := "res://map/scenes/mapa.tscn"
var chicken_scene = preload("res://Boss_fight/scenes/chicken_enemy.tscn")

var nPoints = 0
var spawn = true
var spawn_timer = 0.0
var spawn_time = 3
var enemy_count = 0
var Nround = 1
var terminou_fase = false

@export var RoundLabel: Label
@export var Points: Label
@export var player: CharacterBody2D
var enemys

func _ready():
	enemys = [chicken_scene]

func spawn_enemy():
	var random_x = 0
	var random_y = 0
	var random_num = randi_range(0, 100)
	var enemy_scene = enemys.pick_random()
	var obj = enemy_scene.instantiate()
	enemy_count += 1
	obj.points = Points
	if random_num < 25:
		random_x = randf_range(0, get_viewport().size.x)
		random_y = -50
	elif random_num < 50:
		random_x = get_viewport().size.x + 50
		random_y = randf_range(0, get_viewport().size.y)
	elif random_num < 75:
		random_x = randf_range(0, get_viewport().size.x)
		random_y = get_viewport().size.y + 50
	else:
		random_x = -50
		random_y = randf_range(0, get_viewport().size.y)
	obj.position = Vector2(random_x, random_y)
	if player:
		obj.player = player
	add_child(obj)

func update_Round(sp):
	Nround += 1
	if RoundLabel != null:
		RoundLabel.text = "ROUND: " + str(Nround)
	await get_tree().create_timer(2.0).timeout
	if RoundLabel != null:
		RoundLabel.text = ""
	spawn_time = sp
	spawn = true

func update_difficulty():
	print(GameController.nPoints)
	spawn_time = max(0.5, 3.0 - (GameController.nPoints * 0.1))

func _process(delta: float) -> void:
	# FIM DE FASE — só quando o jogador realmente MATOU (nPoints) os 45
	if terminou_fase == false and GameController.nPoints >= 45 and Nround == 3:
		terminou_fase = true
		spawn = false
		GlobalData.jogou_minigame_540 = true
		GlobalData.ir_top_down = false
		print("Pontos", GameController.nPoints)
		get_tree().change_scene_to_file("res://540/scenes/540.tscn")
		return

	# ROUND 1: para de spawnar assim que spawnar o 10º
	if Nround == 1 and enemy_count >= 10:
		spawn = false
		# só avança de round quando o jogador MATAR todos os 10
		if GameController.nPoints >= 10:
			update_Round(2)

	# ROUND 2: para de spawnar assim que spawnar o 25º
	elif Nround == 2 and enemy_count >= 25:
		spawn = false
		# só avança de round quando o jogador MATAR todos os 25
		if GameController.nPoints >= 25:
			update_Round(1.5)

	spawn_timer += delta
	if spawn_timer >= spawn_time:
		if spawn:
			spawn_enemy()
		spawn_timer = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().call_deferred("change_scene_to_file", MAPA_SCENE)
		get_viewport().set_input_as_handled()
		return
