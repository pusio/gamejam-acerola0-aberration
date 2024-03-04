extends CharacterBody2D
class_name Player

@onready var spieciesController: Spiecies = $SpieciesController

# func _ready()->void:
# 	spieciesController.attachParticle(preload("res://objects/fx/MagicSpell-DeathLoop.tscn"))
# 	return


func _physics_process(delta: float) -> void:
	spieciesController.lookAt(Tools.getRelativeMousePosition(self))
	var direction = Input.get_vector("left", "right", "up", "down")
	spieciesController.process(self, delta, direction)
	# tmp particle test
	if Input.is_action_just_pressed("ui_accept"):
		spieciesController.attachParticle(preload("res://objects/fx/MagicSpell-DeathLoop.tscn"))
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
