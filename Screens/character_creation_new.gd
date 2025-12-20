extends Control

const permittedBasePrefixes = ["deep_dwarf", "deep_elf", "demigod", "dwarf", "elf", "gnome", "human", "vampire"]

var permittedNames : Array[String] = []

func _ready() :
	setupCarousels(true)
	setupCarousels(false)
	setDefaultTextures()
	connectCarousels()
	setupLayout()
	
func setupCarousels(isBody : bool) :
	var children
	if (isBody) :
		children = $Carousels/VBoxContainer/Body.get_children()
	else :
		children = $Carousels/VBoxContainer/Clothes.get_children()
	for child in children :
		if (!(child is HBoxContainer)) :
			continue
		var type : String = child.name
		var count = 0
		if (type == "base") :
			count = setupBase(type)
		elif (type == "felids") :
			count = setupCat(type)
		else :
			count = setupOther(type)
		var tempOptions : Array[String] = []
		for index in range(0,count) :
			tempOptions.append(str(index))
		child.get_node("Carousel").setOptions(tempOptions)
	
func setupBase(type) -> int :
	var count = 0
	var values = MegaFile.getPlayerTextureDictionary(type).keys()
	for value in values :
		var permitted : bool = false
		for prefix in permittedBasePrefixes :
			if (value.find(prefix) != -1) :
				permitted = true
				break
		if (permitted) :
			permittedNames.append(value)
			count += 1
	return count
func setupCat(type) -> int :
	return MegaFile.getPlayerTextureDictionary(type).size()
func setupOther(type) -> int :
	return MegaFile.getPlayerTextureDictionary(type).size() + 1

func setDefaultTextures() :
	$Portrait/Base.texture = MegaFile.getPlayerTexture_base(permittedBasePrefixes[0]+"_female")
	for child in $Portrait.get_children() :
		if (child == $Portrait/Base || child == $Portrait/Cat) :
			pass
		else :
			child.texture = null

func connectCarousels() :
	for child in $Carousels/VBoxContainer/Body.get_children() :
		if !child.has_node("Carousel") : continue
		var carousel = child.get_node("Carousel")
		if (carousel != null) :
			carousel.connect("move", _on_carousel_move)
	for child in $Carousels/VBoxContainer/Clothes.get_children() :
		if !child.has_node("Carousel") : continue
		var carousel = child.get_node("Carousel")
		if (carousel != null) :
			carousel.connect("move", _on_carousel_move)
		
func _on_carousel_move(emitter : Node, currentPos, _currentOption) :
	var type : String = emitter.get_parent().name
	if (type == "base") :
		$Portrait/Base.texture = MegaFile.getPlayerTexture_base(permittedNames[currentPos])
	elif (type == "felids") :
		$Portrait/Cat.texture = MegaFile.getPlayerTextureDictionary(type).values()[currentPos]
	elif (currentPos == 0) :
		$Portrait.get_node(type).texture = null
	else :
		$Portrait.get_node(type).texture = MegaFile.getPlayerTextureDictionary(type).values()[currentPos-1]

func setupLayout() :
	var base = $Carousels/VBoxContainer/Body/base
	var children = $Carousels/VBoxContainer/Body.get_children()
	children.append_array($Carousels/VBoxContainer/Clothes.get_children())
	for child in children :
		if (!(child is HBoxContainer)) :
			continue
		if (child != base) :
			var newHome = base.get_node("TextureButton").duplicate()
			child.add_child(newHome)
			newHome.name = "TextureButton"
			var newButton = base.get_node("MyButton").duplicate()
			child.add_child(newButton)
			newButton.name = "MyButton"
			var newButton2 = base.get_node("MyButton2").duplicate()
			newButton2.name = "MyButton2"
			child.add_child(newButton2)
			child.move_child(newHome, 1)
			child.move_child(newButton,2)
			child.move_child(newButton2, 3)
		child.get_node("TextureButton").connect("myPressed",_on_home_pressed)
		child.get_node("MyButton").connect("myPressed", _on_button_pressed)
		child.get_node("MyButton2").connect("myPressed", _on_button2_pressed)

func _on_home_pressed(emitter : Node) :
	emitter.get_parent().get_node("Carousel").setPositionWithSignal(0, false)
func _on_button_pressed(emitter : Node) :
	emitter.get_parent().get_node("Carousel").setPositionWithSignal(-10, true)
func _on_button2_pressed(emitter : Node) :
	emitter.get_parent().get_node("Carousel").setPositionWithSignal(10,true)
