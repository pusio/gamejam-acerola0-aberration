extends Area2D
class_name Collectable

enum CollectableType { Unknown = 0, Food = 1, Damage = 2 }

var type: CollectableType = CollectableType.Unknown


func _ready() -> void:
	connect("body_entered", on_body_entered)
	virtual_onReady()
	return


func on_body_entered(body: Node2D) -> void:
	virtual_onPickup(body)
	return


func virtual_onPickup(_body: Node2D) -> void:
	return


func virtual_onReady() -> void:
	return
