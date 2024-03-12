extends Sprite2D
class_name EvilMagic


func prepare(player: Player):
	Tools.playSound(self, "Magic", 2.0)
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	scale = Vector2(1.0, 1.0)
	var m_tween = create_tween()
	m_tween.tween_property(self, "scale", Vector2(5.0, 5.0), 0.3)
	m_tween.parallel()
	m_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)
	m_tween.tween_interval(1.5)
	m_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.0)
	create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).tween_property(
		self, "rotation_degrees", 360 * 5, 4.0
	)
	await Tools.wait(self, 4.0)
	if player.speciesController.health > 0:
		player.speciesController.attachParticle(
			preload("res://objects/fx/MagicSpell-DeathLoop.tscn")
		)
		Tools.playSound(self, "Mutate", 1.0)
		await Tools.wait(self, 1.0)
	call_deferred("queue_free")
	return
