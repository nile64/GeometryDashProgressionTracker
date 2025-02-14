extends Node2D

var colorStep = 0;
var colorStepSpeed = 0.1;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_change_bg_color(delta)

func _change_bg_color(delta):
	if colorStep >= 1:
		colorStep = 0
	
	colorStep += delta * colorStepSpeed
	
	modulate = Color.from_hsv(colorStep, 0.5, 1)
	
