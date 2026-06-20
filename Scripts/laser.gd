extends Area2D

var hurtbox_active := false
var damage = 30

@onready var damage_tick: Timer = $DamageTick
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func enable_hurtbox():
	damage_tick.start()
	collision_shape.disabled = false


func disable_hurtbox():
	damage_tick.stop()
	collision_shape.disabled = true


func _on_damage_tick_timeout() -> void:
	var enemies_hit : Array = self.get_overlapping_areas()
	
	for i in enemies_hit.size():
		enemies_hit[i].owner.bullet_hit(damage)
