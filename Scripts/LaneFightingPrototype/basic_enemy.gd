extends RigidBody2D

@export var follow_strength := 10

var path_follow : Node2D
var path_guide : Node2D
var target_pos : Vector2
var speed = 0.9

func _ready() -> void:
	path_guide = path_follow.find_child("Guide")
	target_pos = path_guide.global_position


func _process(_delta: float) -> void:
	target_pos = path_guide.global_position


func get_target_force(state :PhysicsDirectBodyState2D, origin, target):
	var norm_direction = origin.direction_to(target)
	var local_speed = clampf(speed, 0.0, origin.distance_to(target))
	state.linear_velocity = local_speed * norm_direction / state.step


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	get_target_force(state, global_position, target_pos)


func _on_body_entered(body: Node) -> void:
	#if body.collision_layer == 2:
		print("Collision with playerUnit")
