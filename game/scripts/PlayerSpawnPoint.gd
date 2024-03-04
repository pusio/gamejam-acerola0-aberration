extends Node2D

@export var playerSpiecies: PackedScene
@export var playerTexture: Texture2D
@export var playerScript: Script


func _ready() -> void:
	var player = playerSpiecies.instantiate()
	get_parent().call_deferred("add_child", player)
	player.global_position = global_position
	player.set_script(playerScript)
	player.name = "Player"
	player.add_to_group("player")
	var cam: GameCamera = $"../Camera2D"
	cam.prepare(player)
	Tools.replaceTextureInChildren(player, playerTexture)
	queue_free()
	return
