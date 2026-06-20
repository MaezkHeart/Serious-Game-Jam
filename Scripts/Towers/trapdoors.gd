extends Towers
class_name Trapdoors

var is_active = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var effect_timer: Timer = $EffectTimer
@onready var cooldown_timer: Timer = $CooldownTimer

func placement_initialize():
	cooldown_timer.start()

func _process(_delta: float) -> void:
	if turret_range.has_overlapping_areas() and is_active:
		var enemies_on_trap = turret_range.get_overlapping_areas()
		for i in enemies_on_trap.size():
			var captured_enemy = enemies_on_trap[i].owner
			captured_enemy.trapped(self)
		
		enemies_on_trap.clear()


func activate_trap():  # called at end of open anim
	effect_timer.start()
	is_active = true


func _on_cooldown_timer_timeout() -> void:
	animation_player.play("trapdoor_open")


func _on_effect_timer_timeout() -> void:
	animation_player.play("trapdoor_close") # starts cooldown timer at end
	is_active = false
