class_name Pushable
extends CharacterBody2D

@export var friction := 800

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	velocity += Vector2.DOWN * gravity * delta
	move_and_slide()

func apply_force(force: float):
	velocity.x = force
