extends Area2D

const OBSTACLE_COLLISION_LAYER = 128
const PATH_COLLISION_LAYER = 64

var collider_shape : CollisionPolygon2D

@onready var visual_area: Polygon2D = $VisualArea
# we get the level by finding first child
@onready var level = get_tree().root.get_node("Main").get_child(0)
@onready var tower_manager: Node2D = level.get_node("TowerManager")
@onready var path : Path2D = level.get_node("EnemyPath")


func _ready():
	visual_area.polygon = find_child("CollisionPolygon2D").polygon
	
	tower_manager.entered_tower_placement_mode.connect(draw_tower_placement_mode_boundaries)
	tower_manager.entered_trap_placement_mode.connect(draw_trap_placement_mode_boundaries)
	tower_manager.exited_placement_mode.connect(remove_placement_mode_boundaries)
	
	if get_parent() == path:
		path.path_ready.connect(get_path_boundary)


func get_path_boundary():
	visual_area.polygon = find_child("CollisionPolygon2D").polygon


func draw_tower_placement_mode_boundaries():
	visual_area.visible = true


func draw_trap_placement_mode_boundaries():
	if not collision_layer == PATH_COLLISION_LAYER:
		visual_area.visible = true
	else:
		return


func remove_placement_mode_boundaries():
	visual_area.visible = false
