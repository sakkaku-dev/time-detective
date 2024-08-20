class_name Platform
extends SceneTile

@export var duration := 1.0
@export var idle_time := 0.5
@export var running := false
@onready var follow: PathFollow2D = $Platform/PathFollow2D

func _process(delta):
	if running and follow.progress_ratio < 1:
		follow.progress_ratio = min(follow.progress_ratio + delta, 1)
	elif not running and follow.progress_ratio > 0:
		follow.progress_ratio = max(follow.progress_ratio - delta, 0)
