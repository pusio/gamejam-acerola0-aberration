extends CharacterBody2D

@onready var spieciesController: Spiecies = $SpieciesController

@export var size: float
@export var playerTexture: Texture2D
@export var canMove: bool

var lookAt: Vector2
var direction: Vector2

var myTarget: Node2D
var em: int = 0

func _ready() -> void:
	spieciesController.updateFace()
	spieciesController.mainBody = self
	spieciesController.setSize(size)
	myTarget = get_parent().get_node(name + "Target")
	call_deferred("recalculateStats")
	return


func recalculateStats() -> void:
	spieciesController.hunger = randi_range(50, 500)
	spieciesController.health = randf_range(0.8, 1.0) * spieciesController.maxHealth
	return


func _physics_process(delta: float) -> void:
	spieciesController.virtual_process(self, delta, direction)
	spieciesController.virtual_lookAt(lookAt)
	aiCheats()
	followTarget()
	if em == 1:
		spieciesController.virtual_showEmotion(Spiecies.Emotion.Mad)
	if em == 2:
		spieciesController.virtual_showEmotion(Spiecies.Emotion.Sad)
	return


func aiCheats() -> void:
	spieciesController.hunger = 100


func followTarget() -> void:
	spieciesController.virtual_lookAt(myTarget.position - position)

	if canMove:
		var dist = position.distance_squared_to(myTarget.position)
		if dist > 1024:
			direction = (myTarget.position - position).normalized()
		else:
			direction = Vector2.ZERO



func anim_playMad() -> void:
	em = 1
	return


func anim_playSad() -> void:
	em = 2
	return

func anim_turnPlayer() -> void:
	spieciesController.attachParticle(preload("res://objects/fx/MagicSpell-DeathLoop.tscn"))
	await Tools.wait(self, 0.5)
	Tools.replaceTextureInChildren(self, playerTexture)
	return

func anim_attack() -> void:
	spieciesController.virtual_attack((myTarget.position - position).normalized())