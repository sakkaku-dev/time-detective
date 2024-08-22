extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready() -> void:
	canvas_layer.hide()
	GameManager.current_level = name.to_int()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		canvas_layer.visible = not canvas_layer.visible
		GameManager.toggle_paused(canvas_layer.visible)
