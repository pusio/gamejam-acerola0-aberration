extends CharacterBody2D
class_name Player

@export var movementSpeed: float = 250.0


func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction * movementSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, movementSpeed)
		velocity.y = move_toward(velocity.x, 0, movementSpeed)
	move_and_slide()
	return


# returns true if collectable should delete itself from world
func collectable_touched(collectable: Collectable) -> bool:
	match collectable.type:
		Collectable.CollectableType.TestRed:
			print("touch red, lose hp")
		Collectable.CollectableType.TestBlue:
			print("touch blue, gain hp")
		_:
			return false  # unimplemented, don't remove
	return true
