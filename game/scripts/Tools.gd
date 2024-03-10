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
	return owner.get_tree().root.get_child(0)


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
