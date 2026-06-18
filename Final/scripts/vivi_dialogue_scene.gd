extends Control

@export_file("*.dialogue") var dialogue_file: String = "res://dialogues/final.dialogue"
@export_file("*.tscn") var next_scene_path: String = ""
@export var scene_title: String = "FINAL"
@export var end_message: String = "Obrigado por jogar."
@export var typing_speed: float = 0.018

@onready var logo: TextureRect = get_node_or_null("Logo") as TextureRect
@onready var background: TextureRect = $Background
@onready var vivi: TextureRect = $Vivi

@onready var dialogue_box: Control = $DialogueBox
@onready var name_label: Label = $DialogueBox/Margin/VBox/NameLabel
@onready var dialogue_label: Label = $DialogueBox/Margin/VBox/DialogueLabel
@onready var hint_label: Label = $DialogueBox/Margin/VBox/BottomRow/HintLabel
@onready var next_button: Button = $DialogueBox/Margin/VBox/BottomRow/NextButton

# Estes dois podem não existir, então ficam opcionais.
@onready var title_label: Label = get_node_or_null("TopBar/TitleLabel") as Label
@onready var top_bar: Control = get_node_or_null("TopBar") as Control

# Vídeo antes do diálogo.
@onready var pre_final_video: VideoStreamPlayer = get_node_or_null("PreFinalVideo") as VideoStreamPlayer

# Vídeo depois do diálogo.
@onready var final_video: VideoStreamPlayer = get_node_or_null("FinalVideo") as VideoStreamPlayer

# Música que toca do primeiro vídeo até o fim.
@onready var music_player: AudioStreamPlayer = get_node_or_null("MusicPlayer") as AudioStreamPlayer

var dialogue_lines: Array[String] = []
var line_index: int = -1
var current_text: String = ""
var type_accumulator: float = 0.0

var pre_video_started: bool = false
var pre_video_finished: bool = false

var dialogue_started: bool = false
var finished_dialogue: bool = false

var final_video_started: bool = false
var final_video_finished: bool = false


func _ready() -> void:
	if get_tree().root.has_signal("size_changed"):
		get_tree().root.size_changed.connect(_fit_layout)

	next_button.pressed.connect(_advance)

	if title_label != null:
		title_label.text = scene_title

	name_label.text = "VIVI"
	dialogue_lines = _load_dialogue_lines(dialogue_file)

	_fit_layout()

	# Música começa desde o vídeo inicial.
	if music_player != null:
		music_player.volume_db = -10
		music_player.play()

	_configure_video(pre_final_video)
	_configure_video(final_video)

	if pre_final_video != null:
		if not pre_final_video.finished.is_connected(_on_pre_final_video_finished):
			pre_final_video.finished.connect(_on_pre_final_video_finished)

	if final_video != null:
		if not final_video.finished.is_connected(_on_final_video_finished):
			final_video.finished.connect(_on_final_video_finished)

	# Fluxo:
	# 1. vídeo de comemoração
	# 2. diálogo da Vivi
	# 3. vídeo final
	if pre_final_video != null and pre_final_video.stream != null:
		_start_pre_final_video()
	else:
		_start_dialogue()


func _process(delta: float) -> void:
	if not dialogue_started:
		return

	if finished_dialogue:
		return

	if final_video_started:
		return

	if current_text == "" or dialogue_label.visible_characters >= current_text.length():
		return

	type_accumulator += delta

	while type_accumulator >= typing_speed and dialogue_label.visible_characters < current_text.length():
		type_accumulator -= typing_speed
		dialogue_label.visible_characters += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		if pre_video_started and not pre_video_finished:
			_skip_pre_final_video()
			return

		if final_video_started and not final_video_finished:
			_skip_final_video()
			return

		if dialogue_started:
			_advance()


func _configure_video(video: VideoStreamPlayer) -> void:
	if video == null:
		return

	video.visible = false
	video.expand = true
	video.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Força tela cheia.
	video.anchor_left = 0.0
	video.anchor_top = 0.0
	video.anchor_right = 1.0
	video.anchor_bottom = 1.0

	video.offset_left = 0
	video.offset_top = 0
	video.offset_right = 0
	video.offset_bottom = 0

	# Força ficar por cima de tudo.
	video.z_index = 9999
	video.z_as_relative = false

	if video.get_parent() != null:
		video.get_parent().move_child(video, video.get_parent().get_child_count() - 1)


func _start_pre_final_video() -> void:
	if pre_final_video == null:
		push_warning("PreFinalVideo não encontrado.")
		_start_dialogue()
		return

	if pre_final_video.stream == null:
		push_warning("PreFinalVideo existe, mas está sem vídeo no campo Stream.")
		_start_dialogue()
		return

	pre_video_started = true
	pre_video_finished = false
	dialogue_started = false

	_hide_dialogue_scene()

	_configure_video(pre_final_video)

	pre_final_video.visible = true
	pre_final_video.show()
	pre_final_video.modulate = Color.WHITE
	pre_final_video.play()


func _skip_pre_final_video() -> void:
	if pre_final_video != null:
		pre_final_video.stop()

	_on_pre_final_video_finished()


func _on_pre_final_video_finished() -> void:
	if pre_video_finished:
		return

	pre_video_started = false
	pre_video_finished = true

	if pre_final_video != null:
		pre_final_video.stop()
		pre_final_video.visible = false
		pre_final_video.hide()

	_start_dialogue()


func _start_dialogue() -> void:
	dialogue_started = true
	finished_dialogue = false

	line_index = -1
	current_text = ""
	type_accumulator = 0.0

	_show_dialogue_scene()
	_fit_layout()
	_advance()


func _advance() -> void:
	if final_video_finished:
		_go_next()
		return

	if finished_dialogue:
		_start_final_video()
		return

	if current_text != "" and dialogue_label.visible_characters < current_text.length():
		dialogue_label.visible_characters = current_text.length()
		return

	line_index += 1

	if line_index >= dialogue_lines.size():
		finished_dialogue = true

		current_text = _clean_text(end_message)
		dialogue_label.text = current_text
		dialogue_label.visible_characters = current_text.length()

		hint_label.text = "ENTER / ESPAÇO"
		next_button.text = "Ver final"
		return

	current_text = _clean_text(dialogue_lines[line_index])
	dialogue_label.text = current_text
	dialogue_label.visible_characters = 0
	type_accumulator = 0.0

	hint_label.text = "ENTER / ESPAÇO para avançar"
	next_button.text = "Avançar"


func _start_final_video() -> void:
	if final_video == null:
		push_warning("FinalVideo não encontrado.")
		_finish_everything()
		return

	if final_video.stream == null:
		push_warning("FinalVideo existe, mas está sem vídeo no campo Stream.")
		_finish_everything()
		return

	final_video_started = true
	final_video_finished = false
	dialogue_started = false

	_hide_dialogue_scene()

	_configure_video(final_video)

	final_video.visible = true
	final_video.show()
	final_video.modulate = Color.WHITE
	final_video.play()


func _skip_final_video() -> void:
	if final_video != null:
		final_video.stop()

	_on_final_video_finished()


func _on_final_video_finished() -> void:
	if final_video_finished:
		return

	final_video_finished = true
	final_video_started = false

	if final_video != null:
		final_video.stop()
		final_video.visible = false
		final_video.hide()

	_finish_everything()


func _finish_everything() -> void:
	if music_player != null:
		music_player.stop()

	_go_next()


func _show_dialogue_scene() -> void:
	background.visible = true
	vivi.visible = true
	dialogue_box.visible = true

	if top_bar != null:
		top_bar.visible = true

	if logo != null:
		logo.visible = true

	if pre_final_video != null:
		pre_final_video.visible = false

	if final_video != null:
		final_video.visible = false


func _hide_dialogue_scene() -> void:
	background.visible = false
	vivi.visible = false
	dialogue_box.visible = false

	if top_bar != null:
		top_bar.visible = false

	if logo != null:
		logo.visible = false


func _load_dialogue_lines(path: String) -> Array[String]:
	var result: Array[String] = []

	if not FileAccess.file_exists(path):
		push_warning("Arquivo de diálogo não encontrado: " + path)
		return ["Fim da jornada, aluno."]

	var file := FileAccess.open(path, FileAccess.READ)

	while not file.eof_reached():
		var raw_line := _clean_text(file.get_line().strip_edges())

		if raw_line == "" or raw_line.begins_with("~") or raw_line.begins_with("=>"):
			continue

		if raw_line.begins_with("VIVI:"):
			var fala := _clean_text(raw_line.replace("VIVI:", "").strip_edges())
			result.append(fala)

	return result


func _clean_text(text: String) -> String:
	return text.replace("\uFEFF", "").replace("ï»¿", "").strip_edges()


func _fit_layout() -> void:
	if vivi == null:
		return

	var viewport_size := get_viewport_rect().size
	vivi.custom_minimum_size = Vector2(viewport_size.x * 0.36, viewport_size.y * 0.82)


func _go_next() -> void:
	if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		pass
		
