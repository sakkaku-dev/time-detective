extends Node

@export var player_scene: PackedScene
@export var recorder: InputRecorder

const levels = {
	0: "res://src/levels/level_0.tscn",
	1: "res://src/levels/level_1.tscn",
}

var current_level = 0
var main_player: Player
var clones: Array[Array] = []

func start_current_level():
	SceneManager.change_scene("res://src/levels/level_%s.tscn" % current_level)
	await SceneManager.scene_loaded
	
	var current_scene = get_tree().current_scene
	var spawn = current_scene.find_child("Spawn") as Node2D
	for player in _create_players():
		current_scene.add_child(player)
		player.global_position = spawn.global_position

func next_level():
	current_level += 1
	clones = []
	start_current_level()

func _unhandled_input(event):
	if main_player:
		main_player.input.handle_input(event)

func _create_players() -> Array[Player]:
	var players: Array[Player] = []
	for clone in clones:
		var p = player_scene.instantiate()
		p.events = clone as Array[CloneEvent]
		players.append(p)
	
	main_player = player_scene.instantiate() as Player
	main_player.input.just_pressed.connect(_record_event)
	main_player.input.just_released.connect(_record_event)
	players.append(main_player)
	return players

func _record_event(ev: InputEvent):
	recorder.record_event(ev)

func travel_back():
	recorder.finish_event()
	clones.append(recorder.events)
	recorder.reset()
	start_current_level()
