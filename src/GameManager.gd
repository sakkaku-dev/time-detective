extends Node

@export var player_scene: PackedScene
@export var recorder: InputRecorder
@export var level_manager: LevelManager

var current_level = 0
var main_player: Player
var clones: Array[Array] = []

func load_level(lvl = current_level):
	current_level = lvl
	
	var level_path = level_manager.get_level_path(lvl)
	if level_path:
		SceneManager.change_scene(level_path)
		await SceneManager.scene_loaded
	
		var current_scene = get_tree().current_scene
		var spawn = current_scene.find_child("Spawn") as Node2D
		for player in _create_players():
			current_scene.add_child(player)
			player.global_position = spawn.global_position
		
		recorder.start()
	else:
		print("Level does not exist")

func restart_level():
	clones = []
	main_player = null
	recorder.reset()
	load_level()

func next_level():
	current_level += 1
	restart_level()

func _unhandled_input(event):
	if main_player:
		_record_event(event)
		main_player.input.handle_input(event)

func _create_players() -> Array[Player]:
	var id := 1
	var players: Array[Player] = []
	for clone in clones:
		var p = player_scene.instantiate()
		p.id = id
		p.events = clone.duplicate() as Array[CloneEvent]
		players.append(p)
		id += 1
	
	main_player = player_scene.instantiate() as Player
	main_player.id = id
	players.append(main_player)
	return players

func _record_event(ev: InputEvent):
	recorder.record_event(ev)

func save_clone_record():
	# Currently loading next level
	if main_player == null:
		return
	
	recorder.finish_event()
	clones.append(recorder.events)
	recorder.reset()
	main_player = null
