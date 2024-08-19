class_name Platform
extends Path2D

@export var duration := 1.0
@export var idle_time := 0.5
@export var running := false:
	set(v):
		running = v
		#_set_progress(1.0 if v else 0.0)

@onready var follow := $PathFollow2D

#var tw: Tween

#func _set_progress(value: float):
	#if tw and tw.is_running():
		#tw.kill()
	#
	#tw = create_tween()
	#tw.tween_property(follow, "progress_ratio", value, duration).set_delay(idle_time)

func _process(delta):
	if running and follow.progress_ratio < 1:
		follow.progress_ratio = min(follow.progress_ratio + delta, 1)
	elif not running and follow.progress_ratio > 0:
		follow.progress_ratio = max(follow.progress_ratio - delta, 0)

#func _ready():
	#tw = create_tween()
	#tw.chain().tween_property(follow, "progress_ratio", 0.0, duration).set_delay(idle_time)
	#tw.set_loops()
	#
	#_update_anim_state()
	#
#
#func _set_running(value):
	#if running == value: return
	#running = value
	#_update_anim_state()
#
#func _update_anim_state():
	#if running:
		#tw.play()
	#else:
		#tw.pause()
