extends CharacterBody2D
class_name Player

@onready var spieciesController: Spiecies = $SpieciesController


func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	spieciesController.process(self, delta, direction)
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
