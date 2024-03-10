extends Collectable
class_name Food

@export var nutrition: int
@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite
@onready var shadow: Sprite2D = $"-Shadow"
var isOnGround: bool = true


# override
func virtual_onReady() -> void:
	type = CollectableType.Food
	if randi_range(0, 1) == 1:
		scale.x *= -1
	return


# override
func virtual_onPickup(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		player.eatFood(nutrition)
		queue_free()
	return


func notCollectableYet() -> void:
	collision.disabled = true
	isOnGround = false
	shadow.visible = false
	animateRotate()
	return


func animateRotate() -> void:
	if isOnGround:
		return
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		sprite, "rotation_degrees", randf_range(-10.0, 10.0), randf_range(0.3, 1.2)
	)
	tween.connect("finished", animateRotate)
	return
