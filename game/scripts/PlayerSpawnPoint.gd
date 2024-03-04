extends Node2D

@export var playerSpiecies: PackedScene
@export var playerTexture: Texture2D
@export var playerScript: Script


func _ready() -> void:
	# setup player
	var player = playerSpiecies.instantiate()
	get_parent().call_deferred("add_child", player)
	player.global_position = global_position
	player.set_script(playerScript)
	player.call_deferred("prepare", playerTexture)
	# setup camera
	var cam: GameCamera = $"../Camera2D"
	cam.prepare(player)
	queue_free()
	return
