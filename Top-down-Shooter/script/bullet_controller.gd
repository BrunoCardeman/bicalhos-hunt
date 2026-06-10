extends Area2D
class_name bullet

@export var direction: Vector2
const SPEED = 300.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += direction.x * SPEED * delta
	position.y += direction.y * SPEED * delta
	
	if position.x < 0 or position.x > get_viewport().size.x or position.y < 0 or position.y > get_viewport().size.y:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Enemy:
		queue_free()
