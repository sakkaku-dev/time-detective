class_name Player
extends CharacterBody2D

@export var input: PlayerInput
@export var anim: AnimationPlayer
@export var sprite: Sprite2D

@export var accel = 1000
@export var speed = 200
@export var jump_force = 300

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var motion = input.get_action_strength("move_left") - input.get_action_strength("move_right")
	
	velocity.x = move_toward(velocity.x, motion * speed, accel * delta)
	velocity += Vector2.DOWN * gravity * delta
	
	if motion != 0:
		sprite.scale.x = sign(motion)
	
	anim.play("idle" if velocity.x == 0 else "run")
	
	
	move_and_slide()


func _on_player_input_just_pressed(ev: InputEvent):
	if ev.is_action_pressed("jump") and is_on_floor():
		velocity += Vector2.UP * jump_force
