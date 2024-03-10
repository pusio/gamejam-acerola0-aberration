extends CharacterBody2D
class_name Player

@onready var spieciesController: Spiecies = $SpieciesController

# func _ready() -> void:
# 	return


func prepare(playerTexture: Texture2D) -> void:
	name = "Player"
	remove_from_group("ocelot")
	add_to_group("player")
	spieciesController.set_deferred("familyGroupTag", "player")
	spieciesController.mainBody = self
	spieciesController.setSize(0.5)
	spieciesController.health = spieciesController.maxHealth * 0.45
	spieciesController.hunger = 50
	spieciesController.updateFace()
	spieciesController.attachParticle(preload("res://objects/fx/MagicSpell-DeathLoop.tscn"))
	Tools.replaceTextureInChildren(self, playerTexture)
	await Tools.wait(self, 2.0)
	spieciesController.virtual_showEmotion(Spiecies.Emotion.Sad)
	return


func _physics_process(delta: float) -> void:
	var mouseVec = Tools.getRelativeMousePosition(self)
	spieciesController.virtual_lookAt(mouseVec)
	var direction = Input.get_vector("left", "right", "up", "down")
	spieciesController.virtual_process(self, delta, direction)
	if Input.is_action_pressed("attack"):
		spieciesController.virtual_attack(mouseVec)
	return


func eatFood(nutrition: int) -> void:
	spieciesController.hunger = spieciesController.hunger + nutrition
	return


func onHit(damage: float, _attacker) -> void:
	print(name, "hit", damage)
	return
