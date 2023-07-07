class_name Platform
extends Path2D

@export var duration := 1.0
@export var idle_time := 2.0
@export var running := false : set = _set_running

@onready var follow := $PathFollow2D

var tw: Tween

func _ready():
	tw = create_tween()
	tw.tween_property(follow, "progress_ratio", 1.0, duration).set_delay(idle_time)
	tw.chain().tween_property(follow, "progress_ratio", 0.0, duration).set_delay(idle_time)
	tw.set_loops()
	
	_update_anim_state()
	

func _set_running(value):
	if running == value: return
	running = value
	_update_anim_state()

func _update_anim_state():
	if running:
		tw.play()
	else:
		tw.pause()
