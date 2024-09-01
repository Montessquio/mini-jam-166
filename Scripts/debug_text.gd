extends RichTextLabel
@export_category("Data Refs")
@export var player: NodePath
@export var health_bar: NodePath
@export var fuel_bar: NodePath
@export var camera: NodePath

var ticks: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if ticks == 9223372036854775807:
		ticks = 0
	else:
		ticks += 1
	
	printvars()
	
func printvars() -> void:
	text = ""
	push_color(Color.WHITE)
	add_text("TICK: %d\n" % ticks)
	add_text("PLAYER: (%d, %d)\n" % [get_node(player).position.x, get_node(player).position.y])
	add_text("PLAYER: %d / %d HP (%d%%)\n" % [get_node(player).get_health(), get_node(player).max_health, get_node(health_bar).value * 100.0])
	add_text("PLAYER: %d / %d FU (%d%%)\n" % [get_node(player).get_fuel(), get_node(player).max_fuel, get_node(fuel_bar).value * 100.0])
	add_text("CAMERA: ZOOM (%d, %d)\n" % [get_node(camera).zoom.x, get_node(camera).zoom.y])