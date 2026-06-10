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

func _ready():
	self.position = initialPosition.position

func _physics_process(delta: float) -> void:
	# Add the gravity.
	var bg_height = background.region_rect.size.y * background.scale.y
	if self.position.y > bg_height:
		vidas -= 1
		vidasUI.text = "Vidas: " + str(vidas)
		if vidas == 0:
			perder_jogo()
		self.position = initialPosition.position
		#resetar camera!!
	if is_on_floor():
		jump_count = 0	
		
	if not is_on_floor():
		self.velocity += get_gravity() * delta
		if velocity.y<0:
			sprite2d.animation = "jump"
		else:
			sprite2d.animation = "fall"
		

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		self.velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps:
		self.velocity.y = JUMP_VELOCITY
		jump_count += 1
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		sprite2d.flip_h = direction < 0 
		if is_on_floor():
			sprite2d.animation = "run"
		self.velocity.x = direction * SPEED
	else:
		if is_on_floor():
			sprite2d.animation = "idle"
		self.velocity.x = move_toward(self.velocity.x, 0, SPEED)

	move_and_slide()
	
	
	
func update_points():
	points += 10
	pointsUI.text = "Points: " + str(points)
	if points >= 100:
		vencer_jogo()
		
func vencer_jogo():
	print("Você Ganhou!")
	
	get_tree().change_scene_to_file("res://platformer/scenes/menuPlatfomer.tscn")
	
func perder_jogo():
	print("Você Perdeu!")
	
	get_tree().change_scene_to_file("res://platformer/scenes/menuPlatfomer.tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("encostei no ", body.name)
	if  body.name == "enemy":
		if self.velocity.y > 0 and self.global_position.y < body.global_position.y:
			body.queue_free() 
			self.velocity.y = JUMP_VELOCITY 			
		else:
			vidas -= 1
			#print(vidas)
			vidasUI.text = "Vidas: " + str(vidas)
			if vidas == 0:
				perder_jogo()
			self.position = initialPosition.position
