extends Node

var killedDictionary : Dictionary = {}
var itemsObtainedDictionary : Dictionary = {}

func _init() :
	add_to_group("Saveable")
	
func getAllEnemies() -> Array :
	var actorList = MegaFile.getAllNewActor()
	actorList.append_array(MegaFile.getAllOldActor())
	return actorList
	
func getEnemy(enemyName) :
	var try = MegaFile.getNewActor(enemyName)
	if (try != null) :
		return try
	return MegaFile.getOldActor(enemyName)
	
signal enemyDataChanged
func getEnemyKilled(enemyName : String) -> bool :
	return killedDictionary.get(enemyName) != null && killedDictionary[enemyName] != 0
func setEnemyKilled(enemyName : String, val : int) :
	killedDictionary[enemyName] = val
	emit_signal("enemyDataChanged", enemyName)
func incrementKills(enemyName : String) :
	killedDictionary[enemyName] += 1
	emit_signal("enemyDataChanged", enemyName)
func getAllEnemyDropsCollected(enemyName : String) -> bool :
	if (!getEnemyKilled(enemyName)) :
		return false
	for itemKey in itemsObtainedDictionary[enemyName].keys() :
		if (!itemsObtainedDictionary[enemyName][itemKey]) :
			return false
	return true
func setItemCollected(enemyName : String, item : String) :
	itemsObtainedDictionary[enemyName][item] = true
	emit_signal("enemyDataChanged", enemyName)
	
var myReady : bool = false
signal myReadySignal
var doneLoading : bool = false
signal doneLoadingSignal
func _ready() :
	myReady = true
	emit_signal("myReadySignal")
	
func getSaveDictionary() -> Dictionary :
	var retVal : Dictionary = {}
	retVal["killed"]=killedDictionary
	retVal["items"]=itemsObtainedDictionary
	return retVal
	
func beforeLoad(newGame) :
	myReady = false
	if (newGame) :
		for actor in MegaFile.getAllNewActor() :
			resetEntry(actor.resource_path.get_file().get_basename())
		for actor in MegaFile.getAllOldActor() :
			resetEntry(actor.resource_path.get_file().get_basename())
	myReady = true
	emit_signal("myReadySignal")
	if (newGame) :
		doneLoading = true
		emit_signal("doneLoadingSignal")
	
func resetEntry(key) :
	killedDictionary[key] = 0
	var emptyDict : Dictionary = {}
	itemsObtainedDictionary[key] = emptyDict
	var enemy = getEnemy(key)
	for item in enemy.drops :
		itemsObtainedDictionary[key][item.getName()] = false

func onLoad(loadDict : Dictionary) :
	myReady = false
	killedDictionary = loadDict["killed"]
	itemsObtainedDictionary = loadDict["items"]
	await get_tree().process_frame
	emit_signal("enemyDataChanged", "ALL")
	myReady = true
	emit_signal("myReadySignal")
	doneLoading = true
	emit_signal("doneLoadingSignal")

func getEnemyList() :
	var retVal : Array = []
	retVal = killedDictionary.keys()
	retVal.sort_custom(func(a,b):return a<b)
	return retVal
	
func getItemObtained(enemy, item) :
	if (!getEnemyKilled(enemy)) :
		return false
	return itemsObtainedDictionary[enemy][item]
	
func getKillCount(enemy) :
	return killedDictionary[enemy]
