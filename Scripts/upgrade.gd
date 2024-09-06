extends Panel

var disable_buy: bool
var on_click_buy: Callable

var display_name: String
var desc: String
var desc_addl: Callable
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
	$"Effect".append_text(desc)
	if desc_addl:
		desc_addl.call($"Effect")

	if disable_buy:
		$"Button".disabled = true
		$"Button".visible = false
	else:
		$"Button".disabled = false
		$"Button".visible = true
		$"Button".pressed.connect(on_click_buy)

	for child in $"Costs".get_children():
		child.queue_free()
		
	for item in cost:
		$"Costs".add_child(item)
			