extends Area2D

func _on_body_entered(body: Player):
	GameManager.next_level()
	