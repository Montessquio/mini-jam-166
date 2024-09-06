extends AudioStreamPlayer

@export var intro: Resource
@export var main: Resource
var state = "intro"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stream = intro
	play()
	
func _on_finished() -> void:
	if state == "intro":
		state = "main"
		stream = main
		play()