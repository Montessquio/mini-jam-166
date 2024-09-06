extends Node2D

var _rand = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var p = $".."
	if Input.is_action_just_released("activate_primary") or p.get_fuel() <= 0 or not p.can_shoot:
		p.get_node(p.sound_controller).stop_flamethrower()

	if Input.is_action_pressed("activate_primary") and p.can_shoot:
		var mul = p.flamer_particle_quantity_mult.round()
		var hi = int(mul.x)
		var lo = int(mul.y)
		var n_projectiles = _rand.randi_range(int(lo), int(hi))
		for n in range(1, n_projectiles):
			# Each flame spits one fuel unit.
			if p.get_fuel() <= 0:
				return
			
			p.get_node(p.sound_controller).start_flamethrower()
			p.remove_fuel(1)
			
			var particle = p.flamer_particle_prefab.instantiate()
			particle.position = global_position
			particle.get_node("AnimatedSprite2D").rotation = global_rotation
			
			var jitter = _rand.randf_range(p.flamer_particle_spread_range.x, p.flamer_particle_spread_range.y)
			var launch_direction = (global_position - get_global_mouse_position()).normalized().rotated(deg_to_rad(jitter))
			var launch_vector = launch_direction * -p.flamer_particle_birth_force_magnitude
			
			particle.birth_force = launch_vector
			
			particle.lifetime = _rand.randf_range(p.flamer_particle_lifetime_range.x, p.flamer_particle_lifetime_range.y)
			
			particle.remaining_hits = p.flamer_particle_hp
			particle.hit_damage = p.flamer_particle_hit_damage
			particle.hit_stun_inc = p.flamer_particle_hit_stun_inc
			particle.hit_stun_max = p.flamer_particle_hit_stun_max
			particle.enflame_time = p.flamer_particle_enflame_time
			particle.enflame_max_time = p.flamer_particle_enflame_max_time
			particle.enflame_tick_damage = p.flamer_particle_enflame_tick_damage
			
			p.get_node(p.particle_container).add_child(particle)
