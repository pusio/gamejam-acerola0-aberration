extends Destroyable

@export var possibleFruits: Array[PackedScene]
@export var fruitRange: Vector2i
@export var height: int

@onready var leaves: Sprite2D = $Leaves
@onready var shadow: Sprite2D = $"-Shadow"
@onready var collisionShape: CollisionShape2D = $CollisionShape2D


func virtual_onReady() -> void:
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

func virtual_onDamage() -> void:
	if myFruits.size() > 0:
		for i in range(1, randi_range(1, 3) + 1):
			if myFruits.size() == 0:
				break
			var fruit = myFruits.pick_random()
			myFruits.erase(fruit)
			fruit.dropOnGround(height)
	rotation_degrees = randf_range(2.0, 5.0)
	if randi_range(0, 1) == 1:
		rotation_degrees *= -1
	create_tween().set_trans(Tween.TRANS_BOUNCE).tween_property(self, "rotation", 0, 0.1)
	var fxTscn = preload("res://objects/fx/GreenSmall.tscn")
	var fx = fxTscn.instantiate()
	Tools.getRoot(self).add_child(fx)
	fx.global_position = leaves.global_position
	return


func virtual_onDestroy() -> void:
	if myFruits.size() > 0:
		for fruit in myFruits:
			fruit.dropOnGround(height)
		myFruits = []
	var fxTscn = preload("res://objects/fx/GreenBig.tscn")
	var fx = fxTscn.instantiate()
	Tools.getRoot(self).add_child(fx)
	fx.global_position = leaves.global_position + leaves.offset + leaves.region_rect.size / 2
	return

