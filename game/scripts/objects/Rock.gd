extends Destroyable


@onready var rock: Sprite2D = $Rock
@onready var shadow: Sprite2D = $"-Shadow"
@onready var collisionShape: CollisionShape2D = $CollisionShape2D


func virtual_onReady() -> void:
	prepareVariants()
	return


# region: random flips and size
func prepareVariants() -> void:
	# scale
	var rndScale = randf_range(0.8, 1.4)
	rock.scale *= rndScale
	shadow.scale *= rndScale
	collisionShape.scale *= rndScale
	# flip
	if randi_range(0, 1) == 1:
		rock.scale.x *= -1
	return


# endregion

func virtual_onDamage() -> void:
	Tools.playSound(self, "Thump", randf_range(1.5, 2.0))
	rotation_degrees = randf_range(2.0, 5.0)
	if randi_range(0, 1) == 1:
		rotation_degrees *= -1
	create_tween().set_trans(Tween.TRANS_BOUNCE).tween_property(self, "rotation", 0, 0.1)
	var fxTscn = preload("res://objects/fx/GraySmall.tscn")
	var fx = fxTscn.instantiate()
	Tools.getRoot(self).add_child(fx)
	fx.global_position = rock.global_position
	return


func virtual_onDestroy() -> void:
	Tools.playSound(self, "Destroy", randf_range(0.7, 0.9))
	var fxTscn = preload("res://objects/fx/GrayBig.tscn")
	var fx = fxTscn.instantiate()
	Tools.getRoot(self).add_child(fx)
	fx.global_position = rock.global_position + rock.offset + rock.region_rect.size / 2
	return

