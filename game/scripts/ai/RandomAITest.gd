extends CharacterBody2D

@onready var spieciesController: Spiecies = $SpieciesController

var decisionCooldown: float
var direction: Vector2 = Vector2.ZERO
var followTarget: Node2D = null


func _ready() -> void:
	decisionCooldown = randf_range(0.5, 2.0)
	return


func _physics_process(delta: float) -> void:
	if followTarget != null:
		var dist = position.distance_squared_to(followTarget.position)
		if dist > 64 * 64:
			direction = (followTarget.position - position).normalized()
		else:
			direction = Vector2.ZERO
	spieciesController.process(self, delta, direction)
	decisionCooldown -= delta
	if decisionCooldown > 0:
		return
	decisionCooldown = randf_range(0.5, 2.0)
	followTarget = null
	if randf() > 0.3:
		direction = Vector2.ZERO
		return
	if randf() > 0.3:
		followTarget = findClosestBeast(6400.0)
		if followTarget != null:
			decisionCooldown *= 10
			print(self.name + " follows " + followTarget.name)
			return
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	return


func findClosestBeast(searchDistance: float) -> Node2D:
	var searchDistanceSquared = searchDistance * searchDistance
	var closestBeast: Node2D = null
	var closestDistance: float = 99999
	for beast in get_tree().get_nodes_in_group("beast"):
		if beast == self:
			continue
		var dist = position.distance_squared_to(beast.position)
		if dist > searchDistanceSquared:
			continue
		if closestDistance > dist:
			closestDistance = dist
			closestBeast = beast
	return closestBeast
