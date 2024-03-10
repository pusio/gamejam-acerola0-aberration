extends Collectable
class_name AttackProjectile

@export var timeToLive: float
@export var speed: float

var direction: Vector2
var damage: int
var source: Node2D
var exclude: Array[Node]
var parentVelocity: Vector2


func prepare(dir: Vector2, dmg: int, vel: Vector2, src: Node2D, excl: Array[Node]) -> void:
	direction = dir.normalized()
	global_position = src.global_position
	rotation = Vector2.RIGHT.angle_to(direction)
	if rotation_degrees < -90 || rotation_degrees > 90:
		scale.x *= -1
		rotation_degrees -= 180
	damage = dmg
	exclude = []
	source = src
	parentVelocity = vel
	for ex in excl:
		exclude.append(ex)
	get_tree().create_timer(timeToLive).connect("timeout", queue_free)
	var sprite: Sprite2D = $Sprite
	var fadeTime = 0.15
	var targetScale = scale
	scale *= 0.3
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).tween_property(
		self, "scale", targetScale, timeToLive
	)
	if timeToLive > fadeTime:
		await Tools.wait(self, timeToLive - fadeTime)
	create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).tween_property(
		sprite,
		"self_modulate",
		Color(sprite.self_modulate.r, sprite.self_modulate.g, sprite.self_modulate.b, 0),
		minf(fadeTime, timeToLive)
	)
	return


func _process(delta) -> void:
	position += (direction * speed + parentVelocity) * delta
	pass


# override
func virtual_onReady() -> void:
	type = CollectableType.Damage
	return


# override
func virtual_onPickup(body: Node2D) -> void:
	if body == source:  # don't hit yourself
		# print("exclude self")
		return
	if exclude.has(body):  # don't hit already hit target or ally
		# print("exclude friend " + body.name)
		return
	if body.has_method("onHit"):
		body.onHit(damage, source)
	else:
		print("hit agains unsupported target: " + body.name)
	exclude.append(body)
	return
