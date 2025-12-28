extends "res://Graphic Elements/popups/my_popup_button.gd"

var placeholderSprite = preload("res://Images/PlaceholderCharacterGraphic.jpg")

func initialise(smallEntry : Node) :
	## Add pic later
	getSpriteRef().texture = smallEntry.myEnemy.portrait
	getTitleRef().text = smallEntry.myEnemy.getName()
	getTagContainer().setEnemy(smallEntry.getEnemy())
	#getHBOX().get_node("Star").visible = smallEntry.get_node("Star").visible
	var killCount = smallEntry.killCount
	#getHBOX().get_node("Skull").visible = smallEntry.get_node("Skull").visible
	var description : String = ""
	description += "\tBase Stats:\n"
	var baseEnemy = smallEntry.getEnemy().getAdjustedCopy(1)
	for key in Definitions.baseStatDictionary.keys() :
		description += Definitions.baseStatDictionary[key] + ": " + str(Helpers.myRound(baseEnemy.getStat(key),3)) + "\n"
	description += "Attack - "
	var attack = smallEntry.getEnemy().actions[0]
	description += attack.getName() + "\n"
	if (attack is AttackAction) :
		description += "\t\tType: " + Definitions.damageTypeDictionary[attack.getDamageType()] + "\n"
		description += "\t\tPower: " + str(Helpers.myRound(attack.getPower(),3)) + "\n"
	description += "\t\tWarmup: " + str(Helpers.myRound(attack.getWarmup(),3)) + " seconds\n"
	description += "\nKilled: " + str(int(killCount)) + "\n\n"
	#description += "Drops\n"
	#if (smallEntry.myEnemy.drops.is_empty()) :
		#description += "\t-None-\n"
	#else :
		#for index in range(0,smallEntry.myEnemy.drops.size()) :
				### swap to item encyclopedia later???
				#var item = smallEntry.myEnemy.drops[index]
				#if (smallEntry.itemCollection[item.getItemName()]) :
					#description += EquipmentGroups.colourText(item.equipmentGroups.quality, item.getName(), true) + " - " + str(100*smallEntry.myEnemy.dropChances[index]) + "%\n"
				#else :
					#description += EquipmentGroups.colourText(item.equipmentGroups.quality, "??? (" + Definitions.equipmentTypeDictionary[item.type] + ")", true) + " - " + str(100*smallEntry.myEnemy.dropChances[index]) + "%\n"
	description += "\n"
	description += smallEntry.myEnemy.getDesc()
	setText(description)
	
func getTitleRef() :
	return $Panel/CenterContainer/Window/ScrollContainer/VBoxContainer/Title
func getSpriteRef() :
	return $Panel/CenterContainer/Window/ScrollContainer/VBoxContainer/Art
func getHBOX() :
	return $Panel/CenterContainer/Window/ScrollContainer/VBoxContainer/HBoxContainer
func getTagContainer() :
	return $Panel/CenterContainer/Window/ScrollContainer/VBoxContainer/TagContainerEnemy
	
var myReady
signal myReadySignal
func _ready() :
	var myWindow = $Panel/CenterContainer/Window
	var myContainer : ScrollContainer = myWindow.get_node("ScrollContainer")
	var myVBox = myWindow.get_node("VBoxContainer")
	myWindow.remove_child(myVBox)
	myContainer.add_child(myVBox)
	myVBox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	myVBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	myReady = true
	emit_signal("myReadySignal")
