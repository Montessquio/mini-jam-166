extends ProgressBar

var total_enemies: float
var total_trees: float

var current_enemies: float
var current_trees: float

@export var on_lose_node: NodePath

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	value = float(current_enemies + current_trees) / (total_enemies + total_trees)

	if value == 0.0 or is_zero_approx(value):
		get_node(on_lose_node).text2 = "WIN"
		get_node(on_lose_node).global_position = global_position
		get_node(on_lose_node).play = true
