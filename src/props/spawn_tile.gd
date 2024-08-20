extends SceneTile

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.hide()
