extends RayCast2D

@export var line: Line2D

var casting = false : set = _set_casting

func toggle():
	self.casting = not casting

func _set_casting(v: bool):
	casting = v
	if casting:
		create_tween().tween_property(line, "width", 2, 0.2)
	else:
		create_tween().tween_property(line, "width", 0, 0.2)
	
	set_physics_process(casting)

func _physics_process(delta):
	var point = target_position
	if is_colliding():
		point = to_local(get_collision_point())
		
	line.points[1] = point
