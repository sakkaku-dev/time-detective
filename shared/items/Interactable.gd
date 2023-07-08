class_name Interactable
extends Area2D

signal interacted

const OUTLINE = preload("res://shared/items/sprite_outline.tres")

@export var sprite: Sprite2D
@export var sprite2: Sprite2D

func _ready():
	unhighlight()

func highlight():
	if sprite:
		set_highlight(sprite, true)
	if sprite2:
		set_highlight(sprite2, true)


func unhighlight():
	if sprite:
		set_highlight(sprite, false)
	if sprite2:
		set_highlight(sprite2, false)


func set_highlight(sp: Sprite2D, enable: bool):
	var mat = sp.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("enable", enable)

func interact():
	interacted.emit()
