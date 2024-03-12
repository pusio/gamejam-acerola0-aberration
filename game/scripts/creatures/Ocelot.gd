extends Spiecies
class_name Ocelot

@onready var bodyAP: AnimationPlayer = $"../BodyAnimationPlayer"
@onready var headAP: AnimationPlayer = $"../HeadAnimationPlayer"
@onready var eyesAP: AnimationPlayer = $"../EyesAnimationPlayer"
@onready var mouthAP: AnimationPlayer = $"../MouthAnimationPlayer"
@onready var origin: Node2D = $"../Origin"
@onready var anchor: Node2D = $"../Origin/Anchor"
@onready var headScaler: Node2D = $"../Origin/Anchor/Body/HeadScaler"
@onready var collisionShape2D: CollisionShape2D = $"../CollisionShape2D"

var movementSpeed: float = 50.0
var speedBurst: float = 1.0
var hasInput: bool = false
var isJumping: bool = false
var directionSnapshot: Vector2 = Vector2.ZERO
var rotationSnapshot: float = 0.0
var isAttacking: bool = false
var isEmoting: bool = false
var attackVector: Vector2
var hungerTick: float = 5
var isAttackOnCooldown: bool = false


func _init() -> void:
	spieciesScale = 1.0
	maxHealthUnscaled = 20.0
	familyGroupTag = "ocelot"
	return


func _ready() -> void:
	updateBodyAP()
	headAP.play("forward")
	updateFace()
	return


func virtual_process(body: CharacterBody2D, delta: float, direction: Vector2) -> void:
	# input
	if direction:
		directionSnapshot = direction
		hasInput = true
		# accelerate animation speed
		bodyAP.speed_scale = move_toward(bodyAP.speed_scale, 2.5, delta)
	else:
		# when input is lost you can stop only if not mid-jump
		hasInput = false
		if !isJumping:
			# decelerate animation speed
			bodyAP.speed_scale = move_toward(bodyAP.speed_scale, 1.0, delta * 0.5)

	# velocity
	if hasInput || isJumping:
		# during input or mid-jump apply velocity
		body.velocity = directionSnapshot * movementSpeed * speedBurst * size
	else:
		# otherwise stop
		body.velocity.x = move_toward(body.velocity.x, 0, movementSpeed * size)
		body.velocity.y = move_toward(body.velocity.y, 0, movementSpeed * size)

	# flip facing direction
	if directionSnapshot.x < 0.1:
		origin.scale.x = abs(origin.scale.x)
	elif directionSnapshot.x > -0.1:
		origin.scale.x = abs(origin.scale.x) * -1

	# rotate towards vertical movement
	if body.velocity && hasInput:
		rotationSnapshot = move_toward(
			rotationSnapshot, body.velocity.normalized().y * -25.0, delta * 200.0
		)
	if bodyAP.current_animation == "sit":
		rotationSnapshot = 0.0
	anchor.rotation_degrees = move_toward(
		anchor.rotation_degrees, rotationSnapshot, delta * 50.0 * bodyAP.speed_scale
	)

	# apply godot physics movement
	body.move_and_slide()

	# dissipate speed burst gained from jump
	speedBurst = move_toward(speedBurst, 0.1, delta)

	updateBodyAP()
	updateFace()
	updateHunger(delta)
	return


func updateBodyAP() -> void:
	if isAttacking:
		bodyAP.play("attack")
	elif hasInput || isJumping:
		bodyAP.play("move")
	elif bodyAP.speed_scale == 1.0:
		bodyAP.play("sit")
	else:
		bodyAP.play("stand")
	return


# triggered by animation
func move_jump_start() -> void:
	speedBurst = 2.5
	isJumping = true
	return


# triggered by animation
func move_jump_end() -> void:
	isJumping = false
	return


# triggered by animation
func attack_execute() -> void:
	call_deferred("spawnAttack")
	return


func spawnAttack() -> void:
	if health <= 0:
		return
	var atkTscn: PackedScene = preload("res://objects/projectiles/BasicAttack.tscn")
	var atk: AttackProjectile = atkTscn.instantiate()
	Tools.getRoot(self).add_child(atk)
	atk.prepare(
		attackVector,
		1,
		size,
		mainBody.velocity,
		mainBody,
		get_tree().get_nodes_in_group(familyGroupTag)
	)
	Tools.playSound(self, "Hit", Tools.sizeToPitch(size))
	return


# triggered by animation
func attack_end() -> void:
	isAttacking = false
	var attackCooldown: float = randf_range(0.3, 0.35)
	if mainBody is Player && Global.websterDefeated:
		attackCooldown = 0.0
	if attackCooldown > 0.0:
		await Tools.wait(self, attackCooldown)
	isAttackOnCooldown = false
	return


func virtual_attack(vector: Vector2) -> void:
	bodyAP.speed_scale = (bodyAP.speed_scale + 1.5) / 2.0
	if isAttackOnCooldown:
		return
	if !isAttacking:
		attackVector = vector
	isAttacking = true
	isAttackOnCooldown = true
	isJumping = false
	return


func virtual_lookAt(vector: Vector2) -> void:
	var anim = "forward"
	if abs(vector.x) > abs(vector.y):
		if vector.x * origin.scale.x < 0:
			anim = "forward"
		elif vector.x * origin.scale.x > 0:
			anim = "backward"
	elif vector.y > 0:
		anim = "down"
	elif vector.y < 0:
		anim = "up"
	headAP.play(anim)
	return


func virtual_showEmotion(emotion: Emotion) -> void:
	if isEmoting:
		return
	isEmoting = true
	match emotion:
		Emotion.Sad:
			eyesAP.play("sad")
			mouthAP.play("normal")
			await Tools.wait(self, 0.5)
			eyesAP.play("sad_half")
			await Tools.wait(self, 0.5)
			mouthAP.play("open")
			Tools.playSound(self, "Mew", Tools.sizeToPitch(size))
			await Tools.wait(self, 0.5)
			eyesAP.play("sad")
			await Tools.wait(self, 0.5)
		Emotion.Mad:
			eyesAP.play("mad")
			mouthAP.play("normal")
			await Tools.wait(self, randf_range(0.5, 1.0))
			mouthAP.play("open")
			Tools.playSound(self, "Mew", Tools.sizeToPitch(size))
			await Tools.wait(self, 0.5)
			mouthAP.play("normal")
			await Tools.wait(self, randf_range(0.5, 1.0))
			mouthAP.play("open")
			Tools.playSound(self, "Mew", Tools.sizeToPitch(size))
			await Tools.wait(self, 0.5)
			mouthAP.play("normal")
			await Tools.wait(self, randf_range(0.5, 1.0))
			mouthAP.play("open")
			Tools.playSound(self, "Mew", Tools.sizeToPitch(size))
			await Tools.wait(self, 0.5)
		Emotion.Cry:
			mouthAP.play("open")
			Tools.playSound(self, "Mew", Tools.sizeToPitch(size))
			await Tools.wait(self, randf_range(0.3, 0.5))
			mouthAP.play("normal")
			await Tools.wait(self, randf_range(0.5, 2.5))
	isEmoting = false
	return


func updateFace() -> void:
	if isEmoting:
		return
	var health100 = roundi(health / maxHealth * 100)
	var mood: int = floor((clampi(hunger, 0, 100) + health100) / 2.0)
	if hunger <= 20:
		mouthAP.play("open")
	elif mood >= 95 && !mainBody is Player:
		mouthAP.play("smile")
	else:
		mouthAP.play("normal")

	if health100 == 100:
		eyesAP.play("normal")
	elif health100 > 80:
		if mood >= 50 && !mainBody is Player:
			eyesAP.play("mad")
		else:
			eyesAP.play("normal")
	elif health100 >= 50:
		eyesAP.play("sad")
	elif health100 >= 25:
		eyesAP.play("sad_half")
	else:
		eyesAP.play("closed")
	return


func virtual_onSetSize() -> void:
	origin.scale.x = sign(origin.scale.x) * size * spieciesScale
	origin.scale.y = size * spieciesScale
	var headSize = Tools.bodySizeToHeadSize(size)
	headScaler.scale = Vector2(headSize, headSize)
	collisionShape2D.scale = Vector2(size, size)
	# print("%s body %.02f head %.02f" % [get_parent().name, size, headSize])
	return


func updateHunger(delta: float) -> void:
	hungerTick -= delta
	if hungerTick > 0:
		return
	hungerTick = randf_range(4.0, 8.0)
	# starving
	if hunger <= 0:
		hunger = 0
		mainBody.onHit(size, null)
	# hunger over time
	hunger -= 1
	# heal if well fed
	if hunger > 20 && health < maxHealth:
		hunger -= 1
		health = clamp(health + 0.05 * maxHealth, 0, maxHealth)
	# grow if well fed
	var maxGrowthSize = 1.0
	if mainBody is Player && Global.momoDefeated:
		maxGrowthSize = 2.0
	if hunger > 80 && size < maxGrowthSize:
		var growthValue = 0.015
		if mainBody is Player && Global.momoDefeated:
			growthValue *= 2
		setSize(clampf(size + growthValue, 0.5, maxGrowthSize))
		hunger -= 4
	# faster decay if overfed
	if hunger > 100:
		var overfedValue: float = 1 + 0.25 * (hunger - 100)
		hunger -= roundi(overfedValue)
		# player heals by overeating
		if mainBody is Player:
			var healCap = 0.1 * maxHealth
			var heal = clampf(overfedValue / 2.0, 0, healCap)
			health = clampf(health + heal, 0, maxHealth)
	return
