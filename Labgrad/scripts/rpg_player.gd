extends CharacterBody2D

const SPEED := 180.0
const CHAO_Y := 480.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")
	position.y = CHAO_Y
	
	if sprite != null:
		sprite.play("stop")

func _physics_process(_delta: float) -> void:
	var direcao := 0.0

	if Input.is_action_pressed("ui_right"):
		direcao += 1.0

	if Input.is_action_pressed("ui_left"):
		direcao -= 1.0

	velocity.x = direcao * SPEED
	velocity.y = 0.0
	position.y = CHAO_Y

	move_and_slide()
	atualizar_animacao(direcao)

func atualizar_animacao(direcao: float) -> void:
	if sprite == null:
		return

	if direcao > 0.0:
		sprite.play("default")	
	elif direcao < 0.0:
		sprite.play("back")
	else:
		sprite.play("stop")


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass
	get_tree().change_scene_to_file("res://map/scenes/mapa.tscn")
