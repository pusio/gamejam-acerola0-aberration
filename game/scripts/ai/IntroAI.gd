extends CharacterBody2D

@onready var speciesController: Species = $SpeciesController

@export var size: float
@export var playerTexture: Texture2D
@export var canMove: bool
@export var isBoss: bool

var lookAt: Vector2
var direction: Vector2

var myTarget: Node2D
var em: int = 0


func _ready() -> void:
	if isBoss:
		Tools.replaceTextureInChildren(self, speciesController.bossTexture)
	speciesController.updateFace()
	speciesController.mainBody = self
	speciesController.setSize(size)
	myTarget = get_parent().get_node(name + "Target")
	call_deferred("recalculateStats")
	return


func recalculateStats() -> void:
	speciesController.hunger = randi_range(50, 500)
	speciesController.health = randf_range(0.8, 1.0) * speciesController.maxHealth
	return


func _physics_process(delta: float) -> void:
	speciesController.virtual_process(self, delta, direction)
	speciesController.virtual_lookAt(lookAt)
	aiCheats()
	followTarget()
	if em == 1:
		speciesController.virtual_showEmotion(Species.Emotion.Mad)
	if em == 2:
		speciesController.virtual_showEmotion(Species.Emotion.Sad)
	return


func aiCheats() -> void:
	speciesController.hunger = 100
	return


func followTarget() -> void:
	speciesController.virtual_lookAt(myTarget.position - position)

	if canMove:
		var dist = position.distance_squared_to(myTarget.position)
		if dist > 1024:
			direction = (myTarget.position - position).normalized()
		else:
			direction = Vector2.ZERO
	return


func anim_playMad() -> void:
	em = 1
	return


func anim_playSad() -> void:
	em = 2
	return


func anim_turnPlayer() -> void:
	Tools.playSound(self, "Magic", 2.0)
	var mag: Sprite2D = $EvilMagic
	mag.visible = true
	mag.modulate = Color(1.0, 1.0, 1.0, 0.0)
	mag.scale = Vector2(1.0, 1.0)
	var m_tween = create_tween()
	m_tween.tween_property(mag, "scale", Vector2(5.0, 5.0), 0.3)
	m_tween.parallel()
	m_tween.tween_property(mag, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)
	m_tween.tween_interval(1.5)
	m_tween.tween_property(mag, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.0)
	create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).tween_property(
		mag, "rotation_degrees", 360 * 5, 4.0
	)
	await Tools.wait(self, 4.0)
	Tools.playSound(self, "Mutate", 1.0)
	var sprite: Sprite2D = $Thunder
	sprite.visible = true
	var tween = create_tween()
	sprite.scale = Vector2(5.0, 5.0)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.3)
	tween.parallel()
	sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.3)
	await Tools.wait(self, 0.1)
	speciesController.attachParticle(preload("res://objects/fx/MagicSpell-DeathLoop.tscn"))
	await Tools.wait(self, 0.5)
	Tools.replaceTextureInChildren(self, playerTexture)
	return


func anim_attack() -> void:
	speciesController.virtual_attack((myTarget.position - position).normalized())
	return
