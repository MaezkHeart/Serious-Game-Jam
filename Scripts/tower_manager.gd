extends Node2D
## Manages tower purchase and placement

# These are used to display plac. block boundaries and init. towers on place
signal entered_tower_placement_mode
signal entered_trap_placement_mode
signal exited_placement_mode

const BASE_ROTATING_TOWER = "Rotating/T1"
const BASE_STATIC_TOWER = "Static/T1"
const BASE_TRAP_TOWER = "Trapdoor/T1"

var towers_dict := {
	"Rotating/T1" : preload("uid://be1i5jo3b7ouu"),
	"Rotating/T2" : preload("uid://dj2rgpqwii2m"),
	"Rotating/T3" : preload("uid://rfx3kryf01y7"),
	"Static/T1" : preload("uid://cbfsi1p55vlud"),
	"Static/T2" : preload("uid://buch8a18qbaro"),
	"Trapdoor/T1" : preload("uid://dcpn41kptd1jf"),
	"Trapdoor/T2" : preload("uid://v8o3bec5gnh3"),
	"NoMoreUpgrades" : null,
}

@export var tower_prices := {
	"Rotating/T1" : 0,
	"Rotating/T2" : 0,
	"Rotating/T3" : 0,
	"Static/T1" : 0,
	"Static/T2" : 0,
	"Static/T3" : 0,
	"Trapdoor/T1" : 0,
	"Trapdoor/T2" : 0,
	"Trapdoor/T3" : 0,
}

@export var main : Node2D
@export var rotation_increment := 20.0

var tower_is_placeable : bool = false
var selected_tower : Node2D = null
var selection_rotation : float = 0
var body_collider : Area2D
var path_polygon : PackedVector2Array

@onready var enemy_path: Path2D = %EnemyPath


func _process(_delta):
	# Adding the path polygon later once it is ready
	if path_polygon.is_empty():
		path_polygon = enemy_path.find_child("CollisionPolygon2D").polygon
	
	if selected_tower:
		placement_mode_behaviour()


func placement_mode_behaviour():
	selected_tower.position = get_global_mouse_position()
	selected_tower.pivot.rotation = selection_rotation
	
	if body_collider.has_overlapping_areas():
		selected_tower.display_unplaceable()
		tower_is_placeable = false
	
	elif not tower_is_placeable:
		selected_tower.display_placeable()
		tower_is_placeable = true


func rotate_tower_left():
	if selected_tower:
		selection_rotation -= rotation_increment


func rotate_tower_right():
	if selected_tower:
		selection_rotation += rotation_increment


func place_turret(): # This is called every left click
	if tower_is_placeable == true and selected_tower:
		selected_tower.shooting_angle = selection_rotation
		selected_tower = null
		exited_placement_mode.emit()


func initialize_tower(tower, tower_type):
	# TODO : Make it so you can't place tower underneath buttons
	if selected_tower:
		print("You already have a selected tower")
		return
	
	if main.resources < tower_prices[tower_type]:
		print("Not enough resources")
		return
	
	main.resources -= tower_prices[tower_type]
	
	tower.tower_manager = self
	tower.next_upgrade = tower_type.get_slice("/", 0) + "/T2"
	add_child(tower)
	body_collider = tower.find_child("TurretBody")
	
	if tower_type.get_slice("/", 0) == "Trapdoor":
		entered_trap_placement_mode.emit()
	else:
		entered_tower_placement_mode.emit()
	
	return tower


func _on_rotating_buy_btn_pressed() -> void:
	var new_tower = towers_dict[BASE_ROTATING_TOWER].instantiate()
	selected_tower = initialize_tower(new_tower, BASE_ROTATING_TOWER)


func _on_static_buy_btn_pressed() -> void:
	var new_tower = towers_dict[BASE_STATIC_TOWER].instantiate()
	selected_tower = initialize_tower(new_tower, BASE_STATIC_TOWER)


func _on_trap_buy_btn_pressed() -> void:
	var new_tower = towers_dict[BASE_TRAP_TOWER].instantiate()
	selected_tower = initialize_tower(new_tower, BASE_TRAP_TOWER)


func upgrade_tower(tower):
	var tower_pos : Vector2 = tower.position
	var tower_rotation : float = tower.shooting_angle
	var upgrade : String = tower.next_upgrade
	var new_upgrade
	var new_tower : Node2D
	
	if selected_tower:
		return
	
	if not towers_dict.has(upgrade):
		print("No More Upgrades")
		return
	
	if main.resources < tower_prices[upgrade]:
		print("Not enough resources")
		return
	
	main.resources -= tower_prices[upgrade]
	
	tower.queue_free()
	
	new_tower = towers_dict[upgrade].instantiate()
	new_tower.tower_manager = self
	add_child(new_tower)
	new_tower.position = tower_pos
	new_tower.shooting_angle = tower_rotation
	new_tower.pivot.rotation = tower_rotation
	
	new_tower.place()
	
	
	if "T2" in upgrade:
		new_upgrade = upgrade.get_slice("/", 0) + "/T3"
	elif "T3" in upgrade:
		new_upgrade = upgrade.get_slice("/", 0) + "/T4"
	elif "T4" in upgrade:
		new_upgrade = upgrade.get_slice("/", 0) + "/T5"
	
	if towers_dict.has(new_upgrade):
		new_tower.next_upgrade = new_upgrade
	else:
		new_tower.next_upgrade = "NoMoreUpgrades"
