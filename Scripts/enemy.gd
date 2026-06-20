extends PathFollow2D

signal health_changed

@export var move_speed : float
@export var health : float
@export var damage : float

var max_health : float
#var is_trapped := false
#var external_attraction
#var t := 0.0
#var original_position

@onready var core: Node2D = $"../../Core"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var enemy_poly: Node2D = $MoveableElement/EnemyPoly
@onready var moveable_element = $MoveableElement
@onready var moveable_pos: Vector2 = moveable_element.position:
	set(value):
		moveable_element.position = value
		moveable_pos = value

func _ready():
	max_health = health

# TODO : Make it so enemies keep walking after they return on the line
# TODO : Make it so enemies either find the closest point on the line or cache the position they should be at
func _process(delta: float) -> void:
	#if external_attraction:
		#apply_attraction()
	
	#elif is_trapped == false:
		progress += move_speed * delta
		if progress_ratio == 1.0:
			core.take_damage(damage)
			queue_free()

#
#func apply_attraction():
	#moveable_pos = lerp(
			#moveable_pos,
			#external_attraction,
			#t
		#)
	#t += 0.01
	#if t >= 0.8 and is_trapped == false:
		#external_attraction = Vector2.ZERO
		#t = 0.0


func bullet_hit(bullet_damage):
	health -= bullet_damage
	health_changed.emit()
	
	if health <= 0:
		queue_free()


# Both of the following functions get the vector between local position and
# trap position relative to enemy. This is an ugly way of doing it
#func trapped(trap : Node2D):
	#animation_player.play("enemy_fall")
	#original_position = moveable_pos
	#
	#var destination = trap.global_position
	#var distance = moveable_element.global_position.distance_to(destination)
	#var angle = moveable_element.global_position.direction_to(destination)
	#var local_destination = angle * distance
	#
	#external_attraction = local_destination
#
#
#func attracting_to_trap(destination : Vector2, MAX_DISTANCE : float):
	#original_position = moveable_pos
	#
	#var distance = moveable_pos.distance_to(destination)
	#var angle = moveable_pos.direction_to(destination)
	#
	## Max distance is a percentage of total distance
	#var reduced_distance =  min(distance, distance * (MAX_DISTANCE / 100))
	#var new_local_destination = angle * reduced_distance
	#
	#external_attraction = Vector2(new_local_destination.x, new_local_destination.y)
