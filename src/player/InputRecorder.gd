class_name InputRecorder
extends Node

@export var actions: Array[String] = []

var events: Array[CloneEvent] = []
var current_event = null
var duration = 0

func _is_recording_action(ev: InputEvent):
	for action in actions:
		if ev.is_action(action):
			return true
	return false

func record_event(ev: InputEvent):
	if not _is_recording_action(ev): return
	
	finish_event()
	current_event = ev
	duration = 0
	
func finish_event():
	events.append(CloneEvent.new(current_event, duration))
		
func reset():
	events = []
	duration = 0
	current_event = null

func _process(delta):
	duration += delta
