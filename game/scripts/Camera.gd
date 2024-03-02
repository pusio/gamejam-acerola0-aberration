extends Camera2D

var target: CharacterBody2D = null
@export var followSpeed: float = 10.0


func _process(delta: float) -> void:
	if target == null:
		return
	position = lerp(position, target.position, followSpeed * delta)
	return
