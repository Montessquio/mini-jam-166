extends CharacterBody2D

@export var move_speed = 400 # How fast the player will move (pixels/sec).
@export var aim_speed = 5 # How fast the player will rotate (deg/sec).

var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	velocity = process_input()
	move_and_slide()
	animate(velocity)
	
	# Update the camera to follow the player.
	$"../PlayerView".position = position
	
	var target_angle = (position - get_global_mouse_position()).normalized().angle() - (PI)
	rotation = lerp_angle(rotation, target_angle, aim_speed * delta) # Lerp the angle smoothly

# Called from _process, returns the player's movement vector this frame.
func process_input() -> Vector2:
	var velocity = Vector2.ZERO # The player's movement vector.
	
	# Change the movement vector based on presed keys.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	# Normalize the movement vector so pressing
	# two keys at once doesn't double the speed.
	if velocity.length() > 0:
		velocity = velocity.normalized() * move_speed
	return velocity

# Called from _process, plays sprite animations.
func animate(velocity: Vector2) -> void:
	# Start or stop the animation depending on
	# whether the sprite is moving.
	if velocity.length() > 0:
		
		$"AnimatedSprite2D".play()
	else:
		$"AnimatedSprite2D".stop()
	
	if velocity == Vector2.ZERO:
		$"AnimatedSprite2D".animation = "default"
	else:
		$"AnimatedSprite2D".animation = "walk"
