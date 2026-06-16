extends Node

var has_sword: bool = false
var player_level: int = 1
var enemies_killed: int = 0
var total_enemies: int = 2
var xp: int = 0
var xp_para_level2: int = 20
var inventory: Array = []
var enemy1_defeated: bool = false
var enemy2_defeated: bool = false

func add_item(item: String):
	inventory.append(item)

func ganhar_xp(quantidade: int):
	xp += quantidade
	if xp >= xp_para_level2 and player_level == 1:
		player_level = 2
		add_item("Amuleto Sagrado")
		print("LEVEL UP! Item coletado!")
