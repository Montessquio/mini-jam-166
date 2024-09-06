extends Button

@export var local_root: NodePath
@export var audio: NodePath
var fade_out = false
var packed_scene: PackedScene 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fade_out:
		get_node(audio).volume_db = lerp(get_node(audio).volume_db, -30.0, delta * 0.5)
		get_node(local_root).modulate.a = lerp(get_node(local_root).modulate.a, 0.0, delta)

		if is_zero_approx(get_node(local_root).modulate.a):
			get_node(audio).stop()
			get_tree().change_scene_to_file("res://Scenes/game_world.tscn")


func _on_pressed() -> void:
	fade_out = true
