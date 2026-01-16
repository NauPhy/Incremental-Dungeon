extends Node

#func getTextWidth(rich_text_label: RichTextLabel, text: String) -> float:
	#var font: Font = rich_text_label.get_theme_font("normal_font") # or custom font
	#var font_size: int = rich_text_label.get_theme_font_size("normal_font_size")
	##return font.get_string_shape_size(text, font_size).x
	## Get the active TextServer
	#var ts := TextServerManager.get_primary_interface()
	#var test = RichTextLabel.new()
	#test.force_update_transform()
	## Create a text buffer and shape it
	#var buffer_rid := ts.create_shaped_text()
	#var arr : Array[RID]
	#arr.append(font.get_rid())
	#ts.shaped_text_add_string(buffer_rid, text, arr, font_size, {}, "")
	#ts.shaped_text_shape(buffer_rid)
#
	## Query the width
	#var width := ts.shaped_text_get_size(buffer_rid).x
#
	#ts.free_rid(buffer_rid)
	#return width

func childIsValid(parent : Node, path : Array[String]) :
	var current = parent
	for item in path :
		if (!current.has_node(NodePath(item))) :
			return false
		current = current.get_node(item)
	return true
	
func myOwnGoddamnSort(list : Array, swapAdjacent : Callable) :
	var finished : bool = false
	while (!finished) :
		finished = true
		for index in range(0,list.size()-1) :
			if (swapAdjacent.call(list[index], list[index+1])) :
				finished = false
				var temp = list[index]
				list[index] = list[index+1]
				list[index+1] = temp
				
func myOwnGoddamnSort_sortChildren(parent : Node, swapAdjacent : Callable) :
	var finished : bool = false
	var list = parent.get_children()
	while (!finished) :
		finished = true
		for index in range(0,list.size()-1) :
			if (swapAdjacent.call(list[index], list[index+1])) :
				finished = false
				parent.move_child(list[index+1],index)
				list = parent.get_children()
				
	
func getSecondsFromTimestamp(timestamp : String) -> int :
	return 3600*(int(timestamp[0]+timestamp[1]))+60*(int(timestamp[3]+timestamp[4]))+int(timestamp[6]+timestamp[7])

func getTimestampString(seconds : int) -> String :
	var tempStr : String = ""
	var hours : int = floor(seconds/3600.0)
	var minutes : int = floor((seconds-3600*hours)/60.0)
	var newSeconds : int = seconds-3600*hours-60*minutes
	if (hours == 0) :
		tempStr += "00:"
	elif (hours < 10) :
		tempStr += "0" + str(hours) + ":"
	else :
		tempStr += str(hours) + ":"
	if (minutes == 0) :
		tempStr += "00:"
	elif (minutes < 10) :
		tempStr += "0" + str(minutes) + ":"
	else :
		tempStr += str(minutes) + ":"
	if (newSeconds == 0) :
		tempStr += "00"
	elif (newSeconds < 10) :
		tempStr += "0" + str(newSeconds)
	else :
		tempStr += str(newSeconds)
	return tempStr

func appendToTimestamp(timestamp : String, seconds : int) -> String :
	var newSeconds = getSecondsFromTimestamp(timestamp) + seconds
	return getTimestampString(newSeconds)

#func standardiseTextArray(nodes : Array[Node]) :
	#var maxSize : int = 0
	#for item in nodes :
		#if (item is RichTextLabel) :
			#var size = getTextWidth(item, item.text)
			#if (size > maxSize) :
				#maxSize = size
	#for item in nodes :
		#if (item is RichTextLabel) :
			#item.custom_minimum_size = Vector2(maxSize, 0)

func getTextWidthWaitFrame(textBox, fontsize, myText) :
	if (textBox != null) :
		await get_tree().process_frame
		return textBox.size.x
	else :
		var offscreen = RichTextLabel.new()
		add_child(offscreen)
		setupTextLabel_internal(offscreen, fontsize, myText)
		await get_tree().process_frame
		var retValue = offscreen.size.x
		offscreen.queue_free()
		return retValue
		
func getTextWidthWaitFrameArray(fontsize, text : Array[String]) -> Array[float] :
	var childReferences : Array[RichTextLabel] = []
	for i in range(0,text.size()) :
		childReferences.append(RichTextLabel.new())
		add_child(childReferences.back())
		setupTextLabel_internal(childReferences.back(), fontsize, text[i])
	await get_tree().process_frame
	var retValue : Array[float] = []
	for i in range(0,text.size()) :
		retValue.append(childReferences[i].size.x)
	for textBox in childReferences :
		textBox.queue_free()
	return retValue
		
func getTextArrayMaxWidthWaitFrame(textBoxArray, fontsize, textArray) :
	if (textBoxArray == null && textArray.size() == 0) :
		return 0
	if (textBoxArray != null) :
		await get_tree().process_frame
		var maxSize = 0
		for item in textBoxArray :
			if (item.size.x > maxSize) :
				maxSize = item.size.x
		return maxSize
	else :
		var offscreenArray : Array[RichTextLabel]
		for index in range(0, textArray.size()) :
			var tempBox = RichTextLabel.new()
			add_child(tempBox)
			offscreenArray.append(tempBox)
			setupTextLabel_internal(tempBox, fontsize, textArray[index])
		await get_tree().process_frame
		var maxSize = 0
		for item in offscreenArray :
			if (item.size.x > maxSize) :
				maxSize = item.size.x
		for item in offscreenArray :
			item.queue_free()
		return maxSize
		
func formatToMaxSizeWaitFrame(textBoxes : Array[RichTextLabel]) :
	var maxSize = await getTextArrayMaxWidthWaitFrame(textBoxes, null, null)
	for item in textBoxes :
		item.custom_minimum_size = Vector2(maxSize, 0)
		
func setupTextLabel_internal(textLabel : RichTextLabel, fontsize, myText) :
	if (fontsize != null) :
		textLabel.add_theme_font_size_override("normal_font_size", fontsize)
	if (myText != null) :
		textLabel.text = myText
	textLabel.fit_content = true
	textLabel.scroll_active = false
	textLabel.autowrap_mode = TextServer.AUTOWRAP_OFF
	textLabel.global_position = Vector2(10000,0)

func getAllNodes() -> Array[Node] :
	#excludes root
	var tempArr : Array[Node] = []
	var root = get_tree().root
	for child in root.get_children() :
		if (child is Node) :
			getAllNodes_recursive(child, tempArr)
	return tempArr
	
func getAllNodes_recursive(node : Node, arr : Array[Node]) -> void :
	arr.append(node)
	for child in node.get_children() :
		if (child is Node) :
			getAllNodes_recursive(child, arr)

func getTopLayer() -> int :
	var nodes = getAllNodes()
	var maxLayer = 0
	for node in nodes :
		if (node is CanvasLayer) :
			if (node.layer > maxLayer) :
				maxLayer = node.layer
	return maxLayer
	
func equipmentIsDirectUpgrade(newEquip : Equipment, oldEquip : Equipment) -> bool :
	if (newEquip.getType() != oldEquip.getType()) :
		return false
	var eq1Elems = newEquip.equipmentGroups.getElements()
	var eq2Elems = oldEquip.equipmentGroups.getElements()
	for index in range(0,eq1Elems.size()) :
		if (eq1Elems[index] != eq2Elems[index]) :
			return false
	if (newEquip.getType() == Definitions.equipmentTypeEnum.weapon) :
		var temp1 = newEquip as Weapon
		var temp2 = oldEquip as Weapon
		if (!is_equal_approx(temp1.basicAttack.getPower(),temp2.basicAttack.getPower()) || !is_equal_approx(temp1.basicAttack.getWarmup(), temp2.basicAttack.getWarmup())) :
			return false
		if (temp1.attackBonus < temp2.attackBonus && !is_equal_approx(temp1.attackBonus,temp2.attackBonus)) :
			return false
		var t1Scalings = temp1.getScalingArray()
		var t2Scalings = temp2.getScalingArray()
		for index in range(0,t1Scalings.size()) :
			if (t1Scalings[index] < t2Scalings[index]) :
				return false
	elif (newEquip.getType() == Definitions.equipmentTypeEnum.armor) :
		var temp1 = newEquip as Armor
		var temp2 = oldEquip as Armor
		if (temp1.PHYSDEF < temp2.PHYSDEF && !is_equal_approx(temp1.PHYSDEF, temp2.PHYSDEF)) :
			return false
		if (temp1.MAGDEF < temp2.MAGDEF && !is_equal_approx(temp1.MAGDEF, temp2.MAGDEF)) :
			return false
	else :
		pass
	for key in newEquip.myPacket.attributeMods.keys() :
		if (!modIsDirectUpgrade(newEquip.myPacket.attributeMods[key], oldEquip.myPacket.attributeMods[key])) :
			return false
	for key in newEquip.myPacket.statMods.keys() :
		if (!modIsDirectUpgrade(newEquip.myPacket.statMods[key], oldEquip.myPacket.statMods[key])) :
			return false
	for key in newEquip.myPacket.otherMods.keys() :
		if (key == Definitions.otherStatDictionary[Definitions.otherStatEnum.physicalDamageTaken] || key == Definitions.otherStatDictionary[Definitions.otherStatEnum.magicDamageTaken]) :
			if (!modIsDirectUpgrade(oldEquip.myPacket.otherMods[key], newEquip.myPacket.otherMods[key])) :
				return false
		else :
			if (!modIsDirectUpgrade(newEquip.myPacket.otherMods[key], oldEquip.myPacket.otherMods[key])) :
				return false
	return true
		
func modIsDirectUpgrade(mod1 : Dictionary, mod2 : Dictionary) -> bool :
	if (mod1["Prebonus"] < mod2["Prebonus"] && !is_equal_approx(mod1["Prebonus"], mod2["Prebonus"])) :
		return false
	if (mod1["Postbonus"] < mod2["Postbonus"] && !is_equal_approx(mod1["Postbonus"], mod2["Postbonus"])) :
		return false
	if (mod1["Premultiplier"] < mod2["Premultiplier"] && !is_equal_approx(mod1["Premultiplier"], mod2["Premultiplier"])) :
		return false
	if (mod1["Postmultiplier"] < mod2["Postmultiplier"] && !is_equal_approx(mod1["Postmultiplier"], mod2["Postmultiplier"])) :
		return false
	return true

func equipmentIsNew(item : Equipment) :
	if (item.equipmentGroups == null) :
		return false
	if (item.equipmentGroups.isSignature || item.equipmentGroups.isEligible) :
		return true
	return false

## A Dictionary can only contain keys of ONE TYPE OF ENUM. This is true for 
## everything, not just this function.
## Additionally, a Dictionary CANNOT contain keys of both int and enum
## So naturally this function assumes that if there is an int in a dictionary that it is an enum
#func stringifyDict(dict : Dictionary, type : Definitions.enumType) -> Dictionary :
	#var tempDict : Dictionary = {}
	#for key in dict.keys() :
		#if (key is int) :
			#tempDict[str(key)] = dict[key]
		#else :
			#tempDict[key] = dict[key]
	#return tempDict
#
### Unfortunately for my sanity, there is no point in returning an enum of a specific type from this 
### function as enums don't really exist at runtime
#func enumifyDict(dict : Dictionary, type : Definitions.enumType) -> Dictionary :
	#var tempDict : Dictionary = {}
	#for key in dict.keys() :
		#if (key.is_valid_int()) :
			#tempDict[int(key)] = dict[key]
		#else :
			#tempDict[key] = dict[key]
	#return tempDict
	
func calculateBase(preBonuses : Array[float], preMultipliers : Array[float]) -> float :
	var bonusSum : float = 0
	for bonus in preBonuses :
		bonusSum += bonus
	var multiplierProduct : float = 1
	for multiplier in preMultipliers :
		multiplierProduct *= multiplier
	return bonusSum*multiplierProduct

func calculateFinal(base : float, postBonuses : Array[float], postMultipliers : Array[float]) :
	var multiplierSum = 1
	for multiplier in postMultipliers :
		multiplierSum += multiplier
	var bonusSum = 0
	for bonus in postBonuses :
		bonusSum += bonus
	return (base*multiplierSum)+bonusSum
	
func findIndexInContainer(container : Node, child) :
	if (child == null) :
		return null
	var children = container.get_children()
	for index in range(0,children.size()) :
		if (children[index] == child) :
			return index
	return null
	
func myRound(val : float, sigFigs : int) :
	if (val == 0) :
		return int(0)
	var magnitude = floor(log(val)/log(10))
	var base = val/pow(10,magnitude)
	var roundedBase = round(base*pow(10.0,sigFigs-1))/pow(10.0,sigFigs-1)
	var finalValue = roundedBase*pow(10,magnitude)
	if (finalValue >= pow(10,sigFigs-1)) :
		return int(finalValue)
	else :
		return finalValue
		
func engineeringNotation(val) -> String :
	var newVal = val
	var suffix : String = ""
	if (val >= pow(10,30)) :
		newVal = val/pow(10,30)
		suffix = "No"
	elif (val >= pow(10,27)) :
		newVal = val/pow(10,27)
		suffix = "Oc"
	elif (val >= pow(10,24)) :
		newVal = val/pow(10,24)
		suffix = "Sp"
	elif (val >= pow(10,21)) :
		newVal = val/pow(10,21)
		suffix = "Sx"
	elif (val >= pow(10,18)) :
		newVal = val/pow(10,18)
		suffix = "Qi"
	elif (val >= pow(10,15)) :
		newVal = val/pow(10,15)
		suffix = "Qa"
	elif (val >= pow(10,12)) :
		newVal = val/pow(10,12)
		suffix = "T"
	elif (val >= pow(10,9)) :
		newVal = val/pow(10,9)
		suffix = "B"
	elif (val >= pow(10,6)) :
		newVal = val/pow(10,6)
		suffix = "M"
	elif (val >= pow(10,3)) :
		newVal = val/pow(10,3)
		suffix = "K"
	if (round(newVal) == newVal) :
		return str(int(newVal)) + suffix
	else :
		return str(newVal) + suffix

func engineeringRound(val, sigFigs : int) -> String :
	if (abs(val) < 1) :
		return str(val).substr(0,2+sigFigs)
	var rounded = myRound(val, sigFigs)
	return engineeringNotation(rounded)
	
var internalPopupBool : bool = false
func notifyPopupStart() :
	internalPopupBool = true
func notifyPopupStop() :
	internalPopupBool = false
func popupIsPresent() -> bool :
	var nodes = getAllNodes()
	for node in nodes :
		if (node.has_method("nestedPopupInit")) :
			return true
	return false
