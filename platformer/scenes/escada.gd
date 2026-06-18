extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Quando o jogador entra, ativamos o modo escada
	if body.is_in_group("player"):
		body.na_escada = true

func _on_body_exited(body: Node2D) -> void:
	# Quando o jogador sai, devolvemos a gravidade para ele
	if body.is_in_group("player"):
		body.na_escada = false
