class_name Tools


static func replaceTextureInChildren(node: Node, texture: Texture2D) -> void:
	for child in node.get_children():
		if child.name.begins_with("-"):
			continue
		if child is Sprite2D:
			(child as Sprite2D).texture = texture
		Tools.replaceTextureInChildren(child, texture)
	return


static func getRelativeMousePosition(owner: Node) -> Vector2:
	var viewportRect = owner.get_viewport_rect()
	var mousePosition = owner.get_viewport().get_mouse_position()
	return mousePosition / viewportRect.size - Vector2(0.5, 0.5)


static func wait(owner: Node, time: float) -> Signal:
	return owner.get_tree().create_timer(time).timeout


static func getRoot(owner: Node) -> Node:
	var godotRoot = owner.get_tree().root
	if godotRoot.has_node("Root"):
		return godotRoot.get_node("Root")
	if godotRoot.has_node("Intro"):
		return godotRoot.get_node("Intro")
	if godotRoot.has_node("Menu"):
		return godotRoot.get_node("Menu")
	return null


static func bodySizeToHeadSize(bodySize: float) -> float:
	var minBodySize: float = 0.5
	var maxBodySize: float = 1.0
	var minHeadSize: float = 1.4
	var maxHeadSize: float = 1.0
	var calcSize = (
		minHeadSize
		+ ((maxHeadSize - minHeadSize) / (maxBodySize - minBodySize)) * (bodySize - minBodySize)
	)
	return clampf(calcSize, maxHeadSize, minHeadSize)


static func playSound(owner: Node2D, fileName: String, pitch: float = 1.0) -> void:
	var sfx = load("res://objects/audio/%s.tscn" % fileName).instantiate()
	owner.get_tree().root.get_node("Global").add_child(sfx)
	sfx.global_position = owner.global_position
	sfx.pitch_scale = pitch
	sfx.max_distance = 500
	sfx.attenuation = 2.0
	sfx.connect("finished", sfx.queue_free)
	sfx.play()
	return


static func sizeToPitch(size: float) -> float:
	return clampf(1.0 / size, 0.25, 2.0)
