extends Area2D

@export var platform: Platform

@onready var anim := $AnimationPlayer
@onready var sprite_2d = $Sprite2D

func _ready():
	body_entered.connect(func(_a): _update_state())
	body_exited.connect(func(_a): _update_state())

func _update_state():
	platform.running = has_overlapping_bodies()
	sprite_2d.frame = 0 if not platform.running else 1
