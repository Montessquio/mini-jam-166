extends CharacterBody2D

@export_category("Player Statstics") 
@export var move_speed: float = 400.0 # How fast the player will move (pixels/sec).
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
@export var health_bar: NodePath
@export var fuel_bar: NodePath
@export var particle_container: NodePath
@export var flamer_particle_prefab: Resource

### Operational Variables ###
var cur_health: float = 0
var cur_fuel: float = 0

var is_on_fuel_pad = false
var is_on_health_pad = false

var player_upgrades = PlayerUpgrades.new()

### Engine Methods ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_health(max_health)
	add_fuel(max_fuel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("scroll_up"):
		get_node(player_camera).zoom += 5

	if Input.is_action_pressed("scroll_down"):
		get_node(player_camera).zoom -= 5

	if is_on_fuel_pad:
		add_fuel(fuel_regen_per_tick)
	if is_on_health_pad:
		add_health(health_pad_regen_per_tick)

func _physics_process(delta: float) -> void:
	velocity = calculate_movement_vector()
	move_and_slide()
	
	animate(velocity)
	
	# Update the camera to follow the player.
	get_node(player_camera).position = position
	
	# Rotate the player to face the mouse.
	var raytrace = (position - get_global_mouse_position()).normalized()	
	rotation = lerp_angle(rotation, raytrace.angle() - (PI), aim_speed * delta) # Lerp the angle smoothly

### Helpers ###

# Called from _process, returns the player's movement vector this frame.
func calculate_movement_vector() -> Vector2:
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
		v = v.normalized() * move_speed
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

### Callbacks ###

func _on_health_pad_body_entered(_body: Node2D) -> void:
	is_on_health_pad = true

func _on_health_pad_body_exited(_body: Node2D) -> void:
	is_on_health_pad = false

func _on_fuel_pad_body_entered(_body: Node2D) -> void:
	is_on_fuel_pad = true

func _on_fuel_pad_body_exited(_body: Node2D) -> void:
	is_on_fuel_pad = false
