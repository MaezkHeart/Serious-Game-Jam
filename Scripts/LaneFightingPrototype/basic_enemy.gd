extends Unit


func set_up_encounter_mask():
	encounter_collision_mask = 1


func _on_attack_cooldown_timeout():
	attack_cooldown.wait_time = randf_range(1.5, 2.0)
	for i in enemies_in_range.size():
		if is_instance_valid(enemies_in_range[i]):
			enemies_in_range[i].defeat()


func defeat():
	if is_instance_valid(path_follow):
		path_follow.queue_free()
	#self.modulate = Color(0.891, 0.0, 0.915, 1.0)
	self.queue_free()
	
