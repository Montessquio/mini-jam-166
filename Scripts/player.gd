extends CharacterBody2D
class_name Player

@export_category("Player Statstics") 
@export var zoom_bounds: Vector2 = Vector2(0.5, 1.0)
@export var zoom_step: float = 1.05
@export var move_speed: float = 8.0 # How fast the player will move (pixels/sec).
@export var aim_speed: float = 5.0 # How fast the player will rotate (deg/sec).
@export var max_health: float
@export var max_fuel: float

@export_category("Weapon Statistics")
@export var flamer_particle_birth_force_magnitude: float
@export var flamer_particle_lifetime_range: Vector2
@export var flamer_particle_spread_range: Vector2
@export var flamer_particle_quantity_mult: Vector2
@export var flamer_particle_hp: int
@export var flamer_particle_hit_damage: float
@export var flamer_particle_hit_stun_inc: float
@export var flamer_particle_hit_stun_max: float
@export var flamer_particle_enflame_time: float
@export var flamer_particle_enflame_max_time: float
@export var flamer_particle_enflame_tick_damage: float

@export_category("World Interaction")
@export var fuel_regen_per_tick: float = 1.0
@export var health_pad_regen_per_tick: float = 1.0

@export_category("Prefabs and References")
@export var player_camera: NodePath
@export var sound_controller: NodePath
@export var shop_overlay: NodePath
@export var health_bar: NodePath
@export var fuel_bar: NodePath
@export var particle_container: NodePath
@export var flamer_particle_prefab: Resource

@export var on_lose_node: NodePath

### Operational Variables ###
var cur_health: float = 0
var cur_fuel: float = 0

var is_on_fuel_pad = false
var is_on_health_pad = false

var near_enemy_count = 0

var time_elapsed: float = 0.0

var can_shoot = true
var can_move = true

var resources = {
	"charcoal": 0,
	"oil seed": 0,
	"volatile amber": 0,
}
var upgrades = PlayerUpgrades.new()

var enemies_damaging_count: int = 0
var damage_cooldown: float = 0.0

var initialized = false

### Engine Methods ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_elapsed = 0.0
	add_health(max_health)
	add_fuel(max_fuel)
	get_node(on_lose_node).play = false
	initialized = true

func _process_damage() -> void:
	var net_health = -clampf(enemies_damaging_count * randf_range(50, 120), 0, max_health * 0.2)
	set_health(clamp(get_health() + net_health, 0, max_health))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	time_elapsed += _delta

	if initialized and get_health() == 0.0 or is_zero_approx(get_health()):
		print("INIT: %s" % initialized)
		print("HP: %.2f" % get_health())
		print("HPAPPROX: %s" % is_zero_approx(get_health()))
		$AnimatedSprite2D.animation = "dead"
		can_move = false
		can_shoot = false
		rotation_degrees = 0.0
		get_node(on_lose_node).text2 = "LOSE"
		get_node(on_lose_node).global_position = global_position
		get_node(on_lose_node).play = true

	if damage_cooldown == 0.0 or is_zero_approx(damage_cooldown):
		if enemies_damaging_count > 0:
			damage_cooldown = 1.0
			_process_damage()
	else:
		damage_cooldown = clamp(damage_cooldown - _delta, 0.0, INF)
	
	if Input.is_action_just_pressed("scroll_up"):
		get_node(player_camera).zoom.x = clamp(get_node(player_camera).zoom.x * zoom_step, zoom_bounds.x, zoom_bounds.y)
		get_node(player_camera).zoom.y = clamp(get_node(player_camera).zoom.y * zoom_step, zoom_bounds.x, zoom_bounds.y)
	if Input.is_action_just_pressed("scroll_down"):
		get_node(player_camera).zoom.x = clamp(get_node(player_camera).zoom.x / zoom_step, zoom_bounds.x, zoom_bounds.y)
		get_node(player_camera).zoom.y = clamp(get_node(player_camera).zoom.y / zoom_step, zoom_bounds.x, zoom_bounds.y)

	if is_on_fuel_pad:
		add_fuel(fuel_regen_per_tick)
	if is_on_health_pad:
		add_health(health_pad_regen_per_tick)

func _physics_process(delta: float) -> void:
	if can_move:
		velocity = calculate_movement_vector(delta)
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	animate(velocity)
	
	# Update the camera to follow the player.
	get_node(player_camera).position = position
	
	# Rotate the player to face the mouse.
	var raytrace = (position - get_global_mouse_position()).normalized()	
	rotation = lerp_angle(rotation, raytrace.angle() + PI, aim_speed * delta) # Lerp the angle smoothly

### Helpers ###

# Called from _process, returns the player's movement vector this frame.
func calculate_movement_vector(delta: float) -> Vector2:
	var v = Vector2.ZERO
	# Change the movement vector based on presed keys.
	if Input.is_action_pressed("move_right"):
		v.x += 1
	if Input.is_action_pressed("move_left"):
		v.x -= 1
	if Input.is_action_pressed("move_down"):
		v.y += 1
	if Input.is_action_pressed("move_up"):
		v.y -= 1
	
	# Normalize the movement vector so pressing
	# two keys at once doesn't double the speed.
	if v.length() > 0:
		v = v.normalized() * (move_speed / delta)
	return v

# Called from _process, plays sprite animations.
func animate(v: Vector2) -> void:
	# Start or stop the animation depending on
	# whether the sprite is moving.
	if v.length() > 0:
		
		$"AnimatedSprite2D".play()
	else:
		$"AnimatedSprite2D".stop()
	
	if v == Vector2.ZERO:
		$"AnimatedSprite2D".animation = "default"
	else:
		$"AnimatedSprite2D".animation = "walk"
		get_node(sound_controller).play_step()

func remove_health(amount: float):
	cur_health = clamp(cur_health - amount, 0, max_health)
	update_ui()

func add_health(amount: float):
	cur_health = clamp(cur_health + amount, 0, max_health)
	update_ui()

func get_health() -> float:
	return cur_health

func set_health(amount: float):
	cur_health = clamp(amount, 0, max_health)
	update_ui()

func remove_fuel(amount: float):
	cur_fuel = clamp(cur_fuel - amount, 0, max_fuel)
	update_ui()

func add_fuel(amount: float):
	cur_fuel = clamp(cur_fuel + amount, 0, max_fuel)
	update_ui()

func get_fuel() -> float:
	return cur_fuel

func set_fuel(amount: float):
	cur_fuel = clamp(amount, 0, max_fuel)

func update_ui():
	get_node(health_bar).value = float(cur_health) / float(max_health)
	get_node(fuel_bar).value = float(cur_fuel) / float(max_fuel)

func enter_shop(area: Area2D = null):
	print("SHOPENTER")
	can_shoot = false
	can_move = false
	get_node(shop_overlay).visible = true
	get_node(shop_overlay).redraw()

	if area:
		global_position = area.global_position
	pass

func exit_shop():
	print("SHOPEXIT")
	can_shoot = true
	can_move = true
	get_node(shop_overlay).visible = false
	pass

### Callbacks ###
func _on_player_trigger_box_area_exited(area:Area2D) -> void:
	if area.name.contains("HealthPad"):
		is_on_health_pad = false

	if area.name.contains("FuelPad"):
		is_on_fuel_pad = false

	if area.name.contains("UpgradeShopPad"):
		exit_shop()

func _on_player_trigger_box_area_entered(area:Area2D) -> void:
	if area.name.contains("HealthPad"):
		is_on_health_pad = true

	if area.name.contains("FuelPad"):
		is_on_fuel_pad = true

	if area.name.contains("UpgradeShopPad"):
		enter_shop(area)

	if area.name.to_lower().contains("pickup"):
		resources[area.resource] += 1
		area.collect()

func _on_player_activation_box_body_entered(body:Node2D) -> void:
	if body.name.to_lower().contains("enemy") && body.music_activator:
		near_enemy_count += 1
	get_node(sound_controller).is_in_combat = near_enemy_count > 0

func _on_player_activation_box_body_exited(body:Node2D) -> void:
	if body.name.to_lower().contains("enemy") && body.music_activator:
		near_enemy_count = clamp(near_enemy_count - 1, 0, 99999999999)
	get_node(sound_controller).is_in_combat = near_enemy_count > 0


func _on_player_hurt_box_area_entered(area:Area2D) -> void:
	var enemy = area.get_node("..")
	if enemy is Enemy and area.name.to_lower().contains("hitbox"):
		print("ENTER E: %s  A: %s" % [enemy.enemy_type, area.name])
		enemies_damaging_count += 1

func _on_player_hurt_box_area_exited(area:Area2D) -> void:
	var enemy = area.get_node("..")
	if enemy is Enemy and area.name.to_lower().contains("hitbox"):
		print("EXIT E: %s  A: %s" % [enemy.enemy_type, area.name])
		enemies_damaging_count = clamp(enemies_damaging_count - 1, 0, 99999999999)
