extends HBoxContainer

func _ready() :
	setEnemy(EnemyDatabase.getEnemy("gold_dragon"))

func setEnemy(enemy : ActorPreset) :
	var stuff = enemy.enemyGroups
	var tech = $Technology.get_children()
	for index in range(0, tech.size()) :
		if (index == stuff.equipmentLevel as int) :
			tech[index].visible = true
		else :
			tech[index].visible = false
	var off = $Offense.get_children()
	for index in range(0, off.size()) :
		if (index + 1 == stuff.enemyRange as int) :
			off[index].visible = true
		else :
			off[index].visible = false
	var def = $Defense.get_children()
	for index in range(0, def.size()) :
		if (index == stuff.enemyArmor as int) :
			def[index].visible = true
		else :
			def[index].visible = false
	var sig = $Signature.get_children()
	for index in range(0, sig.size()) :
		if (index + 1 == stuff.enemyQuality as int) :
			sig[index].visible = true
		else :
			sig[index].visible = false
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
