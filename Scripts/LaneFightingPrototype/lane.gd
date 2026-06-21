
## Handles the spawning and setting up of all units (enemy or allied depending
## on parameters passed)

extends Area2D

const UNIT_PATH_FOLLOW = preload("uid://dtulup478vp38")
const SPAWN_RANGE = 120.0

var colors = [Color(1.0, 0.0, 0.0, 1.0),
		  Color(0.0, 1.0, 0.0, 1.0),
		Color(0.0, 1.0, 1.0, 1.0)
		]


func spawn_unit(unit_type: PackedScene, path: String, new_mask: int):
	var new_path_follow = UNIT_PATH_FOLLOW.instantiate()
	var new_unit = unit_type.instantiate()
	
	# Setting up path_follow/unit pair
	#print(new_unit)
	#print(new_path_follow)
	new_unit.path_follow = new_path_follow
	new_path_follow.unit = new_unit
	new_path_follow.find_child("EncounterArea").collision_mask = new_mask
	
	find_child(path).add_child(new_path_follow)
	find_child(path).add_child(new_unit)
	
	var rand_color = colors[randi() % colors.size()]
	new_unit.modulate = rand_color
	new_path_follow.get_node("Guide/Polygon2D").modulate = rand_color
	
	var spawn_position = new_path_follow.find_child("Guide").global_position
	
	spawn_position.y += randf_range(-SPAWN_RANGE, SPAWN_RANGE)
	new_unit.global_position = spawn_position
