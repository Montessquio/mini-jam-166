extends Area2D
class_name Pickup

@export var resource: String

@export var charcoal_img: Texture2D
@export var oil_seed_img: Texture2D
@export var volatile_amber_img: Texture2D

static var n_pickups: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	n_pickups += 1
	match resource:
		"charcoal":
			$"Sprite2D".texture = charcoal_img
		"oil seed":
			$"Sprite2D".texture = oil_seed_img
		"volatile amber":
			$"Sprite2D".texture = volatile_amber_img

func collect():
	print("Collected %s" % resource)
	$"Beeper".play()

func _on_beeper_finished() -> void:
	print("Killing %s" % resource)
	queue_free()
