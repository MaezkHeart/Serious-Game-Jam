extends Towers
class_name RotatingTowers

## Manages the behaviour specific to rotating turrets : finds target,
## rotates to face target and shoot at fixed interval

# TODO: Show range outline in placement mode

const BULLET = preload("uid://dtewrc4kx2tii")

@export var max_energy = 100.0
@export var energy_loss_speed = 0.2
@export var energy_gain_speed = 2

var is_fueled := true
var target : Node2D
var targets_in_range : Array

@onready var energy = max_energy
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var bullet_spawn_point : Node2D = $Pivot/BulletSpawnPt
@onready var range_area : Area2D = $TurretRange

func _process(_delta: float) -> void:
	if energy > 0.0:
		energy -= energy_loss_speed
	else:
		is_fueled = false
	
	if not is_fueled:
		cooldown_timer.stop()
	elif targets_in_range:
		## Finding most adapted target based on focus mode
		## SHOOTING AT RANDOM ENEMIES
		#if (
				#not is_instance_valid(target)
				#or target == null
				#or not targets_in_range.has(target)
			#):
			#target = find_random_target()
			
		target = find_target()
		
		#rotate canon to point at closest enemy
		if target:
			shooting_angle = position.angle_to_point(target.global_position)
			pivot.rotation = shooting_angle


func energy_gain(gain : float):
	if energy <= max_energy: #and gain > 0:
		energy += abs(gain) * energy_gain_speed
		
		if not is_fueled:
			is_fueled = true


func _on_cooldown_timer_timeout() -> void:
	if targets_in_range:
		shoot()


func shoot():
	var offset = offset_canon()
	
	var bullet = BULLET.instantiate()
	add_sibling(bullet)
	bullet.rotation = shooting_angle
	bullet_spawn_point.position.y = offset
	bullet.position = bullet_spawn_point.global_position


func offset_canon():
	return 0


func _on_turret_range_area_entered(area: Area2D) -> void:
	targets_in_range.append(area.owner)
	if cooldown_timer.is_stopped(): # in case enemies re-enter range
		cooldown_timer.start()


func _on_turret_range_area_exited(area: Area2D) -> void:
	targets_in_range.erase(area.owner)


func find_random_target(): # Not in use
	for i in range(targets_in_range.size() - 1, -1, -1):
		if not is_instance_valid(targets_in_range[i]):
			targets_in_range.erase(i)
	
	return targets_in_range[randi_range(0, targets_in_range.size() - 1)]


func find_target():
	var current_best_target
	var max_progress = 0
	
	## Loops through targets to remove all deleted nodes
	for i in range(targets_in_range.size() - 1, -1, -1):
		if not is_instance_valid(targets_in_range[i]):
			print(targets_in_range)
			targets_in_range.pop_at(i)
			print(targets_in_range)
	
	## Loops through all enemies in range to find target
	for current_target in targets_in_range:
		
		if current_target.progress_ratio > max_progress: # TODO : Fix bug with current target not being deleted properly
			max_progress = current_target.progress_ratio
			current_best_target = current_target
	
	if targets_in_range:
		return current_best_target
	else:
		return null
