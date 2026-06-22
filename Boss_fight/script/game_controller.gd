extends Node2D

const MAPA_SCENE := "res://map/scenes/mapa.tscn"

var chicken_scene = preload("res://Boss_fight/scenes/chicken_enemy.tscn")

var spawn = true
var spawn_timer = 0.0
var nPoints = 0
var spawn_time = 3
var enemy_count = 0
var Nround = 1

@export var RoundLabel: Label
@export var Points: Label
@export var player: CharacterBody2D

var enemys

func _ready():	
	# Espera o jogo carregar completamente na tela antes de mudar o tamanho
	# Inicializa seus inimigos
	enemys = [chicken_scene]
	
func spawn_enemy():
	var random_x = 0
	var random_y = 0

	var random_num = randi_range(0, 100)

	var enemy_scene = enemys.pick_random()
	var obj = enemy_scene.instantiate()
	enemy_count+=1
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
func update_Round(n, sp):
	Nround += 1
	if RoundLabel != null && GameController.nPoints == n:
		RoundLabel.text = "ROUND: " + str(Nround)
	await get_tree().create_timer(2.0).timeout
	if RoundLabel != null:
		RoundLabel.text = ""
	spawn_time = sp
	spawn = true
	
func update_difficulty():
	print(nPoints)
	spawn_time = max(0.5, 3.0 - (nPoints * 0.1))

var terminou_fase = false

func _process(delta: float) -> void:

	if !terminou_fase and enemy_count >= 45 and Nround == 2:
		terminou_fase = true
		spawn = false
		
		GlobalData.jogou_minigame_540 = true
		GlobalData.ir_top_down = false

		get_tree().change_scene_to_file("res://540/scenes/540.tscn")
		return

	elif enemy_count >= 25 and Nround == 2:
		spawn = false
		if GameController.nPoints >= 25:
			spawn_time = 1.5
			update_Round(25, 1)

	elif enemy_count == 10 and Nround == 1:
		spawn = false
		if GameController.nPoints >= 10:
			spawn_time = 2
			update_Round(10, 2)

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
