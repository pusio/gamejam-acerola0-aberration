extends RigidBody2D
class_name Destroyable


func onHit(damage: int, attacker: Node2D) -> void:
	print("%s attacked %s for %s dmg" % [attacker.name, name, str(damage)])
	return

# shared logic with health
# and change of graphics
# and drops
