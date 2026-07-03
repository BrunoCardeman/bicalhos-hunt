extends Node2D

const LABGRAD_RUNNER_SCENE := "res://Labgrad/scenes/main_scene.tscn"
const LABGRAD_DIALOGUE := "res://Labgrad/dialogues/labgrad.dialogue"
const MAPA_SCENE := "res://map/scenes/mapa.tscn"

@onready var hint_label: Label = $NPC/HintLabel
@onready var player: CharacterBody2D = $Player
@onready var npc: Node2D = $NPC
@onready var dialog_box: Control = get_node_or_null("CanvasLayer/DialogBox")

var player_nearby := false
var dialogue_open := false
var dialogue_resource: Resource

var dialogo_atual := ""
var balao_atual: Node = null


func _ready() -> void:
	if hint_label != null:
		hint_label.visible = false

	# Esconde a caixa antiga. Agora quem mostra o texto é o Dialogue Manager.
	if dialog_box != null:
		dialog_box.visible = false

	dialogue_resource = load(LABGRAD_DIALOGUE)

	# Quando o jogador volta do Endless Runner, ele já aparece perto da Vivi
	# e o diálogo de saída abre automaticamente.
	if GlobalData.voltou_do_labgrad:
		player.position.x = npc.position.x - 70.0
		player.position.y = npc.position.y
		player_nearby = true
		call_deferred("abrir_dialogo_saida")


func _input(event: InputEvent) -> void:
	# ESC funciona SEMPRE: com diálogo aberto ou fechado.
	if event.is_action_pressed("ui_cancel"):
		fechar_balao_atual()
		get_tree().call_deferred("change_scene_to_file", MAPA_SCENE)
		marcar_input_como_usado()
		return

	# TAB pula a história e vai direto para as decisões.
	if dialogue_open and event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_TAB:
			pular_para_decisoes()
			marcar_input_como_usado()
			return

	if dialogue_open:
		return

	if not player_nearby:
		return

	if event.is_action_pressed("ui_accept"):
		abrir_dialogo_entrada()
		marcar_input_como_usado()


func marcar_input_como_usado() -> void:
	var viewport_atual := get_viewport()
	if viewport_atual != null:
		viewport_atual.set_input_as_handled()


func abrir_dialogo_entrada() -> void:
	if GlobalData.voltou_do_labgrad:
		abrir_dialogo_saida()
		return

	if GlobalData.falou_com_vivi_labgrad:
		abrir_dialogo("perguntar_de_novo")
	else:
		abrir_dialogo("entrada_labgrad")


func abrir_dialogo_saida() -> void:
	GlobalData.voltou_do_labgrad = false
	abrir_dialogo("saida_labgrad")


func abrir_dialogo(titulo: String) -> void:
	if dialogue_open:
		return

	if dialogue_resource == null:
		push_error("Arquivo de diálogo não encontrado: " + LABGRAD_DIALOGUE)
		return

	if hint_label != null:
		hint_label.visible = false

	dialogue_open = true
	dialogo_atual = titulo

	var dialogue_manager = Engine.get_singleton("DialogueManager") if Engine.has_singleton("DialogueManager") else null
	if dialogue_manager == null:
		push_error("DialogueManager não está ativo. Ative o addon Dialogue Manager em Project > Project Settings > Plugins.")
		dialogue_open = false
		dialogo_atual = ""
		return

	if not dialogue_manager.dialogue_ended.is_connected(_on_dialogue_ended):
		dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)

	balao_atual = dialogue_manager.show_dialogue_balloon(dialogue_resource, titulo, [GlobalData])


func pular_para_decisoes() -> void:
	if not dialogue_open:
		return

	var titulo_decisoes := ""

	if dialogo_atual == "entrada_labgrad":
		titulo_decisoes = "entrada_labgrad_decisoes"
	elif dialogo_atual == "objetivo_labgrad":
		titulo_decisoes = "objetivo_labgrad_decisoes"
	elif dialogo_atual == "saida_labgrad":
		titulo_decisoes = "saida_labgrad_decisoes"
	else:
		return

	fechar_balao_atual()

	dialogue_open = false
	dialogo_atual = ""

	call_deferred("abrir_dialogo", titulo_decisoes)


func fechar_balao_atual() -> void:
	if balao_atual != null and is_instance_valid(balao_atual):
		balao_atual.queue_free()

	balao_atual = null


func _on_dialogue_ended(_resource: Resource) -> void:
	dialogue_open = false
	dialogo_atual = ""
	balao_atual = null

	var dialogue_manager = Engine.get_singleton("DialogueManager") if Engine.has_singleton("DialogueManager") else null
	if dialogue_manager != null and dialogue_manager.dialogue_ended.is_connected(_on_dialogue_ended):
		dialogue_manager.dialogue_ended.disconnect(_on_dialogue_ended)

	if GlobalData.iniciar_labgrad_direto:
		# O runner deve abrir no menu inicial. Por isso limpamos a flag antes de trocar de cena.
		GlobalData.iniciar_labgrad_direto = false
		get_tree().call_deferred("change_scene_to_file", LABGRAD_RUNNER_SCENE)
		return

	if player_nearby and hint_label != null:
		hint_label.visible = true


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

		if not dialogue_open and hint_label != null:
			hint_label.visible = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false

		if hint_label != null:
			hint_label.visible = false
