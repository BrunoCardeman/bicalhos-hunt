extends Camera2D
@export var player: CharacterBody2D
@export var background: Sprite2D

func _ready() -> void:
	var bg_size = background.region_rect.size * background.scale
	self.limit_top = int(background.position.y) 
	self.limit_right = int(bg_size.x)
	self.limit_bottom = int(bg_size.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screen_width = get_viewport().get_visible_rect().size.x
	if player.position.x > screen_width/2:
		self.position = player.position
	else:
		self.position = Vector2(screen_width / 2, 324)
