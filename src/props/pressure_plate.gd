extends Area2D

@export var platform: Platform

@onready var anim := $AnimationPlayer

func _process(delta):
	var is_now_pressed = has_overlapping_bodies()
	
	if not platform.running and is_now_pressed:
		anim.play("pressed")
		
	if platform.running and not is_now_pressed:
		anim.play("unpressed")
	
	platform.running = is_now_pressed


func _on_body_entered(body):
	pass # Replace with function body.


func _on_body_exited(body):
	pass # Replace with function body.
