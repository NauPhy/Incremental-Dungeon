@tool
extends Panel

@export var myScale : float : 
	set(val) :
		hiddenScale = val
		for child in get_children() :
			if (child is Sprite2D) :
				if (child.name == "Cat") :
					child.scale = Vector2(val/2,val/2)
				else :
					child.scale = Vector2(val,val)
	get() :
		return hiddenScale

var hiddenScale : float = 16.0

func _ready() :
	const baseWidth = 32*16
	const catWidth = 32*8
	var basePos = size/2
	var catPos = Vector2(0,0)
	catPos.x = basePos.x + 20*hiddenScale
	catPos.y = basePos.y + catWidth/2
	var overlap = -((catPos.x-basePos.x)-baseWidth/2-catWidth/2)
	var totalWidth = baseWidth+catWidth-overlap
	var middleOffset = totalWidth/2-baseWidth/2
	var middlePos = size/2
	basePos = middlePos
	basePos.x -= middleOffset
	catPos.x = basePos.x + 20*hiddenScale
	for child in get_children() :
		if (child.name == "Cat") :
			child.position = catPos
		else :
			child.position = basePos

func setTexture(myName : String, texture : Texture2D) :
	var node = get_node(myName)
	if (node != null) :
		node.texture = texture

func _on_check_box_toggled(toggled_on: bool) -> void:
	$Head.visible = !toggled_on
