extends HBoxContainer

const bigLoader = preload("res://Screens/GameScreen/Tabs/Combat/Map/Map_Runtime/enemy_entry_big_runtime.tscn")

var myEnemy : ActorPreset = null
var itemCollection : Dictionary = {}

func setEnemy(enemy : ActorPreset) :
	if (myEnemy != null) :
		myEnemy.disconnect("droppeditems", _on_items_dropped)
		myEnemy = null
		itemCollection = {}
		$Skull.visible = false
		$Star.visible = false
		killCount = 0
	myEnemy = enemy
	$Name.text = " " + myEnemy.getName() + " "
	for item in myEnemy.drops :
		itemCollection[item.getItemName()] = false
	myEnemy.connect("droppedItems", _on_items_dropped)
	
func _on_items_dropped(itemList : Array[Equipment]) :
	for item in itemList :
		itemCollection[item.getItemName()] = true
	updateStarVisibility()
	
#func setEnemyKilled(val) :
	#$Skull.visible = val
	
var killCount = 0
func incrementKilled() :
	killCount += 1
	$Skull.visible = true

#func setDropCollected(item : Equipment, val : bool) :
	#itemCollection[item.getItemName()] = val
	#updateStarVisibility()
	#
#func setItemsCollected(items : Array[String]) :
	#for itemName in items :
		#itemCollection[itemName] = true
	#updateStarVisibility()
	
func updateStarVisibility() :
	for itemCollected in itemCollection.values() :
		if (!itemCollected) :
			$Star.visible = false
			return
	$Star.visible = true
	
func getEnemy() :
	return myEnemy

func createBigEntry() :
	var bigEntry = bigLoader.instantiate()
	add_child(bigEntry)
	if (!bigEntry.myReady) :
		await bigEntry.myReadySignal
	bigEntry.initialise(self)
	
func getSaveDictionary() :
	var retVal : Dictionary = {}
	retVal["killed"] = killCount
	retVal["collected"] = itemCollection
	return retVal
func onLoad(loadDict) :
	killCount = loadDict["killed"]
	$Skull.visible = killCount > 0
	itemCollection = loadDict["collected"]
	updateStarVisibility()
