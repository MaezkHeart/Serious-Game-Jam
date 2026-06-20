extends Node2D
## This script checks the mouse movemement of player and inputs
## Temporarily, it is doing some of the actions on input

# TODO : Fix crash when reloading screen and clicking at the same time
signal left_click
signal scrolled_up
signal scrolled_down

# Detects Core, Bits and Towers layers
const RAYCAST_COLLISION_MASK = 28
const TOWER_LAYER = 4

# Takes two values : [Node, collision layer]
var mouse_over_interractible : Array 
var resources := 0:
	set(value):
		resources = value
		resource_label.text = "Resources = " + str(value)
var time_in_level: float = 0.0

@onready var resource_label: Label = %ResourceLabel
@onready var core: Node2D = %Core
@onready var level: Node2D = %Level1
@onready var tower_manager: Node2D = %TowerManager


func _process(_delta: float) -> void:
	
	## Checking if mouse is over interractible
	mouse_over_interractible = raycast_check_for_interractibles()
	
	## Handling resource collection
	if !mouse_over_interractible.has(null):
		if mouse_over_interractible[0].get_parent() == core:
			resources += mouse_over_interractible[0].collect_bit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		
		if mouse_over_interractible[0] == core:
			core.core_mined()
		elif mouse_over_interractible[1] == TOWER_LAYER:
			tower_manager.upgrade_tower(mouse_over_interractible[0])
		else:
			left_click.emit()
	
	if event.is_action("scroll_wheel_up"):
		scrolled_up.emit()
	
	if event.is_action("scroll_wheel_down"):
		scrolled_down.emit()


func raycast_check_for_interractibles():
	## This function returns the node that mouse hovers over and its
	## collision layer
	var space_state = get_world_2d().direct_space_state
	var parameters  = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collision_mask = RAYCAST_COLLISION_MASK
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return [result[0].collider.get_parent(),
				result[0].collider.collision_layer]
	return [null, null]
