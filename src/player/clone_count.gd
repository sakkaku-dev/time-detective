extends Label

func _ready() -> void:
	GameManager.paused.connect(func(pause): visible = pause)
