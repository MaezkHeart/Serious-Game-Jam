extends ProgressBar

@onready var core : Node2D = $".."
@onready var health_label: Label = $HealthLabel

func _ready():
	core.health_changed.connect(update_health_bar)
	update_health_bar()

func update_health_bar():
	value = core.health * 100 / core.max_health
	health_label.text = str(core.health) + " / " + str(core.max_health)
