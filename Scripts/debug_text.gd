extends RichTextLabel

var ticks: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ticks == 9223372036854775807:
		ticks = 0
	else:
		ticks += 1
	
	printvars()
	
func printvars() -> void:
	text = ""
	push_color(Color.WHITE)
	add_text("TICK: %d\n" % ticks)
	add_text("PLAYER: %d, %d" % [$"..".position.x, $"..".position.y])
