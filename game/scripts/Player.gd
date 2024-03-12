extends CharacterBody2D
class_name Player

@onready var spieciesController: Spiecies = $SpieciesController

# func _ready() -> void:
# 	return


func prepare(playerTexture: Texture2D) -> void:
	# groups
	name = "Player"
	remove_from_group("ocelot")
	add_to_group("player")
	spieciesController.set_deferred("familyGroupTag", "player")
	# stats
	spieciesController.mainBody = self
	spieciesController.setSize(0.5)
	spieciesController.health = spieciesController.maxHealth * 0.45
	spieciesController.hunger = 50
	spieciesController.updateFace()
	# audio listener
	var audioListener: AudioListener2D = (
		preload("res://objects/audio/AudioListener.tscn").instantiate()
	)
	add_child(audioListener)
	audioListener.make_current()
	# texture
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
	var nutriMulti: float = 1.0
	if Global.sneksquikDefeated:
		nutriMulti = 2.0
	spieciesController.hunger = spieciesController.hunger + roundi(nutrition * nutriMulti)
	return


func onHit(damage: float, _attacker) -> void:
	if Global.boarisDefeated:
		spieciesController.health -= damage * 0.5
	else:
		spieciesController.health -= damage
	spieciesController.virtual_showEmotion(Spiecies.Emotion.Cry)
	if spieciesController.health <= 0:
		var fxTscn = preload("res://objects/fx/RedBig.tscn")
		var fx = fxTscn.instantiate()
		Tools.getRoot(self).add_child(fx)
		fx.global_position = self.global_position
		queue_free()
		Tools.playSound(self, "Death", Tools.sizeToPitch(spieciesController.size))
		Global.die()
	else:
		var fxTscn = preload("res://objects/fx/RedSmall.tscn")
		var fx = fxTscn.instantiate()
		Tools.getRoot(self).add_child(fx)
		fx.global_position = self.global_position
		modulate = Color(1, 0, 0, 1)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)
		Tools.playSound(self, "Thump", Tools.sizeToPitch(spieciesController.size))
	return
