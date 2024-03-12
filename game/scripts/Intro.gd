extends AnimationPlayer


func _ready() -> void:
	await Tools.wait(self, 5)
	play("intro")
	return


func end() -> void:
	Global.die(false)
	return
