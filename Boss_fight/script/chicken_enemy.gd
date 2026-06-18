extends Area2D

class_name Enemy

@export var points : Label
@export var player: CharacterBody2D = null
var SPEED = 80

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if player:
		position = position.move_toward(player.position, delta * SPEED)


func _on_area_entered(area: Area2D) -> void:
	# Verifica se a área que entrou é do tipo da classe 'bullet'
	if area is bullet:
		GameController.nPoints += 1
		if points != null:
			points.text = "Points: " + str(GameController.nPoints)
		
		queue_free() # Inimigo morre instantaneamente com 1 tiro!
