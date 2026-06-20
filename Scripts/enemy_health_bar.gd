extends TextureProgressBar

@export var enemy : Node2D

func _ready():
	enemy.health_changed.connect(update_health_bar)
	
func update_health_bar():
	visible = true
	value = enemy.health * 100 / enemy.max_health
	
func _process(_delta):
	get_parent().rotation = -enemy.rotation
