extends Node2D

const GRID_SIZE = 32
const GRID_WIDTH = 36
const GRID_HEIGHT = 20

const MAX_ITEMS = 12
const SPAWN_INTERVAL = 0.3

enum ItemType { NOTA_BOA, NOTA_RUIM, MOEDA, PECA_PC, COLA_PROVA, PROVA_EM_BRANCO }

const ICONS_TEXTURE = preload("res://adventure/assets/icons.png")

const ITEM_FRAMES = {
	ItemType.MOEDA: 0,
	ItemType.NOTA_BOA: 1,
	ItemType.PECA_PC: 2, 
	ItemType.COLA_PROVA: 4,
	ItemType.NOTA_RUIM: 5,
	ItemType.PROVA_EM_BRANCO: 6,
}

const ITEM_LIFETIMES = {
	ItemType.NOTA_BOA: 8.0,
	ItemType.NOTA_RUIM: 8.0,
	ItemType.MOEDA: 6.0,
	ItemType.PECA_PC: 10.0,
	ItemType.COLA_PROVA: 5.0,
	ItemType.PROVA_EM_BRANCO: 6.0,
}

const ITEM_COLORS = {
	ItemType.NOTA_BOA: Color(0.2, 0.8, 0.2),
	ItemType.NOTA_RUIM: Color(0.9, 0.2, 0.2),
	ItemType.MOEDA: Color(1.0, 0.85, 0.0),
	ItemType.PECA_PC: Color(0.2, 0.6, 1.0),
	ItemType.COLA_PROVA: Color(0.8, 0.1, 0.8),
	ItemType.PROVA_EM_BRANCO: Color(0.7, 0.7, 0.7),
}

var items: Array = []
var spawn_timer: float = 0.0
var snake_ref = null

func _ready():
	for i in range(MAX_ITEMS):
		_spawn_item()

func setup(snake: Node2D):
	snake_ref = snake

func _process(delta):
	if not snake_ref or not snake_ref.is_alive:
		return

	spawn_timer += delta

	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0.0
		if items.size() < MAX_ITEMS:
			_spawn_item()

	var to_remove = []
	for i in range(items.size()):
		var item = items[i]
		item["timer"] += delta

		if item["timer"] >= item["lifetime"]:
			to_remove.append(i)
			continue

		if snake_ref.get_head_position() == item["position"]:
			_collect_item(item)
			to_remove.append(i)

	for i in range(to_remove.size() - 1, -1, -1):
		if is_instance_valid(items[to_remove[i]]["sprite"]):
			items[to_remove[i]]["sprite"].queue_free()
		items.remove_at(to_remove[i])

	queue_redraw()

func _spawn_item():
	var roll = randf()
	var tipo: ItemType
	
	if roll < 0.20:
		tipo = ItemType.MOEDA
	elif roll < 0.40:
		tipo = ItemType.NOTA_BOA
	elif roll < 0.75:
		tipo = ItemType.PECA_PC 
	elif roll < 0.85:
		tipo = ItemType.NOTA_RUIM
	elif roll < 0.95:
		tipo = ItemType.COLA_PROVA
	else:
		tipo = ItemType.PROVA_EM_BRANCO

	var pos = _get_random_empty_cell()
	
	var sprite = Sprite2D.new()
	sprite.texture = ICONS_TEXTURE
	sprite.hframes = 4
	sprite.vframes = 2
	sprite.frame = ITEM_FRAMES[tipo]
	sprite.centered = true 
	
	var frame_width = sprite.texture.get_width() / 4.0
	var frame_height = sprite.texture.get_height() / 2.0
	var multiplicador_de_tamanho = 1.7 
	
	sprite.scale = Vector2(GRID_SIZE / frame_width, GRID_SIZE / frame_height) * multiplicador_de_tamanho
	sprite.position = Vector2(pos.x * GRID_SIZE + (GRID_SIZE / 2.0), pos.y * GRID_SIZE + (GRID_SIZE / 2.0))
	add_child(sprite)

	items.append({
		"type": tipo,
		"position": pos,
		"timer": 0.0,
		"lifetime": ITEM_LIFETIMES[tipo],
		"sprite": sprite 
	})

func _collect_item(item: Dictionary):
	match item["type"]:
		ItemType.NOTA_BOA:
			snake_ref.add_reputacao(40)
			snake_ref.shrink(1)
		ItemType.NOTA_RUIM:
			snake_ref.add_reputacao(-5)
			snake_ref.grow()
		ItemType.MOEDA:
			snake_ref.add_moedas(10)
		ItemType.PECA_PC:
			snake_ref.add_peca_pc()
			snake_ref.grow()
		ItemType.COLA_PROVA:
			snake_ref.add_reputacao(-20)
		ItemType.PROVA_EM_BRANCO:
			snake_ref.add_reputacao(-8)
			snake_ref.grow()
			snake_ref.grow()
			snake_ref.grow()
			snake_ref.grow()

func _get_random_empty_cell() -> Vector2:
	var occupied = []
	if snake_ref:
		occupied = snake_ref.segments.duplicate()
	for item in items:
		occupied.append(item["position"])

	var attempts = 0
	while attempts < 200:
		var pos = Vector2(randi() % GRID_WIDTH, randi() % GRID_HEIGHT)
		if not pos in occupied:
			return pos
		attempts += 1
	return Vector2(0, 0)

func _draw():
	for item in items:
		var x = item["position"].x * GRID_SIZE
		var y = item["position"].y * GRID_SIZE
		var color = ITEM_COLORS[item["type"]]
		var remaining = 1.0 - (item["timer"] / item["lifetime"])

		if remaining < 0.3 and is_instance_valid(item["sprite"]):
			item["sprite"].modulate.a = 0.5 + 0.5 * sin(item["timer"] * 15.0)
		elif is_instance_valid(item["sprite"]):
			item["sprite"].modulate.a = 1.0

		var bar_width = GRID_SIZE * remaining
		draw_rect(Rect2(x, y + GRID_SIZE - 4, GRID_SIZE, 3), Color(0.3, 0.3, 0.3))
		draw_rect(Rect2(x, y + GRID_SIZE - 4, bar_width, 3), color)
