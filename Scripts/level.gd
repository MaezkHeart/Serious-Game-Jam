extends Node2D
## This script calculates time in level, handles enemy spawn time
## and its evolution throughout the wave

@export var spawn_time_evolution: Curve

const ENEMY = preload("uid://wnrjs17sxd4w")
const ENEMY_PATH_FOLLOW = preload("uid://1jk06orar4pn")

var time_in_level: float = 0.0

@onready var spawn_timer: Timer = %SpawnTimer
@onready var enemy_path: Path2D = %EnemyPath
@onready var timer_label: Label = %LevelTimerLabel

func _ready():
	spawn_timer.wait_time = spawn_time_evolution.sample(time_in_level)

func _process(delta) -> void:
	time_in_level += 1.0 * delta
	timer_label.text = str(snapped(time_in_level, 0.01))

func _on_spawn_timer_timeout() -> void:
	#var path_follow = ENEMY_PATH_FOLLOW.instantiate()
	var enemy = ENEMY.instantiate()
	#enemy.path_follow = path_follow
	
	#enemy_path.add_child(path_follow)
	enemy_path.add_child(enemy)
	
	
	
	spawn_timer.wait_time = spawn_time_evolution.sample(time_in_level)
