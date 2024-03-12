extends CanvasLayer


func _ready() -> void:
	$Quit.connect("pressed", Global.quit)
	return
