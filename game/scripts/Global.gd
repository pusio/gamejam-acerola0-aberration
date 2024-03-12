extends Node

@export var fadeBlock: ColorRect

var deaths: int = 0
var momoDefeated: bool = false
var boarisDefeated: bool = false
var sneksquikDefeated: bool = false
var websterDefeated: bool = false

func _ready() -> void:
	# toggle_fullscreen()
	fadeBlock.visible = false
	return


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit_game"):
		quit()
	if Input.is_action_just_pressed("toggle_fullscreen"):
		toggle_fullscreen()
	return


# https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html#quitting
func quit() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
	return


func toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	return


func die(really: bool = true) -> void:
	if really:
		deaths += 1
	await Tools.wait(self, 1.0)
	fadeBlock.visible = true
	fadeBlock.color = Color(0, 0, 0, 0)
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).tween_property(fadeBlock, "color", Color(0, 0, 0, 1), 1.0)
	await Tools.wait(self, 1.5)
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).tween_property(
		fadeBlock, "color", Color(0, 0, 0, 0), 1.0
	)
	await Tools.wait(self, 1.0)
	fadeBlock.visible = false
	return
