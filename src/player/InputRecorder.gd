class_name InputRecorder
extends Node

@export var actions: Array[String] = []

var recording = false
var events: Array[CloneEvent] = []
var current_event = null
var duration = 0

func _get_recording_action(ev: InputEvent):
	for action in actions:
		if ev.is_action(action):
			return action
	return null

func record_event(ev: InputEvent):
	var action = _get_recording_action(ev)
	if action == null: return
	
	finish_event()
	current_event = ev
	duration = 0
	
func finish_event():
	if current_event:
		events.append(CloneEvent.new(current_event, duration))
		
func reset():
	events = []
	duration = 0
	current_event = null
	recording = false

func start():
	recording = true

func _process(delta):
	if recording and current_event:
		duration += delta
