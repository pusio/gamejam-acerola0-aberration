extends AnimationPlayer


func _ready() -> void:
	await Tools.wait(self, 5)
	play("intro")
	return


func end() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	return
