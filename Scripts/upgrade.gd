extends Panel

var on_click_buy: Callable

var display_name: String
var desc: String
var cost: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()

func update():
	$"Name".text = ""
	$"Name".push_color(Color.WHITE)
	$"Name".add_text(display_name)

	$"Effect".text = ""
	$"Effect".push_color(Color.WHITE)
	$"Effect".add_text(desc)

	$"Button".pressed.connect(on_click_buy)

	for child in $"Costs".get_children():
		child.queue_free()
		
	for item in cost:
		if item is Node:
			$"Costs".add_child(item)
		elif item is String:
			var txt = RichTextLabel.new()
			txt.bbcode_enabled = true
			txt.add_text(item)
			$"Costs".add_child(txt)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
