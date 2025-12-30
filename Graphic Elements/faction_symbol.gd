extends HBoxContainer

const tooltipLoader = preload("res://Graphic Elements/Tooltips/tooltip_trigger.tscn")
func _ready() :
	var children = get_children()
	for index in range(0,children.size()) :
		var newTooltip = tooltipLoader.instantiate()
		children[index].add_child(newTooltip)
		newTooltip.initialise(EnemyGroups.factionDictionary[index as EnemyGroups.factionEnum])
		newTooltip.currentLayer = Helpers.getTopLayer()
		var upperLeft = Vector2(0,0)
		var bottomRight = Vector2(16,16)*children[index].getScale()
		newTooltip.setPos(upperLeft, bottomRight)

func setSymbolMutex(val : EnemyGroups.factionEnum) :
	clearAllSymbols()
	get_child(val).visible = true
	
func setSymbol(val : EnemyGroups.factionEnum) :
	get_child(val).visible = true

func clearAllSymbols() :
	for child in get_children() :
		child.visible = false
