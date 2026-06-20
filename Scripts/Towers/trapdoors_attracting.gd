extends Trapdoors


const MAX_DISTANCE = 30
@onready var attractor_range: Area2D = $AttractorRange


func attract():
	var targets_in_range = attractor_range.get_overlapping_areas()
	print(targets_in_range)
	for i in targets_in_range.size():
		targets_in_range[i].get_parent().attracting_to_trap(global_position, MAX_DISTANCE)
