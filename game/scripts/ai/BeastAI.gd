extends CharacterBody2D
class_name BeastAI

@export var isBoss: bool

@onready var speciesController: Species = $SpeciesController
@onready var sightArea: Area2D = $SightArea
@onready var navAgent: NavigationAgent2D = $NavAgent

var targetPosition: Vector2
var friendToFollow: Node2D = null
var enemyToFollow: Node2D = null
var foodToFollow: Node2D = null

var currentLogic: Callable
var logicBusy: bool
var logicLocked: bool
var spawnPoint: Vector2
var shouldBeAbleToMove: bool
var anger: float
var agroTime: float
var friendFollowTime: float
var navCooldown: float = 2


func _ready() -> void:
	speciesController.isBoss = isBoss
	speciesController.updateFace()
	speciesController.mainBody = self
	if isBoss:
		Tools.replaceTextureInChildren(self, speciesController.bossTexture)
		if speciesController is Ocelot:
			speciesController.setSize(2.0)
		else:
			speciesController.setSize(1.5)
	else:
		speciesController.setSize(randf_range(0.5, 1.0))

	currentLogic = logicIdle
	logicBusy = false
	spawnPoint = global_position
	targetPosition = spawnPoint
	call_deferred("recalculateStats")
	# wait for navigation map to fill
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)
	return


func recalculateStats() -> void:
	speciesController.hunger = randi_range(50, 500)
	speciesController.health = randf_range(0.8, 1.0) * speciesController.maxHealth
	return


func _physics_process(delta: float) -> void:
	if navCooldown > 0:
		navCooldown -= delta
		if navCooldown <= 0:
			navCooldown = 0.1
			navAgent.target_position = targetPosition
	var direction: Vector2 = Vector2.ZERO
	var navPos = navAgent.get_next_path_position()
	var distCheck = 64
	if foodToFollow != null:
		distCheck = 16
	if targetPosition.distance_squared_to(global_position) > distCheck:
		direction = to_local(navPos).normalized()
	speciesController.virtual_process(self, delta, direction)
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
							(collider as BeastAI).speciesController.familyGroupTag
							!= speciesController.familyGroupTag
						)
					)
				):
					anger += delta
		else:
			anger = 0.0
	else:
		anger = 0.0
	if anger >= 0.5:
		speciesController.virtual_attack((targetPosition - global_position).normalized())
	aiCheats()
	if agroTime > 0:
		agroTime -= delta
		if agroTime <= 0:
			enemyToFollow = null
	if friendFollowTime > 0:
		friendFollowTime -= delta
		if friendFollowTime <= 0:
			friendToFollow = null
	if !logicBusy:
		rethinkLogic()
		currentLogic.call()
	return


func aiCheats() -> void:
	# don't starve
	if speciesController.hunger < 10:
		speciesController.hunger = 10


func rethinkLogic() -> void:
	if logicLocked:
		return
	# cleanup destroyed enemies
	if enemyToFollow != null:
		if !enemyToFollow.is_inside_tree():
			enemyToFollow = null
		elif enemyToFollow is Player:
			if (enemyToFollow as Player).speciesController.health <= 0:
				enemyToFollow = null
		elif enemyToFollow is BeastAI:
			if (enemyToFollow as BeastAI).speciesController.health <= 0:
				enemyToFollow = null
	# cleanup destroyed food
	if foodToFollow != null:
		if !foodToFollow.is_inside_tree():
			foodToFollow = null
		elif foodToFollow is Food:
			if (foodToFollow as Food).isConsumed:
				foodToFollow = null
	# cleanup destroyed friends
	if friendToFollow != null:
		if !friendToFollow.is_inside_tree():
			friendToFollow = null
		elif friendToFollow is Player:
			if (friendToFollow as Player).speciesController.health <= 0:
				friendToFollow = null
		elif friendToFollow is BeastAI:
			if (friendToFollow as BeastAI).speciesController.health <= 0:
				friendToFollow = null
	# return to spawn if wandered too far
	if agroTime <= 0 && position.distance_squared_to(spawnPoint) > 4194304:
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
			# not interested in meat of my own species
			if (area as Food).ownerSpecies == speciesController.familyGroupTag:
				continue
			foodToFollow = area
			friendToFollow = null
			enemyToFollow = null
			logicBusy = false
			return
	# look for enemies
	for body in sightArea.get_overlapping_bodies():
		# non-ocelot agroes on player
		if body is Player && !speciesController is Ocelot:
			enemyToFollow = body
			logicBusy = false
			return
		# ai beasts agro on other species
		if (
			body is BeastAI
			&& (
				(body as BeastAI).speciesController.familyGroupTag
				!= speciesController.familyGroupTag
			)
		):
			enemyToFollow = body
			logicBusy = false
			return
	# sit
	if randf() > 0.3:
		targetPosition = global_position
		shouldBeAbleToMove = false
		await Tools.wait(self, randf_range(0.5, 2.0))
	# follow friend
	elif randf() > 0.3 && !isBoss:
		friendToFollow = findClosestFriend(4096.0)
		friendFollowTime = 10.0
		enemyToFollow = null
		foodToFollow = null
		shouldBeAbleToMove = false
		await Tools.wait(self, randf_range(2, 5))
	# wander
	elif !isBoss:
		targetPosition = global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		speciesController.virtual_lookAt(Vector2.ZERO)
		shouldBeAbleToMove = true
		await Tools.wait(self, randf_range(0.2, 0.8))
	logicBusy = false
	return


func logicFollowFriend() -> void:
	if friendToFollow != null:
		speciesController.virtual_lookAt(friendToFollow.position - position)
		var dist = position.distance_squared_to(friendToFollow.position)
		if dist > 4096:
			targetPosition = friendToFollow.global_position
			shouldBeAbleToMove = true
		else:
			targetPosition = global_position
	else:
		speciesController.virtual_lookAt(Vector2.ZERO)
	return


func logicFollowFood() -> void:
	if foodToFollow != null:
		speciesController.virtual_lookAt(foodToFollow.position - position)
		targetPosition = foodToFollow.global_position
		shouldBeAbleToMove = true
	else:
		speciesController.virtual_lookAt(Vector2.ZERO)
		foodToFollow = null
	return


func logicAttackEnemy() -> void:
	if enemyToFollow != null:
		speciesController.virtual_lookAt(enemyToFollow.position - position)
		var dist = position.distance_squared_to(enemyToFollow.position)
		if dist > 4096:
			targetPosition = enemyToFollow.global_position
			shouldBeAbleToMove = true
		else:
			targetPosition = global_position
			speciesController.virtual_attack((enemyToFollow.position - position).normalized())
	else:
		speciesController.virtual_lookAt(Vector2.ZERO)
	return


func logicReturnToSpawn() -> void:
	if global_position.distance_squared_to(spawnPoint) > 1024:
		logicLocked = true
	else:
		logicLocked = false
	speciesController.virtual_lookAt(spawnPoint - global_position)
	targetPosition = spawnPoint
	shouldBeAbleToMove = true
	return


#endregion


func findClosestFriend(searchDistance: float) -> Node2D:
	var searchDistanceSquared = searchDistance * searchDistance
	var closestBeast: Node2D = null
	var closestDistance: float = 10000
	for beast in get_tree().get_nodes_in_group(speciesController.familyGroupTag):
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
	if attacker != null:
		# get species controller
		var attackerSC = null
		var playerSizeNerf = 1.0
		if attacker is Player:
			attackerSC = (attacker as Player).speciesController
			# attacking player is less important than other ai
			playerSizeNerf = 0.1
		elif attacker is BeastAI:
			attackerSC = (attacker as BeastAI).speciesController
		# if attacker is from different family
		var shouldAggro = false
		if attackerSC != null && attackerSC.familyGroupTag != speciesController.familyGroupTag:
			agroTime = 10.0
			# always attack if there is no target
			if enemyToFollow == null:
				shouldAggro = true
			# attack bigger enemy first
			else:
				var enemySC = null
				if enemyToFollow is Player:
					enemySC = (enemyToFollow as Player).speciesController
				if enemyToFollow is BeastAI:
					enemySC = (enemyToFollow as BeastAI).speciesController
				if enemySC != null:
					if (
						attackerSC.size * attackerSC.speciesScale * playerSizeNerf
						> enemySC.size * enemySC.speciesScale
					):
						shouldAggro = true
		# aggro
		if shouldAggro:
			enemyToFollow = attacker
			friendToFollow = null
			foodToFollow = null
			speciesController.virtual_showEmotion(Species.Emotion.Mad)
	if isBoss && speciesController is Boar:
		speciesController.health -= damage * 0.5
	else:
		speciesController.health -= damage
	speciesController.virtual_showEmotion(Species.Emotion.Cry)
	if speciesController.health <= 0:
		if isBoss:
			var player: Player = Tools.getRoot(self).get_node("Player")
			if player != null:
				var evilFx: EvilMagic = preload("res://objects/fx/EvilMagic.tscn").instantiate()
				player.add_child(evilFx)
				evilFx.position = Vector2(-2, -2)
				evilFx.call_deferred("prepare", player)
			if speciesController is Ocelot:
				Global.momoDefeated = true
				Global.bossesKilledInThisLife += 1
				print("momo is dead")
			elif speciesController is Boar:
				Global.boarisDefeated = true
				Global.bossesKilledInThisLife += 1
				print("boaris is dead")
			elif speciesController is Spider:
				Global.websterDefeated = true
				Global.bossesKilledInThisLife += 1
				print("webster is dead")
			elif speciesController is Snake:
				Global.sneksquikDefeated = true
				Global.bossesKilledInThisLife += 1
				print("sneksquik is dead")
		if Global.bossesKilledInThisLife >= 4:
			Global.die(false, "Ending")
		var fxTscn = preload("res://objects/fx/RedBig.tscn")
		var fx = fxTscn.instantiate()
		var root = Tools.getRoot(self)
		root.add_child(fx)
		fx.global_position = self.global_position
		Tools.playSound(self, "Death", Tools.sizeToPitch(speciesController.size))
		var meatTscn = load(
			"res://objects/collectables/meat/%s.tscn" % speciesController.familyGroupTag
		)
		var meatCount = roundi(speciesController.size * speciesController.speciesScale / 0.2925)
		for i in range(meatCount):
			var meat = meatTscn.instantiate()
			root.add_child(meat)
			meat.global_position = global_position
			meat.call_deferred("notCollectableYet")
			meat.call_deferred(
				"dropFromBody", speciesController.size * speciesController.speciesScale
			)
		call_deferred("queue_free")
	else:
		var fxTscn = preload("res://objects/fx/RedSmall.tscn")
		var fx = fxTscn.instantiate()
		Tools.getRoot(self).add_child(fx)
		fx.global_position = self.global_position
		modulate = Color(1, 0, 0, 1)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)
		Tools.playSound(self, "Thump", Tools.sizeToPitch(speciesController.size))
	return


func eatFood(nutrition: int) -> void:
	speciesController.hunger = speciesController.hunger + nutrition
	foodToFollow = null
	return
