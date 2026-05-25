extends Node2D

var chicken_scene = preload("res://Top-down-Shooter/scenes/chicken_enemy.tscn")
var cow_scene = preload("res://Top-down-Shooter/scenes/cow_enemy.tscn")

var spawn_timer = 0.0
var nPoints = 0
var spawn_time = 0.5
var enemy_count = 0

@export var Points: Label
@export var player: CharacterBody2D

var enemys

func _ready() -> void:
	enemys = [chicken_scene, cow_scene]

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

func update_difficulty():
	print(nPoints)
	spawn_time = max(0.5, 3.0 - (nPoints * 0.1))

func _process(delta: float) -> void:

	if enemy_count >= 6:
		spawn_time = 0.5
	elif enemy_count >= 4:
		spawn_time = 1.0
	elif enemy_count >= 2:
		spawn_time = 2
	else:
		spawn_time = 3

	spawn_timer += delta

	if spawn_timer >= spawn_time:
		print(spawn_time)
		spawn_enemy()
		spawn_timer = 0
