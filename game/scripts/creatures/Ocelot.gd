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


func _ready() -> void:
	updateBodyAP()
	headAP.play("forward")
	eyesAP.play("normal")
	# mouthAP.play("todo")
	return


# executed by AI or player input
func process(body: CharacterBody2D, delta: float, direction: Vector2) -> void:
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
	print("kamehameha")
	return


# triggered by animation
func attack_end() -> void:
	isAttacking = false
	return


# executed by AI or player input
func attack(_vector: Vector2) -> void:
	isAttacking = true
	isJumping = false
	bodyAP.speed_scale = (bodyAP.speed_scale + 1.5) / 2.0
	return


# executed by AI or player input
func lookAt(vector: Vector2) -> void:
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
