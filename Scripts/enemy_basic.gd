extends RigidBody2D

@export var health: int = 20000
@export var stun_buildup: int = 0
@export var stun_decay: int = 10
@export var enflamed_timer: float = 0.0
@export var enflamed_dps: int = 0

var valid_targets = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.connect("timeout", self._tick)
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	enflamed_timer -= delta
	enflamed_timer = clamp(enflamed_timer - delta, 0, 1.7e23)
	
	if health <= 0:
		die()
		return
	
	# If we're no longer on fire...
	if is_enflamed():
		$EnflamedParticles.emitting = true
		$EnflamedParticles.lifetime = clamp(0.1 * enflamed_timer, 0.1, 0.30)
	else:
		# Clear the flame dps.
		enflamed_dps = 0
		# Clamp the enflamed timer to zero so it doesn't stay
		# negative for next time.
		enflamed_timer = 0.0
		$EnflamedParticles.emitting = false
	
# Called once per second.
func _tick():
	# Reduce the current stun amount every second, down to zero.
	stun_buildup = clamp(stun_buildup - stun_decay, 0, 9223372036854775807)
	
	# Only attack if not stunned
	if not is_stunned():
		try_attack()

	# Deal damage for being on fire.
	if is_enflamed():
		health -= enflamed_dps
		
	print("HP: %d ENF: %d s %d dps" % [health, enflamed_timer, enflamed_dps])

func apply_hit(damage: int, stun: int, stun_clamp: int, enflame: float, enflame_damage: int, enflame_max_time: float):	
	health -= damage
	# Rate limit stun buildup
	stun_buildup += clamp(stun, 0, stun_clamp)
	# Enflamed timer is re-set to whichever is longest,
	# either the new flame time, or the current remaining flame time.
	# It cannot go above max_time
	enflamed_timer = clamp(max(enflame, enflamed_timer+enflame), 0, enflame_max_time)
	# The damage dealt per second via enflame is always the highest possible.
	enflamed_dps = max(enflamed_dps, enflame_damage)

func is_stunned() -> bool:
	return stun_buildup > health

func is_enflamed() -> bool:
	return enflamed_timer > 0.0

func die():
	queue_free()

func try_attack():
	for target in valid_targets:
		var node = get_node(target)
		if node.name == "Player":
			node.remove_health(40)

func _on_enemy_basic_hit_box_body_entered(body: Node2D) -> void:
	valid_targets[body.get_path()] = null

func _on_enemy_basic_hit_box_body_exited(body: Node2D) -> void:
	valid_targets.erase(body.get_path())
