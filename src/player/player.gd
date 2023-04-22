class_name Player
extends CharacterBody2D

@export var input: PlayerInput
@export var anim: AnimationPlayer
@export var sprite: Sprite2D

@export var accel = 1000
@export var speed = 200

func _physics_process(delta):
	var motion = input.get_action_strength("move_left") - input.get_action_strength("move_right")
	
	velocity.x = move_toward(velocity.x, motion * speed, accel * delta)
	
	if motion != 0:
		if motion < 0:
			sprite.scale.x = -1
		else:
			sprite.scale.x = 1
	
	if abs(velocity.x) > 0:
		anim.play("run")
	else:
		anim.play("idle")
	
	move_and_slide()
