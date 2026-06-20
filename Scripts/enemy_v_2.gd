extends RigidBody2D

signal health_changed

@export var move_speed : float
@export var health : float
@export var damage : float

var path_follow : PathFollow2D
var max_health : float
var path_guide_pos : Vector2

@onready var core: Node2D = $"../../Core" # replace that
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var enemy_poly: Node2D = $EnemyPoly

func _ready():
	max_health = health
	global_position = path_follow.global_position


func _process(_delta: float) -> void:
	path_guide_pos = path_follow.global_position

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	
	state.apply_force(global_position.path_guide_pos)


func bullet_hit(bullet_damage):
	health -= bullet_damage
	health_changed.emit()
	
	if health <= 0:
		queue_free()
