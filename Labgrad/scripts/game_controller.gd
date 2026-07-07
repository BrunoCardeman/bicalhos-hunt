extends Node2D

const VELOCIDADE_INICIAL := 360.0
const ACELERACAO_POR_SEGUNDO := 18.0
const DISTANCIA_SPAWN_BASE := 950.0
const LIMPEZA_ATRAS_CAMERA := 950.0

const CHAO_Y_OBSTACULO := 508.0
const Y_PASSARO := 448.0
const Y_ITEM_BAIXO := 442.0
const Y_ITEM_ALTO := 372.0
const RPG_LABGRAD_SCENE := "res://Labgrad/scenes/rpg_labgrad.tscn"

@onready var player: CharacterBody2D = $Dinossaur
@onready var camera: Camera2D = $Camera2D

@onready var label_pontos: Label = $CanvasLayer/HUD/PainelSuperior/MargemSuperior/InfoLinha/PontosLabel
@onready var label_itens: Label = $CanvasLayer/HUD/PainelSuperior/MargemSuperior/InfoLinha/MoedasLabel
@onready var label_azul: Label = $CanvasLayer/HUD/PainelSuperior/MargemSuperior/InfoLinha/AzulLabel
@onready var label_amarelo: Label = $CanvasLayer/HUD/PainelSuperior/MargemSuperior/InfoLinha/AmareloLabel
@onready var label_vermelho: Label = $CanvasLayer/HUD/PainelSuperior/MargemSuperior/InfoLinha/VermelhoLabel
@onready var label_velocidade: Label = $CanvasLayer/HUD/PainelSuperior/MargemSuperior/InfoLinha/VelocidadeLabel

@onready var menu_inicial: Control = $CanvasLayer/MenuInicial
@onready var painel_pausa: Control = $CanvasLayer/Pausa
@onready var painel_game_over: Control = $CanvasLayer/GameOver

@onready var painel_game_over_box: Control = $CanvasLayer/GameOver/PainelGameOver
@onready var margem_game_over: Control = $CanvasLayer/GameOver/PainelGameOver/MargemGameOver
@onready var conteudo_game_over: Control = $CanvasLayer/GameOver/PainelGameOver/MargemGameOver/ConteudoGameOver
@onready var label_reiniciar: Label = $CanvasLayer/GameOver/PainelGameOver/MargemGameOver/ConteudoGameOver/ReiniciarLabel
@onready var label_pontuacao_final: Label = $CanvasLayer/GameOver/PainelGameOver/MargemGameOver/ConteudoGameOver/PontuacaoFinalLabel
@onready var label_itens_finais: Label = $CanvasLayer/GameOver/PainelGameOver/MargemGameOver/ConteudoGameOver/MoedasFinaisLabel

var cena_toco := preload("res://Labgrad/scenes/stump_obstacle.tscn")
var cena_pedra := preload("res://Labgrad/scenes/rock_obstacle.tscn")
var cena_barril := preload("res://Labgrad/scenes/barrel_obstacle.tscn")
var cena_passaro := preload("res://Labgrad/scenes/bird_enemy.tscn")
var cena_item := preload("res://Labgrad/scenes/computer_collectible.tscn")

var obstaculos_terrestres: Array[PackedScene] = []

var estado_jogo := "menu"
var tempo_jogo := 0.0
var pontuacao := 0
var pecas_azuis := 0
var pecas_amarelas := 0
var pecas_vermelhas := 0
var timer_spawn := 0.0
var proximo_intervalo_spawn := 1.4
var velocidade_atual := VELOCIDADE_INICIAL
var resultado_salvo := false


func _ready() -> void:
	randomize()
	configurar_inputs()

	obstaculos_terrestres = [cena_toco, cena_pedra, cena_barril]

	camera.enabled = true
	camera.position = Vector2(320, 324)

	player.resetar()
	atualizar_hud()

	menu_inicial.visible = true
	painel_pausa.visible = false
	painel_game_over.visible = false

	configurar_visual_game_over()

	GlobalData.iniciar_labgrad_direto = false


func configurar_visual_game_over() -> void:
	var largura_painel := 800.0
	var altura_painel := 180.0
	var tamanho_tela := get_viewport_rect().size

	# Ajuste visual para a esquerda.
	# Se ainda ficar para a direita, aumente para -200.
	# Se ficar muito para a esquerda, diminua para -120.
	var ajuste_x := -120.0

	painel_game_over.set_anchors_preset(Control.PRESET_FULL_RECT)
	painel_game_over.offset_left = 0.0
	painel_game_over.offset_top = 0.0
	painel_game_over.offset_right = 0.0
	painel_game_over.offset_bottom = 0.0

	painel_game_over_box.set_anchors_preset(Control.PRESET_TOP_LEFT)
	painel_game_over_box.custom_minimum_size = Vector2(largura_painel, altura_painel)
	painel_game_over_box.size = Vector2(largura_painel, altura_painel)
	painel_game_over_box.position = Vector2(
		((tamanho_tela.x - largura_painel) / 2.0) + ajuste_x,
		(tamanho_tela.y - altura_painel) / 2.0
	)

	margem_game_over.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margem_game_over.position = Vector2.ZERO
	margem_game_over.custom_minimum_size = Vector2(largura_painel, altura_painel)
	margem_game_over.size = Vector2(largura_painel, altura_painel)

	conteudo_game_over.set_anchors_preset(Control.PRESET_TOP_LEFT)
	conteudo_game_over.position = Vector2(20.0, 20.0)
	conteudo_game_over.custom_minimum_size = Vector2(760.0, 140.0)
	conteudo_game_over.size = Vector2(760.0, 140.0)

	if conteudo_game_over is VBoxContainer:
		conteudo_game_over.add_theme_constant_override("separation", 0)

	label_reiniciar.text = "ENTER - Jogar novamente | ESC - Voltar ao RPG"
	label_reiniciar.custom_minimum_size = Vector2(740.0, 26.0)
	label_reiniciar.size = Vector2(740.0, 26.0)
	label_reiniciar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_reiniciar.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_reiniciar.autowrap_mode = TextServer.AUTOWRAP_OFF

	label_pontuacao_final.custom_minimum_size = Vector2(740.0, 24.0)
	label_pontuacao_final.size = Vector2(740.0, 24.0)
	label_pontuacao_final.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_pontuacao_final.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	label_itens_finais.custom_minimum_size = Vector2(740.0, 28.0)
	label_itens_finais.size = Vector2(740.0, 28.0)
	label_itens_finais.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_itens_finais.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_itens_finais.autowrap_mode = TextServer.AUTOWRAP_OFF


func _process(delta: float) -> void:
	if estado_jogo != "jogando":
		return
	
	tempo_jogo += delta
	velocidade_atual = VELOCIDADE_INICIAL + tempo_jogo * ACELERACAO_POR_SEGUNDO
	pontuacao += int(round(delta * 12.0))

	camera.position.x = player.position.x + 280.0

	timer_spawn += delta

	if timer_spawn >= proximo_intervalo_spawn:
		timer_spawn = 0.0
		spawnar_elemento()
		definir_proximo_intervalo()
		
	update_rep()
	limpar_elementos_antigos()
	atualizar_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reiniciar"):
		reiniciar_jogo()
		marcar_input_como_usado()
		return

	if event.is_action_pressed("iniciar"):
		if estado_jogo == "menu":
			iniciar_jogo()
		elif estado_jogo == "game_over":
			iniciar_jogo()

		marcar_input_como_usado()
		return

	if event.is_action_pressed("voltar_rpg") and estado_jogo == "game_over":
		voltar_para_rpg()
		marcar_input_como_usado()
		return

	if event.is_action_pressed("pausar") and estado_jogo != "menu" and estado_jogo != "game_over":
		alternar_pausa()
		marcar_input_como_usado()


func marcar_input_como_usado() -> void:
	var viewport_atual := get_viewport()

	if viewport_atual != null:
		viewport_atual.set_input_as_handled()


func configurar_inputs() -> void:
	registrar_acao("pular", [KEY_SPACE, KEY_W, KEY_UP])
	registrar_acao("agachar", [KEY_S, KEY_DOWN])
	registrar_acao("pausar", [KEY_P])
	registrar_acao("reiniciar", [KEY_R])
	registrar_acao("iniciar", [KEY_ENTER, KEY_KP_ENTER])
	registrar_acao("voltar_rpg", [KEY_ESCAPE])


func registrar_acao(nome: String, teclas: Array[int]) -> void:
	if not InputMap.has_action(nome):
		InputMap.add_action(nome)

	for evento_existente in InputMap.action_get_events(nome):
		InputMap.action_erase_event(nome, evento_existente)

	for tecla in teclas:
		var evento := InputEventKey.new()
		evento.physical_keycode = tecla as Key
		evento.keycode = tecla as Key
		InputMap.action_add_event(nome, evento)


func iniciar_jogo() -> void:
	estado_jogo = "jogando"

	menu_inicial.visible = false
	painel_pausa.visible = false
	painel_game_over.visible = false

	player.resetar()

	tempo_jogo = 0.0
	pontuacao = 0
	pecas_azuis = 0
	pecas_amarelas = 0
	pecas_vermelhas = 0
	timer_spawn = 0.0
	proximo_intervalo_spawn = 1.2
	velocidade_atual = VELOCIDADE_INICIAL
	resultado_salvo = false

	camera.position = Vector2(320, 324)

	limpar_todos_os_objetos_dinamicos()
	atualizar_hud()


func alternar_pausa() -> void:
	if estado_jogo == "jogando":
		estado_jogo = "pausado"
		painel_pausa.visible = true
	elif estado_jogo == "pausado":
		estado_jogo = "jogando"
		painel_pausa.visible = false


func encerrar_partida() -> void:
	if estado_jogo != "jogando":
		return

	estado_jogo = "game_over"
	salvar_resultado_labgrad()

	painel_pausa.visible = false
	painel_game_over.visible = true

	configurar_visual_game_over()

	label_reiniciar.text = "ENTER - Jogar novamente | ESC - Voltar ao RPG"

	label_pontuacao_final.text = "Pontuação final: %d" % pontuacao
	label_itens_finais.text = "Peças coletadas: %d | Azul: %d | Amarelo: %d | Vermelho: %d" % [
		obter_total_pecas(),
		pecas_azuis,
		pecas_amarelas,
		pecas_vermelhas
	]

func update_rep() -> void:
	if pecas_azuis >= 5:
		GlobalData.reputacao += 50
		pecas_azuis = 0
	if pecas_amarelas >= 5:
		GlobalData.reputacao += 70
		pecas_amarelas = 0
	if pecas_vermelhas >= 5:
		GlobalData.reputacao += 100
		pecas_vermelhas = 0
		
		
func salvar_resultado_labgrad() -> void:
	if resultado_salvo:
		return

	resultado_salvo = true

	GlobalData.registrar_pecas_labgrad(pecas_azuis, pecas_amarelas, pecas_vermelhas)
	GlobalData.voltou_do_labgrad = true
	print("Reputação atual: ", GlobalData.reputacao)


func voltar_para_rpg() -> void:
	get_tree().call_deferred("change_scene_to_file", RPG_LABGRAD_SCENE)


func reiniciar_jogo() -> void:
	get_tree().reload_current_scene()


func pode_processar_jogo() -> bool:
	return estado_jogo == "jogando"


func obter_velocidade_atual() -> float:
	return velocidade_atual


func coletar_item(item: Area2D) -> void:
	var cor := "blue"
	var cor_item = item.get("item_color")

	if cor_item != null:
		cor = str(cor_item)

	match cor:
		"blue":
			pecas_azuis += 1
		"yellow":
			pecas_amarelas += 1
		"red":
			pecas_vermelhas += 1

	pontuacao += 25
	atualizar_hud()


func obter_total_pecas() -> int:
	return pecas_azuis + pecas_amarelas + pecas_vermelhas


func atualizar_hud() -> void:
	label_pontos.text = "Pontos: %d" % pontuacao
	label_itens.text = "Peças: %d" % obter_total_pecas()
	label_azul.text = "Azul: %d" % pecas_azuis
	label_amarelo.text = "Amarelo: %d" % pecas_amarelas
	label_vermelho.text = "Vermelho: %d" % pecas_vermelhas
	label_velocidade.text = "Velocidade: %d" % int(round(velocidade_atual))


func definir_proximo_intervalo() -> void:
	var minimo: float = maxf(0.75, 1.30 - tempo_jogo * 0.01)
	var maximo: float = maxf(1.20, 2.10 - tempo_jogo * 0.015)

	proximo_intervalo_spawn = randf_range(minimo, maximo)


func spawnar_elemento() -> void:
	var x_spawn := camera.position.x + DISTANCIA_SPAWN_BASE + randf_range(0.0, 220.0)

	if randf() < 0.72:
		spawnar_obstaculo_terrestre(x_spawn)
	else:
		spawnar_passaro(x_spawn)

	if randf() < 0.58:
		spawnar_item(x_spawn + randf_range(70.0, 150.0))


func spawnar_obstaculo_terrestre(x_spawn: float) -> void:
	if obstaculos_terrestres.is_empty():
		return

	var indice := randi_range(0, obstaculos_terrestres.size() - 1)
	var obstaculo: Area2D = obstaculos_terrestres[indice].instantiate()

	obstaculo.position = Vector2(x_spawn, CHAO_Y_OBSTACULO)

	add_child(obstaculo)


func spawnar_passaro(x_spawn: float) -> void:
	var passaro: Area2D = cena_passaro.instantiate()

	passaro.position = Vector2(x_spawn, Y_PASSARO)

	add_child(passaro)


func spawnar_item(x_spawn: float) -> void:
	var item: Area2D = cena_item.instantiate()

	var tipos: Array[String] = [
		"motherboard",
		"psu",
		"gpu",
		"cpu",
		"ram"
	]

	var cores: Array[String] = [
		"blue",
		"blue",
		"blue",
		"yellow",
		"yellow",
		"red"
	]

	var tipo: String = tipos[randi_range(0, tipos.size() - 1)]
	var cor: String = cores[randi_range(0, cores.size() - 1)]

	item.position = Vector2(x_spawn, Y_ITEM_ALTO if randf() < 0.5 else Y_ITEM_BAIXO)

	add_child(item)

	if item.has_method("configurar"):
		item.configurar(tipo, cor)


func limpar_elementos_antigos() -> void:
	var limite := camera.position.x - LIMPEZA_ATRAS_CAMERA

	for node in get_tree().get_nodes_in_group("elemento_dinamico"):
		if node is Node2D and node.global_position.x < limite:
			node.queue_free()


func limpar_todos_os_objetos_dinamicos() -> void:
	for node in get_tree().get_nodes_in_group("elemento_dinamico"):
		node.queue_free()
