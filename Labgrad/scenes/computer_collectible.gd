extends Area2D

@export var item_color := "blue"
@export var item_type := "motherboard"

@onready var sprite: Sprite2D = $Sprite2D

const TEXTURE_PATH := "res://Labgrad/assets/img/collectibles/%s_%s.png"

func _ready() -> void:
	add_to_group("coletavel")
	add_to_group("elemento_dinamico")
	atualizar_visual()

func configurar(tipo: String, cor: String) -> void:
	item_type = tipo
	item_color = cor
	atualizar_visual()

func atualizar_visual() -> void:
	if sprite == null:
		return
	var caminho := TEXTURE_PATH % [item_type, item_color]
	if ResourceLoader.exists(caminho):
		sprite.texture = load(caminho)
