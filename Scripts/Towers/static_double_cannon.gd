extends StaticTowers

@export var canon_offset = 25.0
@onready var cooldown_timer_2: Timer = $CooldownTimer2
@onready var reset_timer_2: Timer = $LaserReset2

var laser_2 : Area2D


func placement_initialize():
	cooldown_timer_1.start()
	cooldown_timer_2.wait_time = (cooldown_timer_2.wait_time + reset_timer_2.wait_time) / 2
	cooldown_timer_2.start()


func _on_cooldown_timer_2_timeout():
	laser_2 = shoot(laser_2)
	cooldown_timer_2.wait_time = cooldown_timer_1.wait_time
	reset_timer_2.start()


func offset_canon():
	canon_offset = abs(canon_offset) if canon_offset < 0 else -abs(canon_offset)
	return canon_offset


func _on_laser_reset_2_timeout() -> void:
	laser_2.queue_free()
	cooldown_timer_2.start()
