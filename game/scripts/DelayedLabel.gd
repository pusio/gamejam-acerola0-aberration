extends Label
@export var delay: float


func _ready() -> void:
	self_modulate = Color(self_modulate.r, self_modulate.g, self_modulate.b, 0)
	await Tools.wait(self, delay)
	create_tween().tween_property(
		self, "self_modulate", Color(self_modulate.r, self_modulate.g, self_modulate.b, 1.0), 1.0
	)
	return
