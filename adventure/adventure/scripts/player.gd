extends CharacterBody2D

const SPEED = 1000.0

@onready var inventory_label = $CanvasLayer/PanelContainer/InventoryLabel

func _ready():
	add_to_group("player")
	update_inventory()

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	velocity = direction.normalized() * SPEED
	move_and_slide()
	update_inventory()

func update_inventory():
	var itens = "vazio" if GlobalData.inventory.is_empty() else ", ".join(GlobalData.inventory)
	inventory_label.text = "Inventário: " + itens + "\nLevel: " + str(GlobalData.player_level) + " | XP: " + str(GlobalData.xp) + "/" + str(GlobalData.xp_para_level2)
	
	if GlobalData.player_level >= 2:
		get_tree().change_scene_to_file("res://scenes/vitoria.tscn")
