class_name Gate
extends StaticBody2D

@export var anim: AnimationPlayer

func _ready():
	anim.play("RESET")

func open():
	anim.play("open")
