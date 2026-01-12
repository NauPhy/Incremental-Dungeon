extends "res://Screens/IntroScreen/portrait.gd"

func _ready() :
	applyScale()
	for child in get_children() :
		child.position = Vector2(0,0)
