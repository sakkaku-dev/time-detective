extends Node2D

func _ready() -> void:
	GameManager.current_level = name.to_int()
