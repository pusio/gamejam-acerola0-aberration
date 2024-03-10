extends RigidBody2D
class_name Destroyable

@export var maxHealth: Array[int]
var currentHealth: int
var currentHealthId: int


func _ready() -> void:
	currentHealthId = 0
	if maxHealth.size() <= currentHealthId:
		currentHealth = 1
	else:
		currentHealth = maxHealth[currentHealthId]
	virtual_onReady()
	return


func virtual_onReady() -> void:
	return


func onHit(damage: int, _attacker: Node2D) -> void:
	currentHealth -= damage
	virtual_onDamage()
	if currentHealth > 0:
		return
	currentHealthId += 1
	if maxHealth.size() <= currentHealthId:
		virtual_onDestroy()
		call_deferred("queue_free")
		return
	currentHealth = maxHealth[currentHealthId]
	virtual_onNextStage()
	return


func virtual_onDamage() -> void:
	print("on damage")
	return


func virtual_onDestroy() -> void:
	print("on destroy")
	return


func virtual_onNextStage() -> void:
	print("on next stage")
	return
