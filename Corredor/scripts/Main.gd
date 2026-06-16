extends Node

@onready var snake = $Snake
@onready var fruit_spawner = $FruitSpawner
@onready var hud = $HUD

func _ready():
	# 1. Esconde a tela de Game Over/Resultados assim que o jogo abre
	$HUD/ResultPanel.hide()
	
	fruit_spawner.setup(snake)

	snake.recursos_changed.connect(_on_recursos_changed)
	snake.timer_changed.connect(_on_timer_changed)
	snake.phase_ended.connect(_on_phase_ended)
	snake.snake_died.connect(_on_snake_died)
	snake.powerup_activated.connect(_on_powerup_activated)

	hud.update_recursos(0, 0, [])
	hud.update_timer(snake.PHASE_TIME)
	
	# OBS: Se a sua cobra já anda sozinha usando _process ou _physics_process
	# esconder o painel acima já é suficiente para o jogo rodar normal.
	# Se ela estiver parada, você pode precisar chamar uma função de start dela aqui.

func _on_recursos_changed(moedas: int, reputacao: int, pecas_pc: Array):
	hud.update_recursos(moedas, reputacao, pecas_pc)

func _on_timer_changed(time_remaining: float):
	hud.update_timer(time_remaining)

func _on_phase_ended(moedas: int, reputacao: int, pecas_pc: Array):
	hud.show_result(moedas, reputacao, pecas_pc, false)

func _on_snake_died(moedas: int, reputacao: int, pecas_pc: Array):
	hud.show_result(moedas, reputacao, pecas_pc, true)

func _on_powerup_activated(type: String, duration: float):
	hud.show_powerup(type, duration)
