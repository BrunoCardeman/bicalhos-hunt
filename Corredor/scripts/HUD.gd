extends CanvasLayer

@onready var moedas_label = $MoedasLabel
@onready var reputacao_label = $ReputacaoLabel
@onready var pecas_label = $PecasLabel
@onready var timer_label = $TimerLabel
@onready var powerup_label = $PowerupLabel
@onready var result_panel = $ResultPanel
@onready var result_moedas = $ResultPanel/ResultMoedas
@onready var result_reputacao = $ResultPanel/ResultReputacao
@onready var result_title = $ResultPanel/ResultTitle
@onready var restart_button = $ResultPanel/ContinueButton
@onready var inventory_grid = $ResultPanel/InventoryGrid

var powerup_timer_display: float = 0.0
var active_powerup_name: String = ""

const PECA_CORES = {
	"Placa de Video": Color(0.2, 0.6, 1.0),
	"Processador": Color(1.0, 0.6, 0.0),
	"Memoria RAM": Color(0.2, 0.9, 0.5),
	"SSD": Color(0.9, 0.9, 0.2),
	"Fonte": Color(0.8, 0.2, 0.2),
	"Cooler": Color(0.4, 0.8, 1.0),
	"Placa Mae": Color(0.7, 0.3, 0.9),
	"Cabo HDMI": Color(0.5, 0.5, 0.5),
}

const PECA_SIGLAS = {
	"Placa de Video": "GPU",
	"Processador": "CPU",
	"Memoria RAM": "RAM",
	"SSD": "SSD",
	"Fonte": "PSU",
	"Cooler": "CLR",
	"Placa Mae": "MB",
	"Cabo HDMI": "HDM",
}

const SLOT_SIZE = 56

func _ready():
	result_panel.visible = false
	powerup_label.visible = false
	restart_button.pressed.connect(_on_restart_pressed)

func update_recursos(moedas: int, reputacao: int, pecas_pc: Array):
	moedas_label.text = "Moedas: %d" % moedas
	pecas_label.text = "Pecas: %d" % pecas_pc.size()

	if reputacao >= 0:
		reputacao_label.text = "Rep: +%d" % reputacao
		reputacao_label.modulate = Color(0.2, 1.0, 0.4)
	else:
		reputacao_label.text = "Rep: %d" % reputacao
		reputacao_label.modulate = Color(1.0, 0.3, 0.3)

func update_timer(time_remaining: float):
	var seconds = int(ceil(time_remaining))
	timer_label.text = "Tempo: %ds" % seconds

	if time_remaining <= 10.0:
		timer_label.modulate = Color(1.0, 0.2, 0.2)
	else:
		timer_label.modulate = Color(1.0, 1.0, 1.0)

func show_powerup(type: String, duration: float):
	active_powerup_name = type
	powerup_timer_display = duration
	powerup_label.visible = true
	_update_powerup_text()

func _process(delta):
	if powerup_label.visible and active_powerup_name != "":
		powerup_timer_display -= delta
		if powerup_timer_display <= 0:
			powerup_label.visible = false
			active_powerup_name = ""
		else:
			_update_powerup_text()

func _update_powerup_text():
	var icon = ""
	match active_powerup_name:
		"speed_boost": icon = "Velocidade"
		"slow": icon = "Lento"
	powerup_label.text = "%s: %.1fs" % [icon, powerup_timer_display]

func show_result(moedas: int, reputacao: int, pecas_pc: Array, died: bool):
	result_panel.visible = true
	restart_button.text = "Continuar"

	if died:
		result_title.text = "Voce bateu! Resultado:"
	else:
		result_title.text = "Tempo esgotado! Resultado:"

	result_moedas.text = "Moedas: %d" % moedas

	if reputacao >= 0:
		result_reputacao.text = "Reputacao: +%d" % reputacao
		result_reputacao.modulate = Color(0.2, 1.0, 0.4)
	else:
		result_reputacao.text = "Reputacao: %d" % reputacao
		result_reputacao.modulate = Color(1.0, 0.3, 0.3)

	_build_inventory(pecas_pc)

func _build_inventory(pecas_pc: Array):
	for child in inventory_grid.get_children():
		child.queue_free()

	if pecas_pc.size() == 0:
		var empty_label = Label.new()
		empty_label.text = "Nenhuma peca coletada"
		empty_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		inventory_grid.add_child(empty_label)
		return

	var contagem = {}
	for peca in pecas_pc:
		if contagem.has(peca):
			contagem[peca] += 1
		else:
			contagem[peca] = 1

	for peca in contagem.keys():
		var quantidade = contagem[peca]
		var cor = PECA_CORES.get(peca, Color(0.4, 0.4, 0.4))
		var sigla = PECA_SIGLAS.get(peca, "??")

		var slot = ColorRect.new()
		slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot.color = cor
		slot.tooltip_text = peca

		var sigla_label = Label.new()
		sigla_label.text = sigla
		sigla_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sigla_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		sigla_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		sigla_label.add_theme_font_size_override("font_size", 12)
		sigla_label.add_theme_color_override("font_color", Color.WHITE)
		slot.add_child(sigla_label)

		var badge = ColorRect.new()
		badge.color = Color(0.05, 0.05, 0.05, 0.85)
		badge.size = Vector2(20, 20)
		badge.position = Vector2(SLOT_SIZE - 20, 0)
		slot.add_child(badge)

		var badge_label = Label.new()
		badge_label.text = "x%d" % quantidade
		badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_label.size = Vector2(20, 20)
		badge_label.position = Vector2(SLOT_SIZE - 20, 0)
		badge_label.add_theme_font_size_override("font_size", 10)
		badge_label.add_theme_color_override("font_color", Color.WHITE)
		slot.add_child(badge_label)

		inventory_grid.add_child(slot)

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://Corredor/scenes/mundo1.tscn")
