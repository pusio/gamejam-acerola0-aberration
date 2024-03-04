extends Camera2D
class_name GameCamera

@export var followSpeed: float = 10.0
@export var lookAheadDistance: float = 100.0

var target: CharacterBody2D = null


func prepare(newTarget: CharacterBody2D) -> void:
	position_smoothing_enabled = false
	global_position = newTarget.global_position
	target = newTarget
	set_deferred("position_smoothing_enabled", true)
	return


func _process(delta: float) -> void:
	if target == null:
		return
	var relativeMousePosition = Tools.getRelativeMousePosition(self)
	# print(relativeMousePosition)
	position = lerp(position, target.position + relativeMousePosition * lookAheadDistance, followSpeed * delta)
	return
