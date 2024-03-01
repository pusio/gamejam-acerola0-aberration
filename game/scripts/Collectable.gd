extends Area2D
class_name Collectable

enum CollectableType { Unknown = 0, TestRed = 1, TestBlue = 2 }

@export var type: CollectableType = CollectableType.Unknown


func _ready() -> void:
	connect("body_entered", on_body_entered)
	return


func on_body_entered(body: Node2D) -> void:
	if body is Player && (body as Player).collectable_touched(self):
		queue_free()
	return
