extends SceneTile

@export var platform: Platform

@onready var anim := $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var pressure_plate: Area2D = $PressurePlate

func _ready():
	pressure_plate.body_entered.connect(func(_a): _update_state())
	pressure_plate.body_exited.connect(func(_a): _update_state())

func _update_state():
	platform.running = pressure_plate.has_overlapping_bodies()
	sprite_2d.frame = 0 if not platform.running else 1
