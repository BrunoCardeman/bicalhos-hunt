extends CharacterBody2D

@export var dialogue_resource: DialogueResource
@export var inventory: Array[InventorySlot]
@export var inventoryTileMap: TileMapLayer
@export var nota: Label

var bullet_scene = preload("res://Boss_fight/scenes/bullet.tscn")
var nLife = 3
var selected_item = null
var direction_x = 0
var direction_y = 0
var cooldown_time = 0
var last_direction: Vector2 = Vector2(1,0)
const SPEED = 100.0
var aceitou_missao = false

func _on_dialogue_signal(signal_name):
	if signal_name == "missao_aceita":
		aceitou_missao = true

func _on_dialogue_ended(_resource):
	if aceitou_missao:
		get_tree().change_scene_to_file("res://Boss_fight/scenes/BossFigth.tscn")


func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.mutated.connect(_on_dialogue_signal)
	for i in range(inventory.size()):
		var slot = inventory[i]
		var slot_sprite = Sprite2D.new()
		if slot:
			slot_sprite.texture = slot.item.sprite
			slot_sprite.position.y = 8
			slot_sprite.position.x = 16 * i + 6
			
func _input(event):	
	selected_item = inventory[0].item
			
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and selected_item:
			if cooldown_time > 0.5:
				var bullet_obj = bullet_scene.instantiate()
				var sprite = bullet_obj.get_node("Sprite2D")
				sprite.texture = selected_item.sprite
				
				bullet_obj.position = global_position
				
				var dir = (get_global_mouse_position() - global_position).normalized()
				bullet_obj.direction = dir
			
				get_parent().add_child(bullet_obj)
				cooldown_time = 0
				
func _physics_process(delta: float) -> void:
	cooldown_time += delta
	
	direction_x = Input.get_axis("LEFT", "RIGHT")
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	direction_y = Input.get_axis("UP", "DOWM")
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	if direction_x != 0 or direction_y != 0:
		last_direction = Vector2(direction_x, direction_y)

	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not (area is bullet) and not(area is professor)and not(area is porta):
		GlobalData.nota = GlobalData.nota -1
		print(GlobalData.nota)
		nota.text = "Nota: "+str(GlobalData.nota)


func _on_bicalio_area_entered(area: Area2D) -> void:
	var balloon = DialogueManager.show_dialogue_balloon(dialogue_resource, "start")

	await balloon.tree_exited

	if GlobalData.ir_top_down == true:
		get_tree().change_scene_to_file("res://Boss_fight/scenes/BossFigth.tscn")


func _on_porta_area_entered(area: Area2D) -> void:
	get_tree().change_scene_to_file("res://map/scenes/mapa.tscn") # Replace with function body.
