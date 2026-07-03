extends Area2D

# Permite mudar o texto de cada ponto direto no Inspector do mapa
@export var caminho: String
# Pega a referência do balão e do texto que criamos
@onready var balao: PanelContainer = $Balao
@onready var label_texto: Label = $Balao/Label

func _ready() -> void:
	# Configura o texto do balão com o texto que você escolheu
	if !GlobalData.jogou_minigame_labgrad:
		modulate = Color(0.3, 0.3, 0.3, 1)
	
	# Garante que o balão comece escondido
	balao.hide()
	
	# Conecta os sinais de "mouse entrou" e "mouse saiu"
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	self.input_event.connect(_on_input_event)


# Quando o mouse PASSA POR CIMA da Area2D
func _on_mouse_entered() -> void:
	balao.show() # Mostra o balão


# Quando o mouse SAI de cima da Area2D
func _on_mouse_exited() -> void:
	balao.hide() # Esconde o balão
	
	# Nova função para detectar o clique dentro da área
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if caminho == "":
			print("Este ponto do mapa ainda não tem caminho configurado: ", name)
			return
	if GlobalData.jogou_minigame_labgrad:
		get_tree().call_deferred("change_scene_to_file", caminho)
