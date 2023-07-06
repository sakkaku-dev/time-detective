extends Area2D

func _on_body_entered(body: Player):
	if body.is_main_player():
		GameManager.next_level()
	
