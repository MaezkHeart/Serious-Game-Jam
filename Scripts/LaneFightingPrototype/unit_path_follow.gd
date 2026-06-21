extends PathFollow2D

## Handles the movement of the unit "Guide"

@export var speed = 0.02

#@onready var encounter_area: Area2D = $EncounterArea

var is_stopped := false
var unit : RigidBody2D


func _process(delta: float) -> void:
	if is_stopped == false:
		self.progress_ratio += speed * delta
	else:
		self.modulate = Color(0.242, 0.242, 0.242, 1.0)
		
	# It could also be possible to detect enemies in contact with the guide
	# but the results are not great
	#if encounter_area.has_overlapping_bodies():
		
