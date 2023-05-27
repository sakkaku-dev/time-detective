extends Interactable

@export var gate: Gate
@export var anim: AnimationPlayer

func _ready():
	anim.play("RESET")
	interacted.connect(func(): anim.play("open"))
	
func open_gate():
	gate.open()

