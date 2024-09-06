extends Node

@export var camera: Camera2D
@export var local_root: NodePath
@export var ui_layer: CanvasLayer
@export var shop_layer: CanvasLayer

var fade_out = false

var text1: String = "YOU"
var text2: String = "LOSE"

var play: bool = false
var state: int = 0
var _timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"1".visible = false
	$"2".visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		if play:
			$"1".text = text1
			$"2".text = text2

			_timer += delta
			match state:
				0:
					if _timer >= 0.50:
						$"1".visible = true
						screenshake(0.50)
						state = 1
				1:
					if _timer >= 1.50:
						$"2".visible = true
						screenshake(0.50)
						state = 2
				2:
					if _timer >= 5.0:
						if fade_out:
							get_node(local_root).modulate.a = lerp(get_node(local_root).modulate.a, 0.0, delta)
							shop_layer.visible = false
							for sibling in get_node("..").get_children():
								if sibling.name != name:
									sibling.visible = false
							if is_zero_approx(get_node(local_root).modulate.a):
								get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
						else:
							fade_out = true


func screenshake(duration: float):
	pass
