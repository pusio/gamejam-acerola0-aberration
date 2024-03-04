extends Destroyable

@export var possibleFruits: Array[PackedScene]
@export var fruitRange: Vector2i

@onready var leaves: Sprite2D = $Leaves
@onready var shadow: Sprite2D = $"-Shadow"
@onready var collisionShape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	prepareVariants()
	prepareFruits()
	return


# region: random flips and size
func prepareVariants() -> void:
	# scale
	var rndScale = randf_range(1.0, 1.8)
	leaves.scale *= rndScale
	shadow.scale *= rndScale
	collisionShape.scale *= rndScale
	# flip
	if randi_range(0, 1) == 1:
		leaves.scale.x *= -1
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
		fruit.scale *= 1.0 / abs(leaves.scale.x)
	return
# endregion

# when hit drop fruits

# when hit again destroy this object
