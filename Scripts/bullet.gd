extends Area2D

## Handles bullet movement and damage
# TODO : Make bullets despawn after a certain amount of time

@export var bullet_speed: float = 10.0
@export var bullet_damage = 75
var enabled = true


func _physics_process(_delta: float) -> void:
	position += Vector2.from_angle(rotation) * bullet_speed


func _on_area_entered(area: Area2D) -> void:
	# Enemy
	if area.collision_layer == 1 && enabled == true:
		area.owner.bullet_hit(bullet_damage)
		enabled = false
		queue_free()
	
	# Core
	elif area.collision_layer == 8 && enabled == true:
		area.get_parent().core_mined()
		area.get_parent().take_damage(bullet_damage)
		enabled = false
		queue_free()
