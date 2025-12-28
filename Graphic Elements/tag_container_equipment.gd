extends HBoxContainer

func setEquipment(item : Equipment) :
	var stuff = item.equipmentGroups
	var tech = $Technology.get_children()
	for index in range(0, tech.size()) :
		if (index == stuff.technology as int && (!stuff.isSignature)) :
			tech[index].visible = true
		else :
			tech[index].visible = false
	var off = $Offense.get_children()
	for index in range(0, off.size()) :
		if (index == stuff.weaponClass as int && (!stuff.isSignature)) :
			off[index].visible = true
		else :
			off[index].visible = false
	var def = $Defense.get_children()
	for index in range(0, def.size()) :
		if (index == stuff.armorClass as int && (!stuff.isSignature)) :
			def[index].visible = true
		else :
			def[index].visible = false
	if (stuff.isSignature) :
		$Signature.get_child(0).visible = true
	else :
		$Signature.get_child(0).visible = false
	updateAllRecursive(get_children())
	addTooltipsRecursive(get_children())
	
func updateAllRecursive(children : Array[Node]) :
	for child in children :
		if (child.has_method("updateSize")) :
			child.updateSize()
		if (child.get_child_count() > 0) :
			updateAllRecursive(child.get_children())

func addTooltipsRecursive(children : Array[Node]) :
	for child in children :
		if (child.has_method("updateSize") && child.visible) :
			addTooltip(child)
		if (child.get_child_count() > 0) :
			addTooltipsRecursive(child.get_children())
			
const tooltipLoader = preload("res://Graphic Elements/Tooltips/tooltip_trigger.tscn")
func addTooltip(child : Node) :
	var title : String = child.name
	var upperLeft = Vector2(0,0)
	var bottomRight = Vector2(16,16) * child.getScale()
	var newTrigger = tooltipLoader.instantiate()
	child.add_child(newTrigger)
	newTrigger.initialise(title)
	newTrigger.currentLayer = Helpers.getTopLayer()
	newTrigger.setPos(upperLeft, bottomRight)
