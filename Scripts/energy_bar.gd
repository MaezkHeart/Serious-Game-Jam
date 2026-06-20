extends TextureProgressBar

@onready var tower : Node2D = self.owner

func _process(delta: float) -> void:
	self.value = tower.energy
