extends CharacterBody2D
class_name Player

@onready var speciesController: Species = $SpeciesController

# func _ready() -> void:
# 	return


func prepare(playerTexture: Texture2D) -> void:
	# groups
	name = "Player"
	remove_from_group("ocelot")
	add_to_group("player")
	speciesController.set_deferred("familyGroupTag", "player")
	# stats
	speciesController.mainBody = self
	speciesController.setSize(0.5)
	speciesController.health = speciesController.maxHealth * 0.45
	speciesController.hunger = 50
	speciesController.updateFace()
	# audio listener
	var audioListener: AudioListener2D = (
		preload("res://objects/audio/AudioListener.tscn").instantiate()
	)
	add_child(audioListener)
	audioListener.make_current()
	# texture
	Tools.replaceTextureInChildren(self, playerTexture)
	await Tools.wait(self, 2.0)
	speciesController.virtual_showEmotion(Species.Emotion.Sad)
	return


func _physics_process(delta: float) -> void:
	var mouseVec = (get_global_mouse_position() - global_position).normalized()
	speciesController.virtual_lookAt(mouseVec)
	var direction = Input.get_vector("left", "right", "up", "down")
	speciesController.virtual_process(self, delta, direction)
	if Input.is_action_pressed("attack"):
		speciesController.virtual_attack(mouseVec)
		speciesController.attackVector = mouseVec
	return


func eatFood(nutrition: int) -> void:
	var nutriMulti: float = 1.0
	if Global.sneksquikDefeated:
		nutriMulti = 2.0
	speciesController.hunger = speciesController.hunger + roundi(nutrition * nutriMulti)
	return


func onHit(damage: float, _attacker) -> void:
	if Global.boarisDefeated:
		speciesController.health -= damage * 0.5
	else:
		speciesController.health -= damage
	speciesController.virtual_showEmotion(Species.Emotion.Cry)
	if speciesController.health <= 0:
		var fxTscn = preload("res://objects/fx/RedBig.tscn")
		var fx = fxTscn.instantiate()
		Tools.getRoot(self).add_child(fx)
		fx.global_position = self.global_position
		queue_free()
		Tools.playSound(self, "Death", Tools.sizeToPitch(speciesController.size))
		Global.die()
	else:
		var fxTscn = preload("res://objects/fx/RedSmall.tscn")
		var fx = fxTscn.instantiate()
		Tools.getRoot(self).add_child(fx)
		fx.global_position = self.global_position
		modulate = Color(1, 0, 0, 1)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)
		Tools.playSound(self, "Thump", Tools.sizeToPitch(speciesController.size))
	return
