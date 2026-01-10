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
const margin = 10

func _ready() :
	var baseWidth = 32*$Base.scale.x
	var catWidth = 32*$Cat.scale.x
	var basePos = Vector2(0,0)
	var catPos = Vector2(0,0)
	catPos.x = basePos.x + baseWidth*(3.0/4.0)
	#catPos.x = basePos.x + 20*hiddenScale
	catPos.y = basePos.y + baseWidth - catWidth
	#var overlap = -((catPos.x-basePos.x)-baseWidth/2-catWidth/2)
	#var totalWidth = baseWidth+catWidth-overlap
	#var middleOffset = totalWidth/2-baseWidth/2
	#var middlePos = Vector2(0,0)
	#basePos = middlePos
	#basePos.x -= middleOffset
	#catPos.x = basePos.x + 20*hiddenScale + middleOffset
	for child in get_children() :
		if (child.name == "Cat") :
			child.position = catPos + Vector2(margin,margin)
		else :
			child.position = basePos + Vector2(margin,margin)
	custom_minimum_size = Vector2(catPos.x+catWidth-basePos.x+2*margin, baseWidth+2*margin)
	#custom_minimum_size.x = catPos.x-basePos.x+catWidth/2.0 + baseWidth/2.0

var textureNames : Dictionary
func setTexture(myName : String, texture : Texture2D, textureName : String) :
	var node = get_node(myName)
	if (node != null) :
		node.texture = texture
		textureNames[myName] = textureName
		


func _on_check_box_toggled(toggled_on: bool) -> void:
	$Head.visible = !toggled_on

func getSaveDictionary() -> Dictionary :
	var retVal : Dictionary
	retVal["scale"] = hiddenScale
	retVal["textures"] = textureNames
	return retVal
func onLoad(loadDict) :
	myScale = loadDict["scale"]
	textureNames = loadDict["textures"]
	for key in textureNames.keys() :
		setTexture(key, MegaFile.getPlayerTexture(textureNames[key]),textureNames[key])
	
