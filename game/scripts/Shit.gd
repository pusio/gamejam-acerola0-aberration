extends Node2D

@export var speed: float = 5.0


func _process(_delta: float) -> void:
	if Input.is_action_pressed("up"):
		position.y -= _delta * speed
	elif Input.is_action_pressed("down"):
		position.y += _delta * speed
	if Input.is_action_pressed("left"):
		position.x -= _delta * speed
	elif Input.is_action_pressed("right"):
		position.x += _delta * speed
	return
