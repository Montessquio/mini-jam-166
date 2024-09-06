extends RigidBody2D

var lifetime: float = 2.0 # How long the particle lives, in seconds, before vanishing.
var remaining_life: float
var birth_force: Vector2

var remaining_hits: int
var hit_damage: int
var hit_stun_inc: int
var hit_stun_max: int
var enflame_time: float
var enflame_max_time: float
var enflame_tick_damage: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_central_impulse(birth_force)
	remaining_life = lifetime
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$PointLight2D.rotation = rotation
	lifetime -= delta

	if lifetime < 0.0:
		die()

	# Select frame based on the remaining lifetime.
	$AnimatedSprite2D.pause()
	$AnimatedSprite2D.frame = (1.0 - (remaining_life / lifetime)) * $AnimatedSprite2D.sprite_frames.get_frame_count("default")
	#$PointLight2D.energy = (remaining_life / lifetime)
		
func _physics_process(_delta: float) -> void:
	pass

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("apply_hit"):
		if remaining_hits <= 0:
			die()
		else:
			remaining_hits -= 1
			area.apply_hit(hit_damage, hit_stun_inc, hit_stun_max, enflame_time, enflame_tick_damage, enflame_max_time)

func die():
	queue_free()
