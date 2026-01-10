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
		children = $Carousels/Body/PanelContainer/VBoxContainer.get_children()
	else :
		children = $Carousels/Clothes/PanelContainer/VBoxContainer.get_children()
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
	var values = MegaFile.getPlayerTextureDictionary("PlayerTexture_" + type).keys()
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
	return MegaFile.getPlayerTextureDictionary("PlayerTexture_" + type).size()
func setupOther(type) -> int :
	return MegaFile.getPlayerTextureDictionary("PlayerTexture_" + type).size() + 1

func setDefaultTextures() :
	$Portrait.setTexture("Base", MegaFile.getPlayerTexture_base(permittedBasePrefixes[0]+"_female"), permittedBasePrefixes[0]+"_female")
	for child in $Portrait.get_children() :
		if (child == $Portrait/Base || child == $Portrait/Cat) :
			pass
		else :
			child.texture = null

func connectCarousels() :
	for child in $Carousels/Body/PanelContainer/VBoxContainer.get_children() :
		if !child.has_node("Carousel") : continue
		var carousel = child.get_node("Carousel")
		if (carousel != null) :
			carousel.connect("move", _on_carousel_move)
	for child in $Carousels/Clothes/PanelContainer/VBoxContainer.get_children() :
		if !child.has_node("Carousel") : continue
		var carousel = child.get_node("Carousel")
		if (carousel != null) :
			carousel.connect("move", _on_carousel_move)
		
func _on_carousel_move(emitter : Node, currentPos, _currentOption) :
	var type : String = emitter.get_parent().name
	if (type == "base") :
		$Portrait.setTexture("Base", MegaFile.getPlayerTexture_base(permittedNames[currentPos]), permittedNames[currentPos])
	elif (type == "felids") :
		$Portrait.setTexture("Cat", MegaFile.getPlayerTextureDictionary("PlayerTexture_" + type).values()[currentPos], MegaFile.getPlayerTextureDictionary("PlayerTexture_"+type).keys()[currentPos])
	elif (currentPos == 0) :
		$Portrait.setTexture(type, null, "null")
	else :
		$Portrait.setTexture(type, MegaFile.getPlayerTextureDictionary("PlayerTexture_" + type).values()[currentPos-1], MegaFile.getPlayerTextureDictionary("PlayerTexture_"+type).keys()[currentPos-1])

func setupLayout() :
	var base = $Carousels/Body/PanelContainer/VBoxContainer/base
	var children = $Carousels/Body/PanelContainer/VBoxContainer.get_children()
	children.append_array($Carousels/Clothes/PanelContainer/VBoxContainer.get_children())
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
	
signal characterDone
const popup = preload("res://Graphic Elements/popups/binary_decision.tscn")
func _on_my_button_pressed() -> void:
	var tempPop = popup.instantiate()
	add_child(tempPop)
	tempPop.setTitle("Are you sure?")
	tempPop.setText("Is this your true self?")
	tempPop.connect("binaryChosen", _on_binary_chosen)
func _on_binary_chosen(chosen : int) :
	if (chosen == 0) :
		var myClass = $CharacterCreator/VBoxContainer2/StatDescription.currentStats
		var myName = $VBoxContainer/LineEdit.text
		if (myName == "") :
			myName = " "
		var myCharacter : CharacterPacket = CharacterPacket.new()
		myCharacter.setClass(myClass)
		myCharacter.setName(myName)
		myCharacter.setPortraitExtraSafe($Portrait)
		emit_signal("characterDone", myCharacter)
	elif (chosen == 1) :
		return
