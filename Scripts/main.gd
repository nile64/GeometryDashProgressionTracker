extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _open_credits_window():
	$UI/Panel/BorderTop/CreditsButton/CreditsWindow.show()
