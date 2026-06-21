extends RigidBody2D
class_name UnitMovement

## /!\ The unit movement is divided between this script and unit_path_follow.gd
## Handles the physics part of all unit movement : The rigidbody tries it's 
## best to follow it path "guide" and stops when either itself or the "guide"
## has collided with adversary unit

@export var follow_strength := 10
@export var mov_speed = 0.9
var path_follow : Node2D
var path_guide : Node2D
var target_pos : Vector2

var encounter_collision_mask


func _ready() -> void:
	path_guide = path_follow.find_child("Guide")
	target_pos = path_guide.global_position
	set_up_encounter_mask()


func _process(_delta: float) -> void:
	target_pos = path_guide.global_position


func _physics_process(_delta: float) -> void:
	var bodies_intersecting = get_colliding_bodies()
	
	for i in bodies_intersecting.size():
		if bodies_intersecting[i].collision_layer == encounter_collision_mask:
			print("test")
			unit_encounter()
			break



func get_target_force(state :PhysicsDirectBodyState2D, origin, target):
	var norm_direction = origin.direction_to(target)
	var local_mov_speed = clampf(mov_speed, 0.0, origin.distance_to(target))
	var velocity = local_mov_speed * norm_direction / state.step
	velocity.y = velocity.y / 2
	state.linear_velocity = velocity
	


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	get_target_force(state, global_position, target_pos)


#func _on_body_entered(body: Node2D) -> void:
	#if body.collision_layer == encounter_collision_mask:
		#unit_encounter()


func unit_encounter():
	print("test")
	path_follow.is_stopped = true
	self.modulate = Color(0.242, 0.242, 0.242, 1.0)


# This function is made to be replaced by child of inheritance
func set_up_encounter_mask():
	pass
