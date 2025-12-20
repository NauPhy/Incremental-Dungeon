extends Node

## createX() -> X implies that X.new() or X.duplicate() is called-- it returns a runtime instance
## getX() -> X implies that the "readonly" disk version of X is returned- or a reference to a member in another class

func createMap() -> MapData :
	var environment : MyEnvironment = createEnvironment()
	$EnemyPoolHandler.reset(environment, getAllEnemies())
	$ItemPoolHandler.reset(environment, getAllItems())
	var encounters : MapData = createEncounters()
	return encounters

func getAllEnemies() :
	var list = EnemyDatabase.getAllActors()
	for actor in list :
		if (!actor.enemyGroups.isEligible) :
			list.remove_at(list.find(actor))
		
func getAllItems() :
	var list = EquipmentDatabase.getAllEquipment()
	for item in list :
		if (!item.equipmentGroups.isEligible) :
			list.remove_at(list.find(item))
	return list
	
const environmentList = preload("res://Resources/Environment/EnvironmentReferences.gd")
func createEnvironment() -> MyEnvironment :
	if (previousEnvironments.size() == 9) :
		return environmentList.getEnvironment("fort_demon")
	var myRange = environmentList.FilesDictionary.size()-1
	var randKey = environmentList.FilesDictionary.keys()[randi_range(0,myRange)]
	var potentialEnvironment = environmentList.FilesDictionary[randKey]
	while (createdRecently(potentialEnvironment)) :
		randKey = environmentList.FilesDictionary.keys()[randi_range(0,myRange)]
		potentialEnvironment = environmentList.FilesDictionary[randKey]
	previousEnvironments.append(randKey)
	return potentialEnvironment.duplicate()
	
func createdRecently(newEnv : MyEnvironment) -> bool :
	var envName = newEnv.resource_path.get_file().get_basename()
	if (previousEnvironments.size() < 4) :
		if (previousEnvironments.find(envName) != -1) :
			return true
	var mostRecentPermitted = previousEnvironments.size()-4
	return (previousEnvironments.find(envName) < mostRecentPermitted)
	
func createEncounters() -> MapData :
	var retVal = MapData.new()
	var nodeCount = randi_range(4,7)
	for index in range(0,nodeCount) :
		var newRow = MapRow.new()
		newRow.centralEncounter = createCentralEncounter()
		var sideNodeCount = randi_range(2,5)
		var leftNodeCount = randi_range(0,sideNodeCount)
		var rightNodeCount = sideNodeCount-leftNodeCount
		for leftIndex in range(0,leftNodeCount) :
			newRow.leftEncounters.append(createSideEncounter())
		for rightIndex in range(0,rightNodeCount) :
			newRow.rightEncounters.append(createSideEncounter())
		retVal.rows.append(newRow)
	retVal.bossEncounter = createBossEncounter()
	return retVal
	
func addDrops(encounter : Encounter) -> void :
	for enemy in encounter.enemies :
		var itemPool = $ItemPoolHandler.getItemPoolForEnemy(enemy)
		$DropHandler.reset(itemPool)
		var newDrops = $Drophandler.getDrops()
		enemy.drops.append_array(newDrops)
		enemy.dropChances.append_array($DropHandler.getDropChances(newDrops.size()))
	
func createCentralEncounter() -> Encounter :
	var retVal = Encounter.new()
	retVal.enemies.append(getVeteran().duplicate())
	if (randi_range(0,2) == 0) :
		retVal.enemies.append(getVeteran().duplicate())
	else :
		for index in range(0,randi_range(2,3)) :
			retVal.enemies.append(getNormal().duplicate())
	addDrops(retVal)
	return retVal

func createSideEncounter() -> Encounter :
	var retVal = Encounter.new()
	if (randi_range(0,2)==0) :
		retVal.enemies.append(getVeteran().duplicate())
		if (randi_range(0,2) == 0) :
			retVal.enemies.append(getNormal().duplicate())
	elif (randi_range(0,9) == 0) :
		var enemy = getNormal().duplicate()
		for index in range(0,5) :
			retVal.enemies.append(enemy)
	else :
		for index in range(0, randi_range(2,3)) :
			retVal.enemies.append(getNormal().duplicate())
	addDrops(retVal)
	return retVal

func createBossEncounter() -> Encounter :
	var retVal = Encounter.new()
	retVal.enemies.append(getElite().duplicate())
	if (randi_range(0,1) == 0) :
		retVal.enemies.append(getVeteran().duplicate())
	else :
		for index in range(0,randi_range(2,3)) :
			retVal.enemies.append(getNormal().duplicate())
	addDrops(retVal)
	return retVal
		
func getNormal() -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.normal)
func getVeteran() -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.veteran)
func getElite() -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.elite)
	
############# Saving
var previousEnvironments : Array[String] = []
var myReady : bool = false
func _ready() :
	myReady = true
func getSaveDictionary() -> Dictionary :
	var retVal : Dictionary = {}
	retVal["previousEnvironments"] = previousEnvironments
	return retVal
func beforeLoad(_newGame) :
	pass
func onLoad(loadDict : Dictionary) :
	if (loadDict.get("previousEnvironments") != null) :
		previousEnvironments = loadDict["previousEnvironments"]
