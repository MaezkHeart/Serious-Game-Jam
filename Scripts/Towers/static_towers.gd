extends Towers
class_name StaticTowers

## Manages the behaviour specific to static turrets : shoot at fixed interval

# TODO: Show laser outline in placement mode

const LASER = preload("uid://c36ertgoostda")

var laser_1 : Area2D
var laser_animation : AnimationPlayer

@onready var cooldown_timer_1: Timer = $CooldownTimer1
@onready var reset_timer_1: Timer = $LaserReset1
@onready var bullet_spawn_point : Node2D = $Pivot/BulletSpawnPt


func placement_initialize():
	cooldown_timer_1.start()


func _on_cooldown_timer_1_timeout():
	laser_1 = shoot(laser_1)
	reset_timer_1.start()


func shoot(laser):
	laser = LASER.instantiate()
	add_child(laser)
	laser.rotation = shooting_angle
	
	var offset = offset_canon()
	bullet_spawn_point.position.y = offset
	laser.global_position = bullet_spawn_point.global_position
	
	return laser


func offset_canon():
	return 0


func _on_laser_reset_1_timeout() -> void:
	laser_1.queue_free()
	cooldown_timer_1.start()
