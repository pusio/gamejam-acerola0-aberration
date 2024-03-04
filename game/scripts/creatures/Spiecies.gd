extends Node2D
class_name Spiecies

@export var particleAttachmentPoint: Node2D

enum Emotion { Normal, Sad, Mad, Cry }

var hunger: int = 100
var health: int = 100


func process(_body: CharacterBody2D, _delta: float, _direction: Vector2) -> void:
	return


func attachParticle(particleTscn: Resource):
	var particle = particleTscn.instantiate()
	particleAttachmentPoint.add_child(particle)
	particle.position = Vector2.ZERO
	return


func attack(_vector: Vector2) -> void:
	return


func showEmotion(_emotion: Emotion) -> void:
	return
