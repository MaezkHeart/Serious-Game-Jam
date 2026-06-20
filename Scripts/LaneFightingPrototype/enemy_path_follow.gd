extends PathFollow2D

@export var speed = 0.0005

func _process(_delta: float) -> void:
	self.progress_ratio += speed
