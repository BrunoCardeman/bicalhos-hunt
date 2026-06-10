extends Node2D

const GRID_SIZE = 32
const GRID_WIDTH = 36
const GRID_HEIGHT = 20

const BASE_SPEED = 0.18
const MIN_SPEED = 0.08
const SPEED_INCREMENT = 0.01

const PHASE_TIME = 60.0

var segments: Array = []
var direction: Vector2 = Vector2.RIGHT
var next_direction: Vector2 = Vector2.RIGHT
var move_timer: float = 0.0
var current_speed: float = BASE_SPEED
var is_alive: bool = true

var moedas: int = 0
var reputacao: int = 0
var pecas_pc: Array = [] 

var time_remaining: float = PHASE_TIME
var phase_active: bool = true

var speed_boost_active: bool = false
var speed_boost_timer: float = 0.0
var slow_active: bool = false
var slow_timer: float = 0.0

const POWERUP_DURATION = 7.0

const PECAS_NOMES = [
	"Placa de Video",
	"Processador",
	"Memoria RAM",
	"SSD",
	"Fonte",
	"Cooler",
	"Placa Mae",
	"Cabo HDMI",
]

signal recursos_changed(moedas, reputacao, pecas_pc)
signal timer_changed(time_remaining)
signal phase_ended(moedas, reputacao, pecas_pc)
signal snake_died(moedas, reputacao, pecas_pc)
signal powerup_activated(type, duration)

func _ready():
	spawn_snake()

func spawn_snake():
	segments.clear()
	var start = Vector2(5, 10)
	for i in range(3):
		segments.append(start - Vector2(i, 0))
	direction = Vector2.RIGHT
	next_direction = Vector2.RIGHT
	current_speed = BASE_SPEED
	moedas = 0
	reputacao = 0
	pecas_pc = []
	time_remaining = PHASE_TIME
	is_alive = true
	phase_active = true
	speed_boost_active = false
	slow_active = false
	emit_signal("recursos_changed", moedas, reputacao, pecas_pc)
	emit_signal("timer_changed", time_remaining)

func _process(delta):
	if not is_alive or not phase_active:
		return

	time_remaining -= delta
	emit_signal("timer_changed", time_remaining)
	if time_remaining <= 0.0:
		time_remaining = 0.0
		_end_phase()
		return

	if Input.is_action_just_pressed("ui_right") and direction != Vector2.LEFT:
		next_direction = Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_left") and direction != Vector2.RIGHT:
		next_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_up") and direction != Vector2.DOWN:
		next_direction = Vector2.UP
	elif Input.is_action_just_pressed("ui_down") and direction != Vector2.UP:
		next_direction = Vector2.DOWN

	_update_powerup_timers(delta)

	move_timer += delta
	var effective_speed = current_speed
	if speed_boost_active:
		effective_speed = max(current_speed * 0.5, MIN_SPEED)
	elif slow_active:
		effective_speed = current_speed * 1.6

	if move_timer >= effective_speed:
		move_timer = 0.0
		_move()

	queue_redraw()

func _update_powerup_timers(delta):
	if speed_boost_active:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			speed_boost_active = false

	if slow_active:
		slow_timer -= delta
		if slow_timer <= 0:
			slow_active = false

func _move():
	direction = next_direction
	var new_head = segments[0] + direction

	if new_head.x < 0 or new_head.x >= GRID_WIDTH or new_head.y < 0 or new_head.y >= GRID_HEIGHT:
		_die()
		return

	for i in range(1, segments.size()):
		if new_head == segments[i]:
			_die()
			return

	segments.push_front(new_head)
	segments.pop_back()

func grow():
	var tail = segments[segments.size() - 1]
	segments.append(tail)

func shrink(amount: int = 2):
	for i in range(amount):
		if segments.size() > 1:
			segments.pop_back()

func add_moedas(valor: int):
	moedas += valor
	emit_signal("recursos_changed", moedas, reputacao, pecas_pc)
	current_speed = max(MIN_SPEED, BASE_SPEED - (moedas / 20.0) * SPEED_INCREMENT * 5)

func add_reputacao(valor: int):
	reputacao += valor
	emit_signal("recursos_changed", moedas, reputacao, pecas_pc)

func add_peca_pc():
	var nome = PECAS_NOMES[randi() % PECAS_NOMES.size()]
	pecas_pc.append(nome)
	emit_signal("recursos_changed", moedas, reputacao, pecas_pc)

func activate_speed_boost():
	speed_boost_active = true
	speed_boost_timer = POWERUP_DURATION
	emit_signal("powerup_activated", "speed_boost", POWERUP_DURATION)

func activate_slow():
	slow_active = true
	slow_timer = POWERUP_DURATION
	emit_signal("powerup_activated", "slow", POWERUP_DURATION)

func get_head_position() -> Vector2:
	return segments[0]

func occupies(pos: Vector2) -> bool:
	return pos in segments

func _transferir_para_global():
	GlobalData.moedas += moedas
	GlobalData.alterar_reputacao(reputacao)
	for peca in pecas_pc:
		GlobalData.add_item(peca)
	GlobalData.jogou_minigame_snake = true

func _die():
	is_alive = false
	phase_active = false
	_transferir_para_global()
	emit_signal("snake_died", moedas, reputacao, pecas_pc)

func _end_phase():
	phase_active = false
	is_alive = false
	_transferir_para_global()
	emit_signal("phase_ended", moedas, reputacao, pecas_pc)

func _draw():
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var rect = Rect2(x * GRID_SIZE, y * GRID_SIZE, GRID_SIZE - 1, GRID_SIZE - 1)
			draw_rect(rect, Color(0.1, 0.15, 0.1))

	if not is_alive:
		return

	for i in range(1, segments.size()):
		var pos = segments[i]
		var rect = Rect2(pos.x * GRID_SIZE + 1, pos.y * GRID_SIZE + 1, GRID_SIZE - 3, GRID_SIZE - 3)
		var color = Color(0.2, 0.8, 0.2)
		if speed_boost_active:
			color = Color(0.2, 0.9, 0.9)
		elif slow_active:
			color = Color(0.6, 0.1, 0.9)
		draw_rect(rect, color)

	if segments.size() > 0:
		var head = segments[0]
		var rect = Rect2(head.x * GRID_SIZE + 1, head.y * GRID_SIZE + 1, GRID_SIZE - 3, GRID_SIZE - 3)
		draw_rect(rect, Color(0.1, 1.0, 0.1))
		var eye_offset = Vector2(8, 6)
		if direction == Vector2.RIGHT:
			eye_offset = Vector2(20, 8)
		elif direction == Vector2.LEFT:
			eye_offset = Vector2(6, 8)
		elif direction == Vector2.UP:
			eye_offset = Vector2(8, 6)
		elif direction == Vector2.DOWN:
			eye_offset = Vector2(8, 20)
		draw_circle(Vector2(head.x * GRID_SIZE + eye_offset.x, head.y * GRID_SIZE + eye_offset.y), 3, Color.BLACK)
