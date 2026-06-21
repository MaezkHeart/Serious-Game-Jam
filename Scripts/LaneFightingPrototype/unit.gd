extends RigidBody2D
class_name Unit

## /!\ The unit movement is divided between this script and unit_path_follow.gd
## Handles the physics part of all unit movement and detection of adversary units
##
## The rigidbody tries it's best to follow its path "guide" and stops when it
## has collided with adversary or the "guide" has gotten too far away

@export var follow_strength := 10
@export var mov_speed = 0.6
@export var max_follow_range = 70.0
@export var reconnecting_range = 50.0

var path_follow : Node2D
var path_guide : Node2D
var target_pos : Vector2
var enemies_in_range: Array
var encounter_collision_mask
var is_away_from_guide := false

@onready var attack_cooldown: Timer = $AttackCooldown


func _ready() -> void:
	path_guide = path_follow.find_child("Guide")
	target_pos = path_guide.global_position
	attack_cooldown.wait_time = randf_range(1.5, 2.0)
	set_up_encounter_mask()


func _process(_delta: float) -> void:
	target_pos = path_guide.global_position
	
	## CHECKING GUIDE/UNIT DISTANCE 
	# Stopping unit when too far from guide to stop units "sneaking" behind lines
	if (
			is_away_from_guide == false
			and global_position.distance_to(target_pos) > max_follow_range
		):
		print("test too far")
		path_follow.is_stopped = true
		is_away_from_guide = true
		self.modulate = Color(0.0, 0.0, 0.0, 0.369)
		
	elif (
			is_away_from_guide == true
			and global_position.distance_to(target_pos) < reconnecting_range
		):
		print("test reconnect")
		path_follow.is_stopped = false
		is_away_from_guide = false
		self.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	## CHECKING COLLISION WITH ADVERSARY
	# Fix edge case where unit is too far from guide and collides an adversary
	if (
			enemies_in_range.size() > 0
			and not path_follow.is_stopped
		):
		path_follow.is_stopped = true
		unit_encounter(enemies_in_range)
	
	elif (
			enemies_in_range.is_empty()
			and path_follow.is_stopped
			and is_away_from_guide == false
		):
		path_follow.is_stopped = false
		self.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _physics_process(_delta: float) -> void:
	var bodies_intersecting = get_colliding_bodies()
	enemies_in_range.clear()
	
	for i in bodies_intersecting.size():
		if bodies_intersecting[i].collision_layer == encounter_collision_mask:
			enemies_in_range.append(bodies_intersecting[i])


func get_target_force(state :PhysicsDirectBodyState2D, origin, target):
	var norm_direction = origin.direction_to(target)
	var local_mov_speed = minf(mov_speed, origin.distance_to(target))
	var velocity = local_mov_speed * norm_direction / state.step
	
	# Decreasing y axis vel so the unit is pulled more towards the end than 
	# the center of the lane
	velocity.y = velocity.y / 2
	
	state.linear_velocity = velocity


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	get_target_force(state, global_position, target_pos)


#func _on_body_exited(body: Node) -> void: # no, no. replace
	#enemies_in_range.erase(body)
	#if enemies_in_range.is_empty():
		#path_follow.is_stopped = false


func unit_encounter(enemies: Array):
	self.modulate = Color(0.262, 0.262, 0.262, 1.0)
	for i in enemies.size():
		if not is_instance_valid(enemies[i]):
			pass
		else:
			#target_pos = enemies[i].global_position
			break
	attack_cooldown.start()


# This function is made to be replaced by child of inheritance
func set_up_encounter_mask():
	pass
