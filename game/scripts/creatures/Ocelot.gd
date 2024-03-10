extends Spiecies

@onready var bodyAP: AnimationPlayer = $"../BodyAnimationPlayer"
@onready var headAP: AnimationPlayer = $"../HeadAnimationPlayer"
@onready var eyesAP: AnimationPlayer = $"../EyesAnimationPlayer"
@onready var mouthAP: AnimationPlayer = $"../MouthAnimationPlayer"
@onready var origin: Node2D = $"../Origin"
@onready var anchor: Node2D = $"../Origin/Anchor"
@export var movementSpeed: float = 50.0

var speedBurst: float = 1.0
var hasInput: bool = false
var isJumping: bool = false
var directionSnapshot: Vector2 = Vector2.ZERO
var rotationSnapshot: float = 0.0
var lastInputCooldown: float = 0.0
var isAttacking: bool = false
var isEmoting: bool = false
var attackVector: Vector2


func _ready() -> void:
	familyGroupTag = "ocelot"
	updateBodyAP()
	headAP.play("forward")
	updateFace()
	return


func virtual_process(body: CharacterBody2D, delta: float, direction: Vector2) -> void:
	# input
	if direction:
		lastInputCooldown = 0.5
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
		body.velocity = directionSnapshot * movementSpeed * speedBurst
	else:
		# otherwise stop
		body.velocity.x = move_toward(body.velocity.x, 0, movementSpeed)
		body.velocity.y = move_toward(body.velocity.y, 0, movementSpeed)

	# flip facing direction
	if directionSnapshot.x < 0:
		origin.scale.x = 1.0
	elif directionSnapshot.x > 0:
		origin.scale.x = -1.0

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
	var atkTscn: PackedScene = preload("res://objects/projectiles/BasicAttack.tscn")
	var atk: AttackProjectile = atkTscn.instantiate()
	Tools.getRoot(self).add_child(atk)
	atk.prepare(attackVector, 1, mainBody.velocity, mainBody, get_tree().get_nodes_in_group(familyGroupTag))
	return


# triggered by animation
func attack_end() -> void:
	isAttacking = false
	return


func virtual_attack(vector: Vector2) -> void:
	if !isAttacking:
		attackVector = vector
	isAttacking = true
	isJumping = false
	bodyAP.speed_scale = (bodyAP.speed_scale + 1.5) / 2.0
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
			await Tools.wait(self, 0.5)
			eyesAP.play("sad")
			await Tools.wait(self, 0.5)
	isEmoting = false
	return


func updateFace() -> void:
	if isEmoting:
		return
	var mood: int = floor((hunger + health) / 2.0)
	if hunger <= 20:
		mouthAP.play("open")
	elif mood >= 95:
		mouthAP.play("smile")
	else:
		mouthAP.play("normal")

	if health == 100:
		eyesAP.play("normal")
	elif health > 80:
		if mood >= 50:
			eyesAP.play("mad")
		else:
			eyesAP.play("normal")
	elif health >= 50:
		eyesAP.play("sad")
	elif health >= 25:
		eyesAP.play("sad_half")
	else:
		eyesAP.play("closed")

	$"../DebugLabel".text = (
		"Mood: %s\nHealth: %s\nHunger: %s\nEyes: %s\nFace: %s"
		% [mood, health, hunger, eyesAP.current_animation, mouthAP.current_animation]
	)
	return
