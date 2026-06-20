extends Node2D
class_name Towers

## Manages behaviour common to all turrets : initialize on placed down
## display if placeable or not

var tower_manager : Node2D # gets updated when instantiated
var next_upgrade : String
var shooting_angle : float

@onready var turret_range: Area2D = $TurretRange if find_child("TurretRange") else null
@onready var turret_body: Area2D = $TurretBody if find_child("TurretBody") else null
@onready var no_placement_zone: Area2D = $NoPlacementZone

@onready var pivot: Node2D = $Pivot


func _ready() -> void:
	tower_manager.exited_placement_mode.connect(place)


func place():
	if turret_range:
		turret_range.find_child("RangeCollider").disabled = false
	no_placement_zone.find_child("CollisionPolygon2D").disabled = false
	turret_body.collision_layer = 4
	no_placement_zone.visible = true
	
	tower_manager.exited_placement_mode.disconnect(place)
	
	placement_initialize()

func placement_initialize():
	return

func display_unplaceable():
	modulate = Color(0.77, 0.258, 0.186)


func display_placeable():
	modulate = Color(1.0, 1.0, 1.0)
