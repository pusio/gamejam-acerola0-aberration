extends Collectable
class_name Food

@export var nutrition: int
@export var ownerSpecies: String
@export var randomSize: Vector2 = Vector2(1.0, 1.0)
@export var dropSpread: float = 5
@export var megaMode: bool = false
@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite
@onready var shadow: Sprite2D = $"-Shadow"
var isOnGround: bool = true
var isConsumed = false


# override
func virtual_onReady() -> void:
	type = CollectableType.Food
	if randi_range(0, 1) == 1:
		scale.x *= -1
	var size: float = randf_range(randomSize.x, randomSize.y)
	nutrition = roundi(nutrition * size)
	scale *= size
	if megaMode:
		var megaScale = randf_range(2.0, 5.0)
		scale *= megaScale
		nutrition = roundi(nutrition * megaScale)
	return


# override
func virtual_onPickup(body: Node2D) -> void:
	if isConsumed:
		return
	# cant eat own species (ai only)
	if body is BeastAI:
		var beast = body as BeastAI
		if beast.speciesController.familyGroupTag == ownerSpecies:
			return
	if body.has_method("eatFood"):
		Tools.playSound(body, "Eat", Tools.sizeToPitch(nutrition / 4.0))
		body.eatFood(nutrition)
		isConsumed = true
		queue_free()
	return


func notCollectableYet() -> void:
	collision.disabled = true
	isOnGround = false
	shadow.visible = false
	animateRotate()
	return


func dropOnGround(height: int) -> void:
	if isOnGround:
		return
	isOnGround = true
	var root = Tools.getRoot(self)
	var pos = global_position
	get_parent().call_deferred("remove_child", self)
	root.call_deferred("add_child", self)
	set_deferred("global_position", pos)
	var scaleDir = sign(scale.x)
	set_deferred("scale", Vector2(scaleDir, 1))
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	var fallHeight = height * randf_range(0.8, 1.2)
	var fallDuration: float = min(abs(fallHeight), 20.0) / 20.0
	var randomPosition = Vector2(
		randf_range(-10, 10) + randf_range(-dropSpread, dropSpread),
		fallHeight + randf_range(-dropSpread / 2.0, dropSpread / 2.0)
	)
	tween.tween_property(self, "global_position", pos + randomPosition, fallDuration)
	await tween.finished
	collision.disabled = false
	shadow.visible = true


func dropFromBody(bodySize: float) -> void:
	if isOnGround:
		return
	isOnGround = true
	set_deferred("scale", scale * bodySize)
	nutrition = roundi(nutrition * bodySize)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	var fallDuration: float = randf_range(0.3, 0.5)
	var randomPosition = Vector2(
		randf_range(-dropSpread, dropSpread), randf_range(-dropSpread / 2.0, dropSpread / 2.0)
	)
	tween.tween_property(self, "global_position", global_position + randomPosition, fallDuration)
	await tween.finished
	collision.disabled = false
	shadow.visible = true


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


func splashInWater() -> void:
	if isConsumed:
		return
	isConsumed = true
	Tools.playSound(self, "Splash", Tools.sizeToPitch(nutrition / 4.0))
	var fx = preload("res://objects/fx/Splash.tscn").instantiate()
	Tools.getRoot(self).add_child(fx)
	fx.global_position = global_position
	queue_free()
	return


func _process(_delta):
	if !isOnGround || isConsumed:
		return
	for body in get_overlapping_bodies():
		if body is TileMap:
			call_deferred("splashInWater")
			return
	return
