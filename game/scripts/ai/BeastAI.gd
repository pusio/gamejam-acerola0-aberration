extends CharacterBody2D
class_name BeastAI

@onready var spieciesController: Spiecies = $SpieciesController
@onready var sightArea: Area2D = $SightArea

var direction: Vector2 = Vector2.ZERO
var friendToFollow: Node2D = null
var enemyToFollow: Node2D = null
var foodToFollow: Node2D = null

var currentLogic: Callable
var logicBusy: bool
var logicLocked: bool
var spawnPoint: Vector2
var shouldBeAbleToMove: bool
var anger: float


func _ready() -> void:
	spieciesController.updateFace()
	spieciesController.mainBody = self
	spieciesController.setSize(randf_range(0.5, 1.0))

	currentLogic = logicIdle
	logicBusy = false
	set_deferred("spawnPoint", global_position)
	call_deferred("recalculateStats")
	return


func recalculateStats() -> void:
	spieciesController.hunger = randi_range(50, 500)
	spieciesController.health = randf_range(0.8, 1.0) * spieciesController.maxHealth
	return


func _physics_process(delta: float) -> void:
	spieciesController.virtual_process(self, delta, direction)
	if shouldBeAbleToMove:
		var lastCollision = get_last_slide_collision()
		if lastCollision != null:
			var collider = lastCollision.get_collider()
			if collider != null:
				if (
					collider is Destroyable  # attack if blocked by destroyable
					|| collider is Player  # attack if blocked by player
					|| (
						collider is BeastAI  # attack if blocked by enemy faction
						&& (
							(collider as BeastAI).spieciesController.familyGroupTag
							!= spieciesController.familyGroupTag
						)
					)
				):
					anger += delta
		else:
			anger = 0.0
	else:
		anger = 0.0
	if anger >= 0.5:
		spieciesController.virtual_attack(direction)
	aiCheats()
	if !logicBusy:
		rethinkLogic()
		currentLogic.call()
	return


func aiCheats() -> void:
	# don't starve
	if spieciesController.hunger < 10:
		spieciesController.hunger = 10


func rethinkLogic() -> void:
	if logicLocked:
		return
	# cleanup destroyed
	if enemyToFollow != null && !enemyToFollow.is_inside_tree():
		enemyToFollow = null
	if foodToFollow != null && !foodToFollow.is_inside_tree():
		foodToFollow = null
	if friendToFollow != null && !friendToFollow.is_inside_tree():
		friendToFollow = null
	# return to spawn if wandered too far
	if position.distance_squared_to(spawnPoint) > 65536:
		enemyToFollow = null
		foodToFollow = null
		friendToFollow = null
		currentLogic = logicReturnToSpawn
	# follow enemy
	elif enemyToFollow != null:
		currentLogic = logicAttackEnemy
	# follow food
	elif foodToFollow != null:
		currentLogic = logicFollowFood
	# follow friend
	elif friendToFollow != null:
		currentLogic = logicFollowFriend
	else:
		currentLogic = logicIdle
	return


# region logic


func logicIdle() -> void:
	logicBusy = true
	foodToFollow = null
	enemyToFollow = null
	friendToFollow = null
	# look for food
	for area in sightArea.get_overlapping_areas():
		if area is Food && (area as Food).isOnGround:
			# not interested in meat of my own spiecies
			if (area as Food).ownerSpiecies == spieciesController.familyGroupTag:
				continue
			foodToFollow = area
			logicBusy = false
			return
	# look for enemies
	for body in sightArea.get_overlapping_bodies():
		# non-ocelot agroes on player
		if body is Player && !spieciesController is Ocelot:
			enemyToFollow = body
			logicBusy = false
			return
		# ai beasts agro on other spiecies
		if (
			body is BeastAI
			&& (
				(body as BeastAI).spieciesController.familyGroupTag
				!= spieciesController.familyGroupTag
			)
		):
			enemyToFollow = body
			logicBusy = false
			return
	# sit
	if randf() > 0.3:
		direction = Vector2.ZERO
		shouldBeAbleToMove = false
		await Tools.wait(self, randf_range(0.5, 2.0))
	# follow friend
	elif randf() > 0.3:
		friendToFollow = findClosestFriend(4096.0)
		shouldBeAbleToMove = false
		await Tools.wait(self, randf_range(2, 5))
	# wander
	else:
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		spieciesController.virtual_lookAt(Vector2.ZERO)
		shouldBeAbleToMove = true
		await Tools.wait(self, randf_range(0.2, 0.8))
	logicBusy = false
	return


func logicFollowFriend() -> void:
	if friendToFollow != null:
		spieciesController.virtual_lookAt(friendToFollow.position - position)
		var dist = position.distance_squared_to(friendToFollow.position)
		if dist > 4096:
			direction = (friendToFollow.position - position).normalized()
			shouldBeAbleToMove = true
		else:
			direction = Vector2.ZERO
	else:
		spieciesController.virtual_lookAt(Vector2.ZERO)
	return


func logicFollowFood() -> void:
	if foodToFollow != null:
		spieciesController.virtual_lookAt(foodToFollow.position - position)
		direction = (foodToFollow.position - position).normalized()
		shouldBeAbleToMove = true
	else:
		spieciesController.virtual_lookAt(Vector2.ZERO)
		foodToFollow = null
	return


func logicAttackEnemy() -> void:
	if enemyToFollow != null:
		spieciesController.virtual_lookAt(enemyToFollow.position - position)
		var dist = position.distance_squared_to(enemyToFollow.position)
		if dist > 4096:
			direction = (enemyToFollow.position - position).normalized()
			shouldBeAbleToMove = true
		else:
			direction = Vector2.ZERO
			spieciesController.virtual_attack((enemyToFollow.position - position).normalized())
	else:
		spieciesController.virtual_lookAt(Vector2.ZERO)
	return


func logicReturnToSpawn() -> void:
	if global_position.distance_squared_to(spawnPoint) > 1024:
		logicLocked = true
	else:
		logicLocked = false
	spieciesController.virtual_lookAt(spawnPoint - global_position)
	direction = (spawnPoint - global_position).normalized()
	shouldBeAbleToMove = true
	return


#endregion


func findClosestFriend(searchDistance: float) -> Node2D:
	var searchDistanceSquared = searchDistance * searchDistance
	var closestBeast: Node2D = null
	var closestDistance: float = 10000
	for beast in get_tree().get_nodes_in_group(spieciesController.familyGroupTag):
		if beast == self:
			continue
		var dist = position.distance_squared_to(beast.position)
		if dist > searchDistanceSquared:
			continue
		if closestDistance > dist:
			closestDistance = dist
			closestBeast = beast
	return closestBeast


func onHit(damage: float, attacker) -> void:
	if enemyToFollow == null && attacker != null:
		if (
			attacker is Player
			|| (
				attacker is BeastAI
				&& (
					(attacker as BeastAI).spieciesController.familyGroupTag
					!= spieciesController.familyGroupTag
				)
			)
		):
			enemyToFollow = attacker
	spieciesController.health -= damage
	spieciesController.virtual_showEmotion(Spiecies.Emotion.Cry)
	if spieciesController.health <= 0:
		var fxTscn = preload("res://objects/fx/RedBig.tscn")
		var fx = fxTscn.instantiate()
		var root = Tools.getRoot(self)
		root.add_child(fx)
		fx.global_position = self.global_position
		Tools.playSound(self, "Death", Tools.sizeToPitch(spieciesController.size))
		var meatTscn = load(
			"res://objects/collectables/meat/%s.tscn" % spieciesController.familyGroupTag
		)
		var meatCount = roundi(spieciesController.size / 0.1725)
		for i in range(meatCount):
			var meat = meatTscn.instantiate()
			root.add_child(meat)
			meat.global_position = global_position
			meat.call_deferred("notCollectableYet")
			meat.call_deferred("dropFromBody")
			pass
		call_deferred("queue_free")
	else:
		var fxTscn = preload("res://objects/fx/RedSmall.tscn")
		var fx = fxTscn.instantiate()
		Tools.getRoot(self).add_child(fx)
		fx.global_position = self.global_position
		modulate = Color(1, 0, 0, 1)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)
		Tools.playSound(self, "Thump", Tools.sizeToPitch(spieciesController.size))
	return


func eatFood(nutrition: int) -> void:
	spieciesController.hunger = spieciesController.hunger + nutrition
	foodToFollow = null
	return
