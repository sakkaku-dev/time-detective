class_name LevelManager
extends Node

const LEVELS_FOLDER = "res://src/levels"

func get_level_path(level: int):
	for lvl in list_available_levels():
		if lvl == level:
			return "%s/level_%s.tscn" % [LEVELS_FOLDER, level]
	
	return null

func list_available_levels():
	var levels = []
	var dir = DirAccess.open(LEVELS_FOLDER)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var level = file_name.split(".")[0].substr("level_".length())
			levels.append(int(level))
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open levels folder")

	levels.sort()
	return levels
