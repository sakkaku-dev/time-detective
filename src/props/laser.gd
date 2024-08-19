extends RayCast2D

@onready var line_2d: Line2D = $Line2D
@onready var casting_particles: GPUParticles2D = $CastingParticles
@onready var collision_particles: GPUParticles2D = $CollisionParticles
@onready var beam_particles: GPUParticles2D = $BeamParticles


var is_casting: bool = false:
	set(value):
		is_casting = value

		beam_particles.emitting = is_casting
		casting_particles.emitting = is_casting
		
		if is_casting:
			appear()
		else:
			collision_particles.emitting = false
			disapear()

		set_physics_process(is_casting)


func _ready():
	is_casting = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		self.is_casting = not is_casting


func _physics_process(delta: float) -> void:
	var cast_point := target_position
	force_raycast_update()

	collision_particles.emitting = is_colliding()

	if is_colliding():
		var collider = get_collider()
		if collider is Player:
			collider.kill()
		
		cast_point = to_local(get_collision_point())
		collision_particles.global_rotation = get_collision_normal().angle()
		collision_particles.position = cast_point

	line_2d.points[1] = cast_point
	beam_particles.position = cast_point * 0.5
	beam_particles.process_material.emission_box_extents.x = cast_point.length() * 0.5

func appear() -> void:
	var tween = create_tween()
	tween.tween_property(line_2d, "width", 3.0, 0.2)

func disapear() -> void:
	var tween = create_tween()
	tween.tween_property(line_2d, "width", 0, 0.1)
