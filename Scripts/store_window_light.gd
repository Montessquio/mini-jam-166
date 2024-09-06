extends PointLight2D

var state: int = 0
var ticker: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match state:
		0:
			energy = 2.0
			ticker += 1
			if ticker > randi_range(120, 600):
				ticker = 0
				state = 1
		1:	
			energy = 1.0
			ticker += 1
			if ticker > randi_range(12, 60):
				ticker = 0
				state = randi_range(0, 2)
		2:
			energy = 0.1
			ticker += 1
			if ticker > randi_range(1, 12):
				ticker = 0
				state = randi_range(0, 2)
		_:
			state = 0
