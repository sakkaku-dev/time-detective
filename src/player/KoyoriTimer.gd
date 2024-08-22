class_name KoyoriTimer
extends Timer

@export var player: CharacterBody2D

var had_contact := false

func _physics_process(delta):
	if had_contact and not _is_on_contact() and is_stopped():
		start()
	
	had_contact = _is_on_contact()

func _is_on_contact():
	return player.is_on_floor()

func can_jump():
	return _is_on_contact() or not is_stopped()
