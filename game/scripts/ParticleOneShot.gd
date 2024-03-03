extends CPUParticles2D


func _ready() -> void:
	connect("finished", onFinish)
	emitting = true
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func onFinish() -> void:
	queue_free()
	return
