extends Node


func _ready() -> void:
	toggle_fullscreen()
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
