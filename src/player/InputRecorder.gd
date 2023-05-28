class_name InputRecorder
extends Node

@export var actions: Array[String] = []

var events: Array[CloneEvent] = []
var current_event = null
var duration = 0
var last_action = ""

func _get_recording_action(ev: InputEvent):
	for action in actions:
		if ev.is_action(action):
			return action
	return null

func record_event(ev: InputEvent):
	var action = _get_recording_action(ev)
	if action == null: return
	
	last_action = action
	finish_event()
	current_event = ev
	duration = 0
	
func finish_event(release_previous = false):
	events.append(CloneEvent.new(current_event, duration))
		
func reset():
	events = []
	duration = 0
	current_event = null

func _process(delta):
	duration += delta
