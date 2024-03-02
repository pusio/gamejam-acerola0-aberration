class_name Tools


static func replaceTextureInChildren(node: Node, texture: Texture2D) -> void:
	for child in node.get_children():
		if child.name.begins_with("[x]"):
			continue
		if child is Sprite2D:
			(child as Sprite2D).texture = texture
		Tools.replaceTextureInChildren(child, texture)
	return
