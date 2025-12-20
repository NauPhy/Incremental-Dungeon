extends Node

var resourceLoader1 = preload("res://Resources/OldActor/OldActorReferences.gd")
var resource1

var killedDictionary : Dictionary = {}
var itemsObtainedDictionary : Dictionary = {}

func _init() :
	add_to_group("Saveable")
	resource1 = resourceLoader1.new()
	add_child(resource1)
	#resources = resourceLoader.new()
	#add_child(resources)
	
func getAllEnemies() -> Array[ActorPreset] :
	var actorList = NewActorReferences.getAllNewActor()
	actorList.append_array(resource1.getAllOldActor())
	return actorList
	
func getEnemy(enemyName) :
	var try = NewActorReferences.getNewActor(enemyName)
	if (try != null) :
		return try
	return resource1.getOldActor(enemyName)
	
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
func _ready() :
	myReady = true
	
func getSaveDictionary() -> Dictionary :
	var retVal : Dictionary = {}
	retVal["killed"]=killedDictionary
	retVal["items"]=itemsObtainedDictionary
	return retVal
	
func beforeLoad(newGame) :
	if (newGame) :
		for actor in NewActorReferences.getAllNewActor() :
			resetEntry(actor.resource_path.get_file().get_basename())
		for actor in resource1.getAllOldActor() :
			resetEntry(actor.resource_path.get_file().get_basename())
				
func resetEntry(key) :
	killedDictionary[key] = 0
	var emptyDict : Dictionary = {}
	itemsObtainedDictionary[key] = emptyDict
	var enemy = getEnemy(key)
	print("Type:", typeof(enemy))  # 17 = OBJECT
	print("Class name:", enemy.get_class())
	print("Script:", enemy.get_script())
	for item in enemy.drops :
		itemsObtainedDictionary[key][item.getName()] = false

func onLoad(loadDict : Dictionary) :
	killedDictionary = loadDict["killed"]
	itemsObtainedDictionary = loadDict["items"]
	await get_tree().process_frame
	emit_signal("enemyDataChanged", "ALL")

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
