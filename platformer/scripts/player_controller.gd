extends CharacterBody2D

@export var sprite2d: AnimatedSprite2D
@export var pointsUI: Label
@export var vidasUI: Label
@export var initialPosition: Node2D
@export var background: Sprite2D

var points = 0
var vidas = 3
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var jump_count = 0
var max_jumps = 2
var na_escada: bool = false 

func _ready():
	add_to_group("player") 
	# Usando call_deferred no _ready para garantir carregamento seguro
	call_deferred("set_global_position", initialPosition.global_position)

func _physics_process(delta: float) -> void:
	# --- VERIFICAÇÃO DE QUEDA DO MAPA ---
	var bg_height = background.region_rect.size.y * background.scale.y
	if self.position.y > bg_height:
		vidas -= 1
		vidasUI.text = "Vidas: " + str(vidas)
		if vidas <= 0:
			perder_jogo()
		else:
			# Teleporte seguro para a física não quebrar
			call_deferred("set_global_position", initialPosition.global_position)

	if is_on_floor():
		jump_count = 0	

	# --- LÓGICA DA ESCADA VS GRAVIDADE ---
	if na_escada:
		var dir_y = Input.get_axis("ui_up", "ui_down")
		if dir_y:
			self.velocity.y = dir_y * SPEED
			sprite2d.animation = "climb"
		else:
			self.velocity.y = 0 
			sprite2d.animation = "static_climb" 
			
		if Input.is_action_just_pressed("ui_accept"):
			self.velocity.y = JUMP_VELOCITY
			na_escada = false
	else:
		if not is_on_floor():
			self.velocity += get_gravity() * delta
			if velocity.y < 0:
				sprite2d.animation = "jump"
			else:
				sprite2d.animation = "fall"

	# --- LÓGICA DE PULO ---
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		self.velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps and not na_escada:
		self.velocity.y = JUMP_VELOCITY
		jump_count += 1

	# --- LÓGICA DE MOVIMENTO HORIZONTAL ---
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		sprite2d.flip_h = direction < 0 
		if is_on_floor() and not na_escada:
			sprite2d.animation = "run"
		self.velocity.x = direction * SPEED
	else:
		if is_on_floor() and not na_escada:
			sprite2d.animation = "idle"
		self.velocity.x = move_toward(self.velocity.x, 0, SPEED)

	move_and_slide()

# --- FUNÇÕES DE JOGO E INIMIGO ---

func update_points():
	points += 10
	pointsUI.text = "Points: " + str(points)
	if points >= 100:
		vencer_jogo()

func vencer_jogo():
	GlobalData.voltou_do_platformer = true
	GlobalData.resultado_di = "venceu"
	GlobalData.jogou_minigame_di = true
	GlobalData.pontos_di = points
	GlobalData.vidas_restantes_di = vidas
	get_tree().change_scene_to_file("res://platformer/scenes/menuPlatfomer.tscn")

func perder_jogo():
	GlobalData.voltou_do_platformer = true
	GlobalData.resultado_di = "perdeu"
	GlobalData.pontos_di = points
	GlobalData.vidas_restantes_di = vidas
	get_tree().change_scene_to_file("res://platformer/scenes/menuPlatfomer.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "enemy":
		if self.velocity.y > 0 and self.global_position.y < body.global_position.y:
			body.queue_free() 
			self.velocity.y = JUMP_VELOCITY 			
		else:
			vidas -= 1
			vidasUI.text = "Vidas: " + str(vidas)
			if vidas <= 0:
				perder_jogo()
			else:
				# Teleporte seguro para a física não quebrar
				call_deferred("set_global_position", initialPosition.global_position)
