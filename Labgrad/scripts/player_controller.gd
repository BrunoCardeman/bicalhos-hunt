extends CharacterBody2D

const GRAVIDADE := 2200.0
const VELOCIDADE_PULO := -860.0
const POSICAO_Y_EM_PE := 500.0
const DESLOCAMENTO_AGACHADO := 28.0

@export var gameController: Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_colisao: CollisionShape2D = $Area2D/CollisionShape2D

var velocidade_vertical: float = 0.0
var esta_agachado: bool = false
var morreu: bool = false
var shape_em_pe := RectangleShape2D.new()
var shape_agachado := RectangleShape2D.new()

func _ready() -> void:
	if gameController == null:
		gameController = get_parent()
	shape_em_pe.size = Vector2(32.0, 80.0)
	shape_agachado.size = Vector2(45.0, 35.0)
	resetar()

func _physics_process(delta: float) -> void:
	if gameController == null or not gameController.pode_processar_jogo():
		if sprite.animation != "idle":
			sprite.play("idle")
		return

	position.x += gameController.obter_velocidade_atual() * delta

	var no_chao: bool = velocidade_vertical == 0.0 and position.y >= POSICAO_Y_EM_PE - 0.1
	var quer_agachar: bool = Input.is_action_pressed("agachar") and no_chao

	if quer_agachar != esta_agachado:
		aplicar_postura(quer_agachar)

	if Input.is_action_just_pressed("pular") and no_chao and not esta_agachado:
		velocidade_vertical = VELOCIDADE_PULO

	velocidade_vertical += GRAVIDADE * delta
	position.y += velocidade_vertical * delta

	var y_chao_atual: float = POSICAO_Y_EM_PE + (DESLOCAMENTO_AGACHADO if esta_agachado else 0.0)

	if position.y >= y_chao_atual:
		position.y = y_chao_atual
		velocidade_vertical = 0.0

	atualizar_animacao()

func aplicar_postura(agachado: bool) -> void:
	esta_agachado = agachado

	if esta_agachado:
		area_colisao.shape = shape_agachado
		area_colisao.position = Vector2(0.0, -18.0)
		sprite.scale.y = 1.0
		position.y = POSICAO_Y_EM_PE + DESLOCAMENTO_AGACHADO
	else:
		area_colisao.shape = shape_em_pe
		area_colisao.position = Vector2(0.0, -10.0)
		sprite.scale.y = 1.0
		position.y = POSICAO_Y_EM_PE
		

func atualizar_animacao() -> void:
	if morreu:
		if sprite.animation != "hurt":
			sprite.play("hurt")
	elif esta_agachado:
		if sprite.animation != "slide":
			sprite.play("slide")
	elif velocidade_vertical < 0.0:
		if sprite.animation != "jump":
			sprite.play("jump")
	elif velocidade_vertical > 0.0:
		if sprite.animation != "fall":
			sprite.play("fall")
	else:
		if sprite.animation != "default":
			sprite.play("default")

func resetar() -> void:
	position = Vector2(140.0, POSICAO_Y_EM_PE)
	velocidade_vertical = 0.0
	morreu = false
	aplicar_postura(false)
	atualizar_animacao()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if morreu:
		return

	if area.is_in_group("coletavel"):
		if gameController != null:
			gameController.coletar_item(area)

		area.call_deferred("queue_free")
		atualizar_animacao()
		return

	if area.is_in_group("obstaculo") or area.is_in_group("inimigo_aereo"):
		morreu = true
		sprite.play("hurt")

		await get_tree().create_timer(0.5).timeout

		if gameController != null:
			gameController.encerrar_partida()
