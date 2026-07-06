extends CharacterBody2D

const SPEED := 180.0
const CHAO_Y := 480.0
const ANIM_FRONT := "front"
const ANIM_BACK := "back"
const ANIM_IDLE := "idle"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")
	position.y = CHAO_Y
	atualizar_animacao(0.0)

func _physics_process(_delta: float) -> void:
	var direction_x := 0.0

	if Input.is_action_pressed("RIGHT") or Input.is_action_pressed("ui_right"):
		direction_x += 1.0
	if Input.is_action_pressed("LEFT") or Input.is_action_pressed("ui_left"):
		direction_x -= 1.0

	velocity = Vector2(direction_x * SPEED, 0.0)
	move_and_slide()
	position.y = CHAO_Y

	atualizar_animacao(direction_x)

func atualizar_animacao(direction_x: float) -> void:
	if sprite == null:
		return

	sprite.flip_h = false

	if direction_x > 0.0:
		sprite.play(ANIM_FRONT)
	elif direction_x < 0.0:
		sprite.play(ANIM_BACK)
	else:
		sprite.play(ANIM_IDLE)

func _on_area_2d_area_entered(_area: Area2D) -> void:
	pass


func _on_vivi_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
