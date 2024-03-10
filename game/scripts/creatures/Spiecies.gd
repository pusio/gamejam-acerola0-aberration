extends Node2D
class_name Spiecies

@export var particleAttachmentPoint: Node2D

enum Emotion { Normal, Sad, Mad, Cry }

var hunger: int = 100
var health: float
var maxHealth: float
var maxHealthUnscaled: float
var familyGroupTag: String
var mainBody: CharacterBody2D
var size: float


func virtual_process(_body: CharacterBody2D, _delta: float, _direction: Vector2) -> void:
	return


func attachParticle(particleTscn: Resource):
	var particle = particleTscn.instantiate()
	particleAttachmentPoint.add_child(particle)
	particle.position = Vector2.ZERO
	return


func virtual_attack(_vector: Vector2) -> void:
	return


func virtual_showEmotion(_emotion: Emotion) -> void:
	return


func virtual_lookAt(_vector: Vector2) -> void:
	return


func setSize(s: float) -> void:
	size = s
	maxHealth = maxHealthUnscaled * s
	virtual_onSetSize()
	return


func virtual_onSetSize() -> void:
	return
