extends Node

@export var player_scene: PackedScene

const levels = {
	0: "res://src/levels/level_0.tscn",
	1: "res://src/levels/level_1.tscn",
}

var current_level = 0
var main_player: Player
var clones = []

func start_game():
	SceneManager.change_scene("res://src/levels/level_%s.tscn" % current_level)
	await SceneManager.scene_loaded
	
	var current_scene = get_tree().current_scene
	print(current_scene.name)
	var spawn = current_scene.find_child("Spawn") as Node2D
	for player in _create_players():
		current_scene.add_child(player)
		player.global_position = spawn.global_position
		
#		if player.is_main_player():
#			var remote = RemoteTransform2D.new()
#			remote.remote_path = current_scene.get_path_to(camera)
#			player.add_child(remote)

func next_level():
	current_level += 1
	clones = []
	start_game()

func _unhandled_input(event):
	if main_player:
		main_player.input.handle_input(event)

func _create_players() -> Array[Player]:
	var players: Array[Player] = []
	for clone in clones:
		var p = player_scene.instantiate()
		p.events = clones
		players.append(p)
	
	main_player = player_scene.instantiate()
	players.append(main_player)
	return players
