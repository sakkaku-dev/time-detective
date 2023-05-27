class_name Player
extends CharacterBody2D

@export var input: PlayerInput
@export var anim: AnimationPlayer
@export var sprite: Sprite2D

@export var accel = 1000
@export var speed = 150
@export var jump_force = 300

@export var hand: Hand

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var pushing = false
var events: Array[CloneEvent] = []

func _ready():
	if not events.is_empty():
		_process_event(events.pop_front())
	
	if is_main_player():
		hand.disable_highlight = false

func _process_event(ev: CloneEvent):
	if ev != null:
		input.handle_input(ev.event)
		get_tree().create_timer(ev.duration).timeout.connect(func(): _process_event(events.pop_front()))

func is_main_player() -> bool:
	return GameManager.main_player == self

func _physics_process(delta):
	var motion = input.get_action_strength("move_left") - input.get_action_strength("move_right")
	var normalized = Vector2(motion, 0).normalized()
	var speed_multiplier = 0.8 if pushing else 1.0
	
	velocity.x = move_toward(velocity.x, normalized.x * speed * speed_multiplier, accel * delta)
	velocity += Vector2.DOWN * gravity * delta
	
	if motion != 0:
		sprite.scale.x = sign(motion)
	
	if is_on_floor():
		anim.play("idle" if velocity.x == 0 else "run")
	else:
		anim.play("jump" if velocity.y < 0 else "fall")
	
	pushing = false
	if move_and_slide():
		var collision = get_last_slide_collision()
		var collider = collision.get_collider()
		
		if is_on_floor() and collider is Pushable and collision.get_normal().x == -motion:
			collider.apply_force(motion * speed * 0.4)
			pushing = true


func _on_player_input_just_pressed(ev: InputEvent):
	if ev.is_action_pressed("jump") and is_on_floor():
		velocity += Vector2.UP * jump_force
	elif ev.is_action_pressed("interact"):
		hand.interact()
	elif ev.is_action_pressed("time_travel"):
		# still need animation for clones
		
		if is_main_player():
			GameManager.travel_back()
