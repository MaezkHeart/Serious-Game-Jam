extends PathFollow2D

## Handles the movement of the unit "Guide"

@export var speed = 0.02

@onready var encounter_area: Area2D = $EncounterArea

var is_stopped := false
var unit : RigidBody2D


func _process(delta: float) -> void:
	#if encounter_area.has_overlapping_bodies() or is_stopped == true:
	if global_position.distance_to(unit.global_position) > 150.0 or is_stopped == true:
		self.modulate = Color(0.242, 0.242, 0.242, 1.0)
	else:
		self.progress_ratio += speed * delta
