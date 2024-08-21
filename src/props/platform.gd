class_name Platform
extends SceneTile

@export var speed := 1.0
@export var running := false
@onready var follow: PathFollow2D = $PathFollow2D

var forward := true

func _process(delta):
	if running:
		if forward:
			follow.progress_ratio = min(follow.progress_ratio + delta * speed, 1)
			if follow.progress_ratio >= 1:
				forward = false
		else:
			follow.progress_ratio = max(follow.progress_ratio - delta * speed, 0)
			if follow.progress_ratio <= 0:
				forward = true

	#if running and follow.progress_ratio < 1:
		#follow.progress_ratio = min(follow.progress_ratio + delta * speed, 1)
	#elif not running and follow.progress_ratio > 0:
		#follow.progress_ratio = max(follow.progress_ratio - delta * speed, 0)
