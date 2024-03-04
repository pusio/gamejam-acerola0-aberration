class_name Tools


static func replaceTextureInChildren(node: Node, texture: Texture2D) -> void:
	for child in node.get_children():
		if child.name.begins_with("[x]"):
			continue
		if child is Sprite2D:
			(child as Sprite2D).texture = texture
		Tools.replaceTextureInChildren(child, texture)
	return


static func getRelativeMousePosition(owner: Node) -> Vector2:
	var viewportRect = owner.get_viewport_rect()
	var mousePosition = owner.get_viewport().get_mouse_position()
	return mousePosition / viewportRect.size - Vector2(0.5, 0.5)
