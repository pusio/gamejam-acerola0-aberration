extends Camera2D
class_name GameCamera

@export var followSpeed: float = 10.0
@export var lookAheadDistance: float = 100.0

var target: CharacterBody2D = null
var lookAheadStrength: float = 0.0


func prepare(newTarget: CharacterBody2D) -> void:
	position_smoothing_enabled = false
	global_position = newTarget.global_position
	target = newTarget
	lookAheadStrength = 0
	await Tools.wait(self, 0.5)
	set_deferred("position_smoothing_enabled", true)
	var tween = create_tween()
	tween.tween_property(self, "lookAheadStrength", 1.0, 1.0)
	return


func _process(delta: float) -> void:
	if target == null:
		return
	var relativeMousePosition = Tools.getRelativeMousePosition(self)
	position = lerp(
		position,
		target.position + relativeMousePosition * lookAheadDistance * lookAheadStrength,
		followSpeed * delta
	)
	return
