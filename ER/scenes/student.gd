extends CharacterBody2D

@export var speed := 200.0

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.play("run")

func _physics_process(delta):
	velocity.x = speed
	move_and_slide()
