extends Node2D

const LABGRAD_RUNNER_SCENE := "res://ER/scenes/main_scene.tscn"
const LABGRAD_DIALOGUE := "res://ER/dialogues/labgrad.dialogue"

@onready var hint_label: Label = $NPC/HintLabel
@onready var player: CharacterBody2D = $Player
@onready var npc: Node2D = $NPC
@onready var dialog_box: Control = get_node_or_null("CanvasLayer/DialogBox")

var player_nearby := false
var dialogue_open := false
var dialogue_resource: Resource

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

func _unhandled_input(event: InputEvent) -> void:
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

	var dialogue_manager = Engine.get_singleton("DialogueManager") if Engine.has_singleton("DialogueManager") else null
	if dialogue_manager == null:
		push_error("DialogueManager não está ativo. Ative o addon Dialogue Manager em Project > Project Settings > Plugins.")
		dialogue_open = false
		return

	if not dialogue_manager.dialogue_ended.is_connected(_on_dialogue_ended):
		dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)

	dialogue_manager.show_dialogue_balloon(dialogue_resource, titulo, [GlobalData])

func _on_dialogue_ended(_resource: Resource) -> void:
	dialogue_open = false

	var dialogue_manager = Engine.get_singleton("DialogueManager") if Engine.has_singleton("DialogueManager") else null
	if dialogue_manager != null and dialogue_manager.dialogue_ended.is_connected(_on_dialogue_ended):
		dialogue_manager.dialogue_ended.disconnect(_on_dialogue_ended)

	if GlobalData.iniciar_labgrad_direto:
		# O runner deve abrir no menu inicial. Por isso limpamos a flag antes de trocar de cena.
		GlobalData.iniciar_labgrad_direto = false
		get_tree().change_scene_to_file(LABGRAD_RUNNER_SCENE)
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
