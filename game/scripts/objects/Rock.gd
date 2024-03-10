extends Destroyable


@onready var rock: Sprite2D = $Rock
@onready var shadow: Sprite2D = $"-Shadow"
@onready var collisionShape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
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

# when hit drop rocks, destroy this object
