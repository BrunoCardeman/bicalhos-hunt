extends Node

# ==========================================
# VARIÁVEIS DE BICALHO'S HUNT
# ==========================================

# --- Sistemas de Sobrevivência ---
var fome: float = 0.0  # Vai de 0 a 100
var sono: float = 0.0  # Vai de 0 a 100

# --- Sistema de Reputação ---
var reputacao: int = 0 # Começa em 0, vai de -10 a +10
var nota:int = 10
# --- Recursos e Inventário ---
var moedas: int = 0
var inventario: Array = []

# Contadores de peças do LabGrad (máximo 5 de cada)
var pc_azul_pecas: int = 0
var pc_amarelo_pecas: int = 0
var pc_vermelho_pecas: int = 0

# --- Progresso do Jogo ---
var jogou_minigame_snake: bool = false
var jogou_minigame_labgrad: bool = false
var jogou_minigame_di: bool = false
var jogou_minigame_540: bool = false

# --- Controle de transição de cenas ---
var ir_para_snake: bool = false       # true só quando o jogador aceitar jogar/rejogar o Snake
var falou_com_vivi_snake: bool = false # true depois que ouviu o diálogo completo da Vivi
var ir_top_down : bool = false

# Controle do fluxo RPG -> Endless Runner -> RPG
var falou_com_vivi_labgrad: bool = false
var voltou_do_labgrad: bool = false
var iniciar_labgrad_direto: bool = false

# ==========================================
# FUNÇÕES GLOBAIS
# ==========================================

func add_item(item: String):
	inventario.append(item)

# Função auxiliar para garantir que a reputação fique sempre entre -10 e +10
func alterar_reputacao(valor: int):
	reputacao += valor
	# clamp() força o valor a ficar dentro do mínimo e máximo permitidos
	reputacao = clamp(reputacao, -10, 10) 

# Função para resetar status ao dormir ou comer
func recuperar_sono(quantidade: float):
	sono -= quantidade
	sono = clamp(sono, 0.0, 100.0)

func recuperar_fome(quantidade: float):
	fome -= quantidade
	fome = clamp(fome, 0.0, 100.0)
	
func tem_computador_montado() -> bool:
	return pc_azul_pecas >= 5 or pc_amarelo_pecas >= 5 or pc_vermelho_pecas >= 5
	
func registrar_pecas_labgrad(azuis: int, amarelas: int, vermelhas: int) -> void:
	var pcs_azuis_antes := floori(pc_azul_pecas / 5.0)
	var pcs_amarelos_antes := floori(pc_amarelo_pecas / 5.0)
	var pcs_vermelhos_antes := floori(pc_vermelho_pecas / 5.0)

	pc_azul_pecas += azuis
	pc_amarelo_pecas += amarelas
	pc_vermelho_pecas += vermelhas

	var pcs_azuis_depois := floori(pc_azul_pecas / 5.0)
	var pcs_amarelos_depois := floori(pc_amarelo_pecas / 5.0)
	var pcs_vermelhos_depois := floori(pc_vermelho_pecas / 5.0)

	var novos_pcs_azuis := pcs_azuis_depois - pcs_azuis_antes
	var novos_pcs_amarelos := pcs_amarelos_depois - pcs_amarelos_antes
	var novos_pcs_vermelhos := pcs_vermelhos_depois - pcs_vermelhos_antes

	var ganho_reputacao := 0
	ganho_reputacao += novos_pcs_azuis * 1
	ganho_reputacao += novos_pcs_amarelos * 2
	ganho_reputacao += novos_pcs_vermelhos * 3

	if ganho_reputacao > 0:
		alterar_reputacao(ganho_reputacao)
