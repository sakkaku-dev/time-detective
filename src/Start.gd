extends Control

@export var level_grid: GridContainer

func _ready():
	for lvl in GameManager.level_manager.list_available_levels():
		var btn = Button.new()
		btn.text = "Level %s" % lvl
		btn.custom_minimum_size = Vector2(100, 100)
		btn.pressed.connect(func(): GameManager.load_level(lvl))
		level_grid.add_child(btn)
