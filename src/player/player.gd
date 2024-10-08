class_name Player
extends CharacterBody2D

signal died()

enum {
	MOVE,
	PUSH,
	JUMP,
	AIR,
	TRAVEL,
	HOLD,
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
@onready var label = $Label
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var koyori_timer: KoyoriTimer = $KoyoriTimer

const FULL_RESTART_THRESHOLD = 2.0

var state = AIR
var events: Array[CloneEvent] = []
var pushing_collider = null
var push_delta_x = 0
var motion = Vector2.ZERO

var travel_pressed = 0
var travel_hold = false
var is_traveling := false

var holding_obj = null
var id := 0
var dead = false

func _ready():
	sprite.material = sprite.material.duplicate()
	_update_highlight()
	GameManager.main_player_changed.connect(func(): _update_highlight())
	
	anim.play("RESET")
	
	label.text = "%s" % id
	if not events.is_empty():
		_process_event(events.pop_front())
	
	if is_main_player():
		hand.disable_highlight = false

func _update_highlight(enable = is_main_player()):
	var mat = sprite.material as ShaderMaterial
	mat.set_shader_parameter("enable", enable)

func _process_event(ev: CloneEvent):
	if is_main_player():
		events.clear()
		input.reset()
		return
	
	if ev.event != null:
		input.handle_input(ev.event)
	
	if not events.is_empty():
		get_tree().create_timer(ev.duration).timeout.connect(func(): _process_event(events.pop_front()))

func is_main_player() -> bool:
	return GameManager.main_player == self

func kill():
	dead = true
	_update_highlight(false)
	collision_shape_2d.disabled = true
	anim.play("death")
	await anim.animation_finished
	died.emit()
	queue_free()

func _physics_process(delta):
	if collision_shape_2d.disabled: return
	
	motion = _get_motion()
	if motion.x != 0:
		sprite.scale.x = sign(motion.x)
		
	if state != TRAVEL and not is_on_floor():
		state = AIR
	
	match state:
		MOVE: _move(delta)
		PUSH: _push(delta)
		JUMP: _jump()
		AIR: _air(delta)
		TRAVEL: _travel(delta)

func _travel(delta):
	if travel_hold:
		travel_pressed += delta
		if travel_pressed >= FULL_RESTART_THRESHOLD and is_main_player():
			GameManager.restart_level()

func _get_motion():
	var motion_x = input.get_action_strength("move_left") - input.get_action_strength("move_right")
	return Vector2(motion_x, 0).normalized()

func _air(delta):
	var motion = _get_motion()
	velocity.x = move_toward(velocity.x, motion.x * speed, air_accel * delta)
	
	anim.play("jump" if velocity.y < 0 else "fall")
	velocity += Vector2.DOWN * gravity * delta
	
	move_and_slide()
	if is_on_floor():
		state = MOVE

func _jump():
	velocity += Vector2.UP * jump_force
	state = AIR

func _push(delta):
	if not push_cast.is_colliding():
		state = MOVE
	elif sign(motion.x) != sign(push_delta_x):
		# TODO: fix multiple player pushing
		if motion.x != 0:
			anim.play("push_move")
		else:
			anim.play("push_idle")
		pushing_collider.apply_force(motion.x * push_force)
		global_position.x = pushing_collider.global_position.x + push_delta_x
	
func _move(delta):
	velocity.x = move_toward(velocity.x, motion.x * speed, accel * delta)
	
	if velocity.x == 0:
		anim.play("idle")
	elif motion.x != 0:
		anim.play("run")
	
	if move_and_slide():
		pass
		#var collision = get_last_slide_collision()
		#var collider = collision.get_collider()
		#if is_on_floor() and collider is Pushable and collision.get_normal().x == -motion.x:
			#state = PUSH
			#pushing_collider = collider
			#push_delta_x = global_position.x - collider.global_position.x

func holding(obj):
	state = HOLD
	holding_obj = obj

func _on_player_input_just_pressed(ev: InputEvent):
	print("[Player %s] Event pressed %s" % [id, ev])
	
	if ev.is_action_pressed("jump") and koyori_timer.can_jump(): # TODO: koyori does not work
		state = JUMP
	elif ev.is_action_pressed("interact"):
		hand.interact()
	elif ev.is_action_pressed("time_travel"):
		state = TRAVEL
		travel_pressed = 0
		travel_hold = true
		anim.play("travel_hold")


func _on_player_input_just_released(ev: InputEvent):
	print("[Player %s] Event released %s" % [id, ev])
	
	if ev.is_action_released("time_travel") and travel_hold:
		travel_hold = false
		if travel_pressed < FULL_RESTART_THRESHOLD and is_on_floor():
			_start_travel()

func _start_travel():
	if is_traveling: return
	
	is_traveling = true
	input.disable()
	velocity = Vector2.ZERO
	anim.play("travel")
	
	if is_main_player():
		GameManager.save_clone_record()
		await anim.animation_finished
		GameManager.load_level()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "travel" and not is_main_player():
		queue_free()
