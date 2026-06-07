extends CharacterBody2D

const SPEED = 50.0
const DISTANCE = 64.0 

var direction := 1.0 
var start_x := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	start_x = self.global_position.x

func _physics_process(delta: float) -> void:
	

	velocity.x = direction * SPEED
	
	if self.global_position.x > start_x + DISTANCE:
		direction = -1.0
		
	elif self.global_position.x < start_x:
		direction = 1.0
	sprite.flip_h = direction < 0 
	move_and_slide()
