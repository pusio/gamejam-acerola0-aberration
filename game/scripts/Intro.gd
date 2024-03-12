extends AnimationPlayer

@export var playBtn: Button
@export var creditsBtn: Button
@export var helpBtn: Button
@export var backBtn: Button
@export var back2Btn: Button
@export var view1: Node2D
@export var view2: Node2D
@export var view3: Node2D
@export var canvas: CanvasLayer


func _ready() -> void:
	canvas.visible = true
	view1.visible = true
	view2.visible = false
	view3.visible = false
	playBtn.connect("pressed", onClickPlay)
	creditsBtn.connect("pressed", onClickCredits)
	helpBtn.connect("pressed", onClickHelp)
	backBtn.connect("pressed", onClickBack)
	back2Btn.connect("pressed", onClickBack)
	Global.toggle_fullscreen()
	return


func end() -> void:
	Global.die(false)
	return


func onClickPlay() -> void:
	Tools.playSound(Tools.getRoot(self), "Raise", 0.75)
	canvas.visible = false
	await Tools.wait(self, 5.0)
	play("intro")
	return


func onClickCredits() -> void:
	Tools.playSound(Tools.getRoot(self), "Raise")
	view1.visible = false
	view2.visible = true
	view3.visible = false
	return


func onClickHelp() -> void:
	Tools.playSound(Tools.getRoot(self), "Raise")
	view1.visible = false
	view2.visible = false
	view3.visible = true
	return


func onClickBack() -> void:
	Tools.playSound(Tools.getRoot(self), "Fall")
	view1.visible = true
	view2.visible = false
	view3.visible = false
	return
