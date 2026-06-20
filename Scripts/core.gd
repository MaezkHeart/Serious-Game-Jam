extends Node2D

signal health_changed

#TODO: Improve by making it so bits doesn't clutter on the edges of screen

const MAX_SPAWN_RANGE = 300
const MIN_SPAWN_RANGE = 120

const CORE_BIT = preload("uid://d21kmve5f6t8b")

var screen_size

var max_health := 1000
var health := max_health


func _ready():
	screen_size = get_viewport_rect().size

func core_mined():
	var new_bit = CORE_BIT.instantiate()
	add_child(new_bit) # TODO: call_deferred() !!! 
	
	## Setting position of new bit in random pos inside circular area
	var rand_angle = Vector2.from_angle(randf_range(0.0, 2 * PI))
	var position_in_range = (
			rand_angle * randf_range(
			MIN_SPAWN_RANGE, MAX_SPAWN_RANGE)
			)
	
	## Making it impossible for bits to spawn out of screen
	new_bit.position = position_in_range.clamp(
		Vector2.ZERO - global_position,
		screen_size - global_position)


func take_damage(damage):
	health -= damage
	health_changed.emit()
	if health <= 0:
		get_tree().reload_current_scene()
