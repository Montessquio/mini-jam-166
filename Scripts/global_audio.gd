extends Node

@export var safety_player: AudioStreamPlayer
@export var combat_player: AudioStreamPlayer
@export var steps_player: AudioStreamPlayer
@export var flamethrower_player: AudioStreamPlayer

@export var max_step_cooldown: float
var current_step_cooldown: float = 0.0
@export var steps_pitch_variance: Vector2

var is_in_combat: bool = false

var combat_volume_target: float = -100.0
var safety_volume_target: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	safety_player.play()
	combat_player.play()
	flamethrower_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_step_cooldown = clampf(current_step_cooldown - delta, 0.0, max_step_cooldown)

	var delta_mod = 1.0
	if is_in_combat:
		combat_volume_target = -2.0
		safety_volume_target = -100.0
	else:
		delta_mod = 0.1
		combat_volume_target = -100.0
		safety_volume_target = 8.0

	combat_player.volume_db = lerp(combat_player.volume_db, combat_volume_target, delta * delta_mod)

func start_flamethrower():
	flamethrower_player.volume_db = -10.0

func stop_flamethrower():
	flamethrower_player.volume_db = -100.0

func play_step():
	if current_step_cooldown <= 0.0:
		current_step_cooldown = max_step_cooldown
		steps_player.play()

func _on_danger_finished() -> void:
	pass

func _on_safety_finished() -> void:
	pass # Replace with function body.
