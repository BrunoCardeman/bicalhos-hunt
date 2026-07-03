extends CharacterBody2D

const SPEED = 300.0

@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	add_to_group("player")

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

	_atualizar_animacao(direction)

func _atualizar_animacao(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if direction.x != 0:
			animacao.play("walk")
			animacao.flip_h = direction.x < 0
		elif direction.y != 0:
			animacao.flip_h = false
			if direction.y < 0:
				animacao.play("back")
			else:
				animacao.play("down")
	else:
		animacao.play("idle")
