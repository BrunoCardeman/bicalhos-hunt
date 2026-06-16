extends Node2D

var player_hp = 30
var player_max_hp = 30
var player_defending = false

var enemy_hp = 25
var enemy_max_hp = 25

@onready var hp_player = $CanvasLayer/HPplayer
@onready var hp_inimigo = $CanvasLayer/hpinimigo
@onready var btn_atacar = $CanvasLayer/BotaoAtacar
@onready var btn_defender = $CanvasLayer/BotaoDefender
@onready var btn_fugir = $CanvasLayer/BotaoFugir
@onready var btn_espada = $CanvasLayer/ataqueEspada
@onready var label_turno = $CanvasLayer/turno

func _ready():
	btn_atacar.pressed.connect(_on_atacar)
	btn_defender.pressed.connect(_on_defender)
	btn_fugir.pressed.connect(_on_fugir)
	btn_espada.pressed.connect(_on_espada)
	update_ui()
	label_turno.text = "TURNO: Seu turno!"
	if not "Espada" in GlobalData.inventory:
		btn_espada.disabled = true

func update_ui():
	hp_player.max_value = player_max_hp
	hp_player.value = player_hp
	hp_inimigo.max_value = enemy_max_hp
	hp_inimigo.value = enemy_hp

func set_buttons(ativo: bool):
	btn_atacar.disabled = not ativo
	btn_defender.disabled = not ativo
	btn_fugir.disabled = not ativo
	if "Espada" in GlobalData.inventory:
		btn_espada.disabled = not ativo

func _on_atacar():
	var dano = randi_range(3, 6)
	enemy_hp -= dano
	player_defending = false
	update_ui()
	set_buttons(false)
	label_turno.text = "TURNO: Turno do inimigo..."
	if enemy_hp <= 0:
		vencer()
		return
	await get_tree().create_timer(1.0).timeout
	turno_inimigo()

func _on_espada():
	var dano = randi_range(8, 15)
	enemy_hp -= dano
	player_defending = false
	update_ui()
	set_buttons(false)
	label_turno.text = "TURNO: Turno do inimigo..."
	if enemy_hp <= 0:
		vencer()
		return
	await get_tree().create_timer(1.0).timeout
	turno_inimigo()

func _on_defender():
	player_defending = true
	set_buttons(false)
	label_turno.text = "TURNO: Turno do inimigo..."
	await get_tree().create_timer(1.0).timeout
	turno_inimigo()

func _on_fugir():
	get_tree().change_scene_to_file("res://scenes/mundo2.tscn")

func turno_inimigo():
	var dano = randi_range(1, 5)
	if player_defending:
		dano = dano / 2
	player_hp -= dano
	player_defending = false
	update_ui()
	if player_hp <= 0:
		perder()
		return
	label_turno.text = "TURNO: Seu turno!"
	set_buttons(true)

func vencer():
	GlobalData.enemies_killed += 1
	GlobalData.ganhar_xp(10)
	GlobalData.enemy1_defeated = true
	label_turno.text = "Você venceu!"
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/mundo2.tscn")

func perder():
	label_turno.text = "Você perdeu!"
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/mundo2.tscn")
