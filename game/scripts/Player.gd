extends CharacterBody2D
class_name Player

@onready var spieciesController: Spiecies = $SpieciesController

# func _ready() -> void:
# 	return


func prepare(playerTexture: Texture2D) -> void:
	name = "Player"
	spieciesController.health = 100
	spieciesController.hunger = 80
	spieciesController.updateFace()
	# add_to_group("player")
	await Tools.wait(self, 1.0)
	spieciesController.attachParticle(preload("res://objects/fx/MagicSpell-DeathLoop.tscn"))
	await Tools.wait(self, 0.5)
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
	spieciesController.hunger = clampi(spieciesController.hunger + nutrition, 0, 100)
	return
