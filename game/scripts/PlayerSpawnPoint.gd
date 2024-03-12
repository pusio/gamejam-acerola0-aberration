extends Node2D

@export var playerSpiecies: PackedScene
@export var playerTexture: Texture2D
@export var playerScript: Script


func _ready() -> void:
	if Global.deaths > 0:
		Tools.playSound(self, "Wierd", clampf(1.2 - Global.deaths * 0.01, 0.75, 1.2))
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
