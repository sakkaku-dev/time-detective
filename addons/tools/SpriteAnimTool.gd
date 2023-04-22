@tool
class_name SpriteAnimTool
extends AnimationPlayer

@export var sprite: NodePath

@export var run: bool : set = execute

func update():
	pass

func execute(x):
	if not Engine.is_editor_hint(): return
	update()

func add_animation(name: String, start_frame: int, end_frame: int, duration: float, loop = true, discrete = true) -> void:
	var node = sprite
	var property = "frame"
	
	var lib = get_animation_library("")
	var anim = Animation.new()
	if lib.has_animation(name):
		anim = lib.get_animation(name)
	else:
		lib.add_animation(name, anim)
		
	anim.loop_mode = loop
	anim.length = duration
	
	var sprite_path = String(owner.get_path_to(get_node(node))) + ":" + property
	var existing_track = anim.find_track(sprite_path, Animation.TYPE_VALUE)
	if existing_track != -1:
		anim.remove_track(existing_track)
		
	var track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track, sprite_path)
	if discrete:
		anim.value_track_set_update_mode(track, Animation.UPDATE_DISCRETE)
		
	var total_frames = (end_frame - start_frame) + 1
	var frame_duration = duration / total_frames
	for i in range(0, total_frames):
		var frame = start_frame + i
		var key = anim.track_insert_key(track, frame_duration * i, i)
		anim.track_set_key_value(track, key, frame)
		
