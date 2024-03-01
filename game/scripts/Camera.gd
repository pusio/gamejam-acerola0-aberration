extends Camera2D

@onready var target: CharacterBody2D = $"../Player"
@export var followSpeed: float = 10.0


func _process(delta: float) -> void:
	position = lerp(position, target.position, followSpeed * delta)
	return
