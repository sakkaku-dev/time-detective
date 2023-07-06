extends Path2D

@export var speed_scale := 1.0
@export var idle_time := 2.0
@export var running := false

@export var anim: AnimationPlayer

var forward = true

func _ready():
	anim.speed_scale = speed_scale
	_start_move()

func start():
	running = true
	_start_move()

func _on_animation_player_animation_finished(anim_name):
	await get_tree().create_timer(idle_time).timeout
	_start_move()

func _start_move():
	if not running:
		return
	
	if forward:
		anim.play_backwards("run")
	else:
		anim.play("run")
	
	forward = not forward
