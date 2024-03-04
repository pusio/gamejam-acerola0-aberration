extends Area2D
class_name Collectable

enum CollectableType { Unknown = 0, Food = 1 }

var type: CollectableType = CollectableType.Unknown


func _ready() -> void:
	connect("body_entered", on_body_entered)
	virtual_onReady()
	return


func on_body_entered(body: Node2D) -> void:
	if body is Player:
		virtual_onPickup(body as Player)
	return


func virtual_onPickup(_player: Player) -> void:
	return


func virtual_onReady() -> void:
	return
