extends Destroyable

@export var possibleFruits: Array[PackedScene]
@export var fruitRange: Vector2i

@onready var fadeArea: Area2D = $FadeArea
@onready var stump: Sprite2D = $Stump
@onready var core: Sprite2D = $Core
@onready var leaves: Sprite2D = $Core/Leaves
@onready var shadow: Sprite2D = $"-Shadow"
@onready var collisionShape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	prepareVariants()
	prepareFade()
	prepareFruits()
	return


# region: random flips and size
func prepareVariants() -> void:
	# scale
	var rndScale = randf_range(0.8, 1.5)
	core.scale *= rndScale
	stump.scale *= rndScale
	shadow.scale *= rndScale
	collisionShape.scale *= rndScale
	fadeArea.scale *= rndScale
	# flip
	if randi_range(0, 1) == 1:
		core.scale.x *= -1
		stump.scale.x *= -1

	return


# endregion

# region: if player is nearby - fade trunk
var lastCoreAlphaTween: Tween = null


func prepareFade() -> void:
	fadeArea.connect("body_entered", on_body_entered)
	fadeArea.connect("body_exited", on_body_exited)
	return


func on_body_entered(body: Node2D) -> void:
	if body is Player:
		tweenCoreAlpha(0.5)
	return


func on_body_exited(body: Node2D) -> void:
	if body is Player:
		tweenCoreAlpha(1.0)
	return


func tweenCoreAlpha(alpha: float) -> void:
	if lastCoreAlphaTween != null:
		lastCoreAlphaTween.kill()
	lastCoreAlphaTween = create_tween()
	lastCoreAlphaTween.set_ease(Tween.EASE_OUT)
	lastCoreAlphaTween.set_trans(Tween.TRANS_CUBIC)
	lastCoreAlphaTween.tween_property(core, "modulate", Color(1, 1, 1, alpha), 0.5)
	return


# endregion

# region: select random fruit type and spawnpoints
var myFruit: PackedScene
var myFruits: Array[Food] = []


func prepareFruits() -> void:
	myFruit = possibleFruits.pick_random()
	var fruitCount: int = randi_range(fruitRange.x, fruitRange.y)
	var spawnPoints = leaves.get_children() as Array[Node2D]
	while myFruits.size() < fruitCount:
		var rndSpawn = spawnPoints.pick_random()
		spawnPoints.erase(rndSpawn)
		var fruit = myFruit.instantiate() as Food
		leaves.add_child(fruit)
		fruit.position = rndSpawn.position
		rndSpawn.queue_free()
		fruit.call_deferred("notCollectableYet")
		myFruits.append(fruit)
		fruit.scale *= 1.0 / abs(core.scale.x)
	return
# endregion

# when hit drop fruits

# when hit again destroy leaves (fruits no longer grow), smaller shadow

# when hit again destroy core and spawn logs

# when hit again destroy this object
