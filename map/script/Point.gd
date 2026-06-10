extends Area2D

# Permite mudar o texto de cada ponto direto no Inspector do mapa
@export var caminho: String
# Pega a referência do balão e do texto que criamos
@onready var balao: PanelContainer = $Balao
@onready var label_texto: Label = $Balao/Label

func _ready() -> void:
	# Configura o texto do balão com o texto que você escolheu

	
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
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Verifica se o evento foi um clique do botão esquerdo do mouse
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# OPÇÃO A: Posição global (em relação ao mapa/mundo do jogo)
		var posicao_global = event.global_position
		
		# OPÇÃO B: Posição local (em relação ao centro da sua Area2D)
		var posicao_local = event.position
		
		# Printa as informações no console do Godot
		get_tree().change_scene_to_file(caminho)
