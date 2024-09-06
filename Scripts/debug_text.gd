extends RichTextLabel
@export_category("Data Refs")
@export var player: NodePath
@export var health_bar: NodePath
@export var fuel_bar: NodePath
@export var camera: NodePath
@export var sound_controller: NodePath
@export var entity_counter: NodePath

var ticks: int = 0

func _ready() -> void:
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if ticks == 9223372036854775807:
		ticks = 0
	else:
		ticks += 1
	
	if Input.is_action_just_released("debug_toggle"):
		visible = not visible

	printvars()

func printvars() -> void:
	text = ""
	push_color(Color.WHITE)
	add_text("TICK: %d\n" % ticks)
	add_text("PLAYER: (%d, %d)\n" % [get_node(player).position.x, get_node(player).position.y])
	add_text("PLAYER: %d / %d HP (%d%%)\n" % [get_node(player).get_health(), get_node(player).max_health, get_node(health_bar).value * 100.0])
	add_text("PLAYER: %d / %d FU (%d%%)\n" % [get_node(player).get_fuel(), get_node(player).max_fuel, get_node(fuel_bar).value * 100.0])
	add_text("CAMERA: ZOOM (%.2f, %.2f)\n" % [get_node(camera).zoom.x, get_node(camera).zoom.y])
	add_text("MUSIC: is_in_combat=%s\n" % get_node(sound_controller).is_in_combat)
	var mcombat = get_node(sound_controller).get_node("Danger")
	add_text("MUSIC: COMBAT Vol=%sdB T=%.2f\n" % [mcombat.volume_db, mcombat.get_playback_position() + AudioServer.get_time_since_last_mix()])


	var msafety = get_node(sound_controller).get_node("Safety")
	add_text("MUSIC: SAFETY Vol=%sdB T=%.2f\n" % [msafety.volume_db, msafety.get_playback_position() + AudioServer.get_time_since_last_mix()])

	var ec = get_node(entity_counter)
	add_text("ENEMIES: %d/%d\n" % [ec.current_enemies, ec.total_enemies])
	add_text("TREES: %d/%d\n" % [ec.current_trees, ec.total_trees])
	add_text("TOTAL: %d/%d (%.2f%%)\n" % [
		float(ec.current_enemies + ec.current_trees),
		ec.total_enemies + ec.total_trees,
		float(ec.current_enemies + ec.current_trees) / (ec.total_enemies + ec.total_trees)
	])

	add_text("CUR_DMG_COUNT: %d\n" % get_node(player).enemies_damaging_count)
	add_text("CUR_DMG_COOLDOWN: %.2f" % get_node(player).damage_cooldown)