extends CharacterBody2D

const SPEED := 180.0
const CHAO_Y := 480.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")
	position.y = CHAO_Y

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1.0
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		direction.y += 1.0
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1.0

	velocity = direction.normalized() * SPEED
	move_and_slide()

	atualizar_animacao(direction)

func atualizar_animacao(direction: Vector2) -> void:
	if sprite == null:
		return

	if direction != Vector2.ZERO:
		if direction.x != 0.0:
			sprite.play("walk")
			sprite.flip_h = direction.x < 0.0
		elif direction.y != 0.0:
			sprite.flip_h = false
			if direction.y < 0.0:
				sprite.play("back")
			else:
				sprite.play("down")
	else:
		sprite.play("idle")

func _on_area_2d_area_entered(_area: Area2D) -> void:
	pass
