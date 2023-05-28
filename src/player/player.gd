class_name Player
extends CharacterBody2D

enum {
	MOVE,
	PUSH,
	JUMP,
	AIR,
}

@export var accel = 1000
@export var air_accel = 800
@export var speed = 150
@export var jump_force = 300
@export var push_force = 50

@export var input: PlayerInput
@export var anim: AnimationPlayer
@export var sprite: Sprite2D
@export var push_cast: RayCast2D
@export var hand: Hand

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var state = AIR
var events: Array[CloneEvent] = []
var pushing_collider = null
var push_delta_x = 0

func _ready():
	if not events.is_empty():
		_process_event(events.pop_front())
	
	if is_main_player():
		hand.disable_highlight = false

func _process_event(ev: CloneEvent):
	if ev.event != null:
		input.handle_input(ev.event)
	
	if not events.is_empty():
		get_tree().create_timer(ev.duration).timeout.connect(func(): _process_event(events.pop_front()))

func is_main_player() -> bool:
	return GameManager.main_player == self

func _physics_process(delta):
	match state:
		MOVE: _move(delta)
		PUSH: _push(delta)
		JUMP: _jump()
		AIR: _air(delta)

func _get_motion():
	var motion_x = input.get_action_strength("move_left") - input.get_action_strength("move_right")
	return Vector2(motion_x, 0).normalized()

func _air(delta):
	var motion = _get_motion()
	velocity.x = move_toward(velocity.x, motion.x * speed, air_accel * delta)
	
	if motion.x != 0:
		sprite.scale.x = sign(motion.x)
	
	anim.play("jump" if velocity.y < 0 else "fall")
	velocity += Vector2.DOWN * gravity * delta
	
	move_and_slide()
	
	if is_on_floor():
		state = MOVE

func _jump():
	velocity += Vector2.UP * jump_force
	state = AIR

func _push(delta):
	var motion = _get_motion()
	_grounded(motion)
	
	if not push_cast.is_colliding():
		state = MOVE
	elif sign(motion.x) != sign(push_delta_x):
		if motion.x != 0:
			anim.play("push_move")
		else:
			anim.pause()
			if sprite.frame == 13:
				sprite.frame = 14
		pushing_collider.apply_force(motion.x * push_force)
		global_position.x = pushing_collider.global_position.x + push_delta_x
	
	if not is_on_floor():
		state = AIR
	
func _move(delta):
	var motion = _get_motion()
	velocity.x = move_toward(velocity.x, motion.x * speed, accel * delta)
	_grounded(motion)
	
	anim.play("idle" if velocity.x == 0 else "run")
	
	if move_and_slide():
		var collision = get_last_slide_collision()
		var collider = collision.get_collider()
		if is_on_floor() and collider is Pushable and collision.get_normal().x == -motion.x:
			state = PUSH
			pushing_collider = collider
			push_delta_x = global_position.x - collider.global_position.x
	

func _grounded(motion: Vector2):
	if motion.x != 0:
		sprite.scale.x = sign(motion.x)
	
	if not is_on_floor():
		state = AIR

func _on_player_input_just_pressed(ev: InputEvent):
	if ev.is_action_pressed("jump") and is_on_floor():
		state = JUMP
	elif ev.is_action_pressed("interact"):
		hand.interact()
	elif ev.is_action_pressed("time_travel"):
		# still need animation for clones
		
		if is_main_player():
			GameManager.travel_back()
