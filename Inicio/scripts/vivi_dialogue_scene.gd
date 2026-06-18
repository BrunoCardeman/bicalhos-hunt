extends Control

@export_file("*.dialogue") var dialogue_file: String = "res://dialogues/intro.dialogue"
@export var scene_title: String = "INTRODUÇÃO"
@export var end_message: String = "Pressione ENTER para começar."
@export_file("*.tscn") var next_scene_path: String = ""
@export var typing_speed: float = 0.018

@onready var background: TextureRect = $Background
@onready var vivi: TextureRect = $Vivi
@onready var name_label: Label = $DialogueBox/Margin/VBox/NameLabel
@onready var dialogue_label: Label = $DialogueBox/Margin/VBox/DialogueLabel
@onready var hint_label: Label = $DialogueBox/Margin/VBox/HintLabel
@onready var next_button: Button = $DialogueBox/Margin/VBox/NextButton

# Nós opcionais
@onready var intro_video: VideoStreamPlayer = get_node_or_null("IntroVideo") as VideoStreamPlayer
@onready var music_player: AudioStreamPlayer = get_node_or_null("MusicPlayer") as AudioStreamPlayer
@onready var warm_overlay: CanvasItem = get_node_or_null("WarmOverlay") as CanvasItem
@onready var top_bar: CanvasItem = get_node_or_null("TopBar") as CanvasItem
@onready var logo: CanvasItem = get_node_or_null("TextureRect") as CanvasItem
@onready var dialogue_box: Control = $DialogueBox

var dialogue_lines: Array[String] = []
var line_index: int = -1
var current_text: String = ""
var type_accumulator: float = 0.0
var finished: bool = false
var video_running: bool = false
var dialogue_started: bool = false


func _ready() -> void:
	get_tree().root.size_changed.connect(_fit_character)

	name_label.text = "VIVI"
	dialogue_lines = _load_dialogue_lines(dialogue_file)

	if next_button != null:
		next_button.pressed.connect(_advance)

	if music_player != null:
		music_player.volume_db = -10
		music_player.play()

	_fit_character()

	if intro_video != null and intro_video.stream != null:
		_start_intro_video()
	else:
		_start_dialogue()


func _process(delta: float) -> void:
	if not dialogue_started:
		return

	if current_text == "" or dialogue_label.visible_characters >= current_text.length():
		return

	type_accumulator += delta

	while type_accumulator >= typing_speed and dialogue_label.visible_characters < current_text.length():
		type_accumulator -= typing_speed
		dialogue_label.visible_characters += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		if video_running:
			_skip_intro_video()
			return

		if dialogue_started:
			_advance()


func _start_intro_video() -> void:
	video_running = true
	dialogue_started = false

	_set_dialogue_scene_visible(false)

	intro_video.visible = true
	intro_video.expand = true
	intro_video.finished.connect(_on_intro_video_finished)
	intro_video.play()


func _skip_intro_video() -> void:
	if intro_video != null:
		intro_video.stop()

	_on_intro_video_finished()


func _on_intro_video_finished() -> void:
	if not video_running:
		return

	video_running = false

	if intro_video != null:
		intro_video.visible = false

	_start_dialogue()


func _start_dialogue() -> void:
	dialogue_started = true
	finished = false
	line_index = -1
	current_text = ""

	_set_dialogue_scene_visible(true)
	_fit_character()
	_advance()


func _set_dialogue_scene_visible(value: bool) -> void:
	background.visible = value
	vivi.visible = value
	dialogue_box.visible = value

	if warm_overlay != null:
		warm_overlay.visible = value

	if top_bar != null:
		top_bar.visible = value

	if logo != null:
		logo.visible = value


func _advance() -> void:
	if finished:
		_go_next()
		return

	if current_text != "" and dialogue_label.visible_characters < current_text.length():
		dialogue_label.visible_characters = current_text.length()
		return

	line_index += 1

	if line_index >= dialogue_lines.size():
		finished = true
		current_text = end_message
		dialogue_label.text = current_text
		dialogue_label.visible_characters = current_text.length()
		hint_label.text = "ENTER / ESPAÇO"
		next_button.text = "Continuar"
		return

	current_text = dialogue_lines[line_index]
	dialogue_label.text = current_text
	dialogue_label.visible_characters = 0
	type_accumulator = 0.0
	hint_label.text = "ENTER / ESPAÇO para avançar"
	next_button.text = "Avançar"


func _load_dialogue_lines(path: String) -> Array[String]:
	var result: Array[String] = []

	if not FileAccess.file_exists(path):
		push_warning("Arquivo de diálogo não encontrado: " + path)
		return result

	var file := FileAccess.open(path, FileAccess.READ)

	while not file.eof_reached():
		var raw_line := file.get_line().strip_edges()

		# Corrige caracteres invisíveis e bug de UTF-8 BOM
		raw_line = raw_line.replace("\uFEFF", "")
		raw_line = raw_line.replace("ï»¿", "")

		if raw_line.begins_with("VIVI:"):
			var fala := raw_line.replace("VIVI:", "").strip_edges()
			fala = fala.replace("\uFEFF", "")
			fala = fala.replace("ï»¿", "")
			result.append(fala)

	return result


func _fit_character() -> void:
	if vivi == null:
		return

	var viewport_size := get_viewport_rect().size
	var target_width := viewport_size.x * 0.38
	var target_height := viewport_size.y * 0.82

	vivi.custom_minimum_size = Vector2(target_width, target_height)


func _go_next() -> void:
	if music_player != null:
		music_player.stop()

	if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		pass
