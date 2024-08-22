extends Node

signal paused(pause: bool)
signal main_player_changed()

@export var player_scene: PackedScene
@export var recorder: InputRecorder
@export var level_manager: LevelManager

var current_level = -1
var main_player: Player
var clones: Array[Array] = []

func _ready() -> void:
	get_tree().create_timer(0.1).timeout.connect(func(): _spawn_player())

func toggle_paused(pause = false):
	paused.emit(pause)

func load_level(lvl = current_level):
	current_level = lvl
	
	var level_path = level_manager.get_level_path(lvl)
	if level_path:
		SceneManager.change_scene(level_path)
		await SceneManager.scene_loaded
		_spawn_player()
	else:
		print("Level does not exist")

func _spawn_player():
	var current_scene = get_tree().current_scene
	var spawn = get_tree().get_first_node_in_group("spawn") as Node2D
	if spawn:
		for player in _create_players():
			current_scene.add_child(player)
			player.global_position = spawn.global_position
		
		recorder.start()

func restart_level():
	clones = []
	main_player = null
	recorder.reset()
	load_level()

func next_level():
	current_level += 1
	restart_level()

func _unhandled_input(event):
	if is_instance_valid(main_player):
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
	
	for p in players:
		p.died.connect(func():
			var prev = _kill_future_clones(p.id)
			if p.id == main_player.id:
				if prev:
					main_player = prev
					main_player_changed.emit()
				else:
					await get_tree().create_timer(1.0).timeout
					restart_level()
		)
	
	return players

func _kill_future_clones(id: int):
	var players = get_tree().get_nodes_in_group("player")
	players.sort_custom(func(a, b): return b.id > a.id)
	
	var first_alive = null
	for player in players:
		if player.id > id:
			player.kill()
		elif player.id < id and first_alive == null:
			first_alive = player
	
	return first_alive

func _record_event(ev: InputEvent):
	recorder.record_event(ev)

func save_clone_record():
	# Currently loading next level
	if not is_instance_valid(main_player):
		return
	
	recorder.finish_event()
	clones.append(recorder.events)
	recorder.reset()
	main_player = null
