extends Node
class_name Spiecies

@export var particleAttachmentPoint: Node2D


func process(_body: CharacterBody2D, _delta: float, _direction: Vector2) -> void:
	return


func attachParticle(particleTscn: Resource):
	var particle = particleTscn.instantiate()
	particleAttachmentPoint.add_child(particle)
	particle.position = Vector2.ZERO
	return
