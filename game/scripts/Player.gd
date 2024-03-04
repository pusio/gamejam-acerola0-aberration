extends CharacterBody2D
class_name Player

@onready var spieciesController: Spiecies = $SpieciesController

# func _ready()->void:
# 	spieciesController.attachParticle(preload("res://objects/fx/MagicSpell-DeathLoop.tscn"))
# 	return


func prepare(playerTexture: Texture2D) -> void:
	name = "Player"
	# add_to_group("player")
	await get_tree().create_timer(1.0).timeout
	spieciesController.attachParticle(preload("res://objects/fx/MagicSpell-DeathLoop.tscn"))
	await get_tree().create_timer(0.5).timeout
	Tools.replaceTextureInChildren(self, playerTexture)
	return


func _physics_process(delta: float) -> void:
	var mouseVec = Tools.getRelativeMousePosition(self)
	spieciesController.lookAt(mouseVec)
	var direction = Input.get_vector("left", "right", "up", "down")
	spieciesController.process(self, delta, direction)
	if Input.is_action_pressed("attack"):
		spieciesController.attack(mouseVec)
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
