extends CharacterBody2D
class_name Enemy

@export var entity_counter: NodePath

@export var enemy_type: String

@export var rotation_speed: float = 5.0
@export var health: int = 2000
@export var stun_buildup: int = 0
@export var stun_decay: int = 10
@export var enflamed_timer: float = 0.0
@export var enflamed_dps: int = 0

@export var self_scale: float = 0.0

@export var music_activator: bool = false

enum AiPlan { Jerk, JitterJump, Slow }
@export var ai_plan: AiPlan = AiPlan.Slow

@export_category("Slow AI Configuration")
@export var slow_movement_speed: float;

@export_category("Jerk AI Configuration")
@export var jerk_movement_speed: Vector2;
@export var jerk_movement_cooldown: Vector2;
@export var jerk_sidejump_chance: float
@export var jerk_sidejump_speed: Vector2;

@export_category("JitterJump AI Configuration")

@export_category("Drop Configuration")
@export var world_container: NodePath
@export var drop_prefab: Resource
@export var drop_name: String
@export var drop_amount: Vector2i
@export var drop_chance: float

var ai_state: int = 0
var ai_timer: float = 0.0
var is_player_detected = false
var __is_enflamed = false
var last_music_time: float = 0.0
var pathfinding_target: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0 + randf_range(0.0, 0.50)
	timer.one_shot = false
	timer.connect("timeout", self._tick)
	timer.start()

	if enemy_type != "tree":
		$AnimatedSprite2D.animation = enemy_type
		
	$"EnflamedParticles/FirePlayer".volume_db = 20.0
	last_music_time = randf_range(0.0, 20.0)
	if enemy_type == "tree":
		$HurtBox.scale *= 2
		$HitBox.scale = Vector2.ZERO
		$NoticeBox.scale = Vector2.ZERO
		$CollisionShape2D.scale *= 2
		$EnflamedParticles.scale *= 4
		$"EnflamedParticles/PointLight2D".visible = false

		if randi_range(0, 1) == 0:
			$AnimatedSprite2D.animation = "2treeA"
		else:
			$AnimatedSprite2D.animation = "2treeB"

		get_node(entity_counter).total_trees += 1.0
		get_node(entity_counter).current_trees += 1.0
	else:
		get_node(entity_counter).total_enemies += 1.0
		get_node(entity_counter).current_enemies += 1.0
	
	deflame()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_zero_approx(enflamed_timer - delta):
		__is_enflamed = false
		deflame()
	enflamed_timer = clamp(enflamed_timer - delta, 0, 1.7e23)
	
	if health <= 0:
		die()
		return

	# Control the animation based on whether or not it's moving.
	if velocity.is_zero_approx():
		$AnimatedSprite2D.pause()
	else:
		$AnimatedSprite2D.play()

func _physics_process(delta: float) -> void:
	if pathfinding_target == null:
		return

	$NavigationAgent2D.target_position = pathfinding_target.global_position
	var target_coords = $NavigationAgent2D.get_next_path_position()
	var distance_to_target = global_position.distance_to(pathfinding_target.global_position)
	move_with_plan(target_coords, distance_to_target, delta)

	# Rotate the enemy to face the movement direction.
	$AnimatedSprite2D.rotation = lerp_angle($AnimatedSprite2D.rotation, velocity.angle() - (2 * PI), rotation_speed * delta) # Lerp the angle smoothly	

# Called once per second.
func _tick():
	# Reduce the current stun amount every second, down to zero.
	stun_buildup = clamp(stun_buildup - stun_decay, 0, 9223372036854775807)

	# Deal damage for being on fire.
	if is_enflamed():
		health -= enflamed_dps

func enflame():
	$"EnflamedParticles/FirePlayer".play(last_music_time)
	$EnflamedParticles.emitting = true
	$EnflamedParticles.lifetime = clamp(0.1 * enflamed_timer, 0.1, 0.30)
	$"EnflamedParticles/PointLight2D".visible = true

func deflame():
	last_music_time = $"EnflamedParticles/FirePlayer".get_playback_position() + AudioServer.get_time_since_last_mix()
	$"EnflamedParticles/FirePlayer".stop()
	$"EnflamedParticles/PointLight2D".visible = false
	$EnflamedParticles.emitting = false

	# Clear the flame dps.
	enflamed_dps = 0
	# Clamp the enflamed timer to zero so it doesn't stay
	# negative for next time.
	enflamed_timer = 0.0

func move_with_plan(target_point: Vector2, distance_to_target: float, delta: float):
	match ai_plan:
		AiPlan.Jerk:
			move_jerk(target_point, distance_to_target, delta)
		AiPlan.JitterJump:
			move_jitter(target_point, distance_to_target, delta)
		AiPlan.Slow:
			move_slow(target_point, distance_to_target, delta)

func move_slow(target_point: Vector2, distance_to_target: float, delta: float):
	var direction = (target_point - global_position).normalized()
	if distance_to_target > 10:
		velocity = (direction.normalized() * (slow_movement_speed / delta))
	move_and_slide()

func move_jerk(target_point: Vector2, distance_to_target: float, delta: float):
	var direction = (target_point - global_position).normalized()
	if distance_to_target < 10:
		return
	
	match ai_state:
		0:
			$AnimatedSprite2D.speed_scale = 4.0
			velocity = (direction.normalized() * (randf_range(jerk_movement_speed.x, jerk_movement_speed.y) / delta)) * 5
			ai_state = 1
			ai_timer = 0.0
		1:
			ai_timer += delta
			if ai_timer > randf_range(jerk_movement_cooldown.x, jerk_movement_cooldown.y):
				ai_timer = 0.0
				velocity = Vector2.ZERO
				
				if randf_range(0, 1.0) <= jerk_sidejump_chance:
					ai_state = 2
				else:
					ai_state = 0
			else:
				$AnimatedSprite2D.speed_scale = clampf($AnimatedSprite2D.speed_scale * 0.90, 0.20, INF)
				velocity *= 0.90
		2:
			$AnimatedSprite2D.speed_scale = 4.0
			velocity = (direction.normalized().rotated(deg_to_rad(randf_range(-90.0, 90.0))) * (randf_range(jerk_sidejump_speed.x, jerk_sidejump_speed.y) / delta)) * 5
			ai_state = 3
			ai_timer = 0.0
		3:
			ai_timer += delta
			if ai_timer > randf_range(jerk_movement_cooldown.x, jerk_movement_cooldown.y):
				ai_timer = 0.0
				velocity = Vector2.ZERO
				ai_state = 0
			else:
				$AnimatedSprite2D.speed_scale = clampf($AnimatedSprite2D.speed_scale * 0.90, 0.20, INF)
				velocity *= 0.90
		_:
			ai_state = 0
	move_and_slide()

func move_jitter(target_point: Vector2, distance_to_target: float, delta: float):
	pass

func apply_hit(damage: int, stun: int, stun_clamp: int, enflame: float, enflame_damage: int, enflame_max_time: float):	
	health -= damage
	# Rate limit stun buildup
	stun_buildup += clamp(stun, 0, stun_clamp)
	# Enflamed timer is re-set to whichever is longest,
	# either the new flame time, or the current remaining flame time.
	# It cannot go above max_time
	enflamed_timer = clamp(max(enflame, enflamed_timer+enflame), 0, enflame_max_time)
	if not is_zero_approx(enflamed_timer):
		enflame()

	# The damage dealt per second via enflame is always the highest possible.
	enflamed_dps = max(enflamed_dps, enflame_damage)

func is_stunned() -> bool:
	return stun_buildup > health

func is_enflamed() -> bool:
	return __is_enflamed

func die():
	if randf_range(0.0, 1.0) < drop_chance:
		for i in randi_range(drop_amount.x, drop_amount.y):
			var pf = drop_prefab.instantiate()
			pf.name = "pickup %d" % (Pickup.n_pickups + 1)
			pf.resource = drop_name
			get_node(world_container).add_child(pf)
			pf.global_position = global_position

	if enemy_type == "tree":
		get_node(entity_counter).current_trees -= 1.0
	else:
		get_node(entity_counter).current_enemies -= 1.0
	queue_free()

func _on_enemy_notice_box_body_exited(body:Node2D) -> void:
	if body.name == "Player":
		is_player_detected = false
		pathfinding_target = null

func _on_enemy_notice_box_body_entered(body:Node2D) -> void:
	if body.name == "Player":
		is_player_detected = true
		pathfinding_target = body
