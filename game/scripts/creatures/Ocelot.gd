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


func _ready() -> void:
	playBodyIdle()
	headAP.play("forward")
	eyesAP.play("normal")
	# mouthAP.play("todo")
	return


func process(body: CharacterBody2D, delta: float, direction: Vector2) -> void:
	# input
	if direction:
		lastInputCooldown = 0.5
		directionSnapshot = direction
		hasInput = true
		# if there is an input you can start movement
		bodyAP.play("move")
		# accelerate animation speed
		bodyAP.speed_scale = move_toward(bodyAP.speed_scale, 2.5, delta)
	else:
		# when input is lost you can stop only if not mid-jump
		hasInput = false
		if !isJumping:
			playBodyIdle()
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

	return


func playBodyIdle() -> void:
	if bodyAP.speed_scale == 1.0:
		bodyAP.play("sit")
	else:
		bodyAP.play("stand")
	return


func move_jump_start() -> void:
	speedBurst = 2.5
	isJumping = true
	return


func move_jump_end() -> void:
	isJumping = false
	if !hasInput:
		playBodyIdle()
	return


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
