extends Node

## createX() -> X implies that X.new() or X.duplicate() is called-- it returns a runtime instance
## getX() -> X implies that the "readonly" disk version of X is returned- or a reference to a member in another class

func createMap() -> MapData :
	var environment : MyEnvironment = getEnvironment()
	$EnemyPoolHandler.reset(environment, getAllEnemies())
	#$ItemPoolHandler.reset(environment, getAllItems())
	var encounters : MapData = createEncounters()
	encounters.environmentName = environment.getFileName()
	return encounters


## moderately inefficent
func generateDrops(enemies : Array[ActorPreset], mapData : MapData) -> Array[Equipment]:
	var retVal : Array[Equipment] = []
	$ItemPoolHandler.reset(MegaFile.getEnvironment(mapData.environmentName), getAllItems())
	for enemy in enemies :
		$DropHandler.reset($ItemPoolHandler.getItemPoolForEnemy(enemy))
		retVal.append_array($DropHandler.createDropsForEnemy(enemy))
	return retVal

func getAllEnemies() :
	var list = EnemyDatabase.getAllEnemies()
	var index = 0
	while (index < list.size()) :
		if (!list[index].enemyGroups.isEligible) :
			list.remove_at(index)
		else :
			index += 1
	return list
	
func getAllMisc() :
	var list = EnemyDatabase.getAllEnemies() 
	var index = 0
	while (index < list.size()) :
		if (!list[index].enemyGroups.isEligible || !(list[index].enemyGroups.faction == EnemyGroups.factionEnum.misc)) :
			list.remove_at(index)
		else :
			index += 1
	return list
		
func getAllItems() :
	var list = EquipmentDatabase.getAllEquipment()
	var index = 0
	while (index < list.size()) :
		if (!list[index].equipmentGroups.isEligible) :
			list.remove_at(index)
		else :
			index += 1
	return list
	
func getEnvironment() -> MyEnvironment :
	if (previousEnvironments.size() == 9) :
		return MegaFile.getEnvironment("fort_demon")
	var myRange = MegaFile.Environment_FilesDictionary.size()-1
	var randKey = MegaFile.Environment_FilesDictionary.keys()[randi_range(0,myRange)]
	var potentialEnvironment = MegaFile.getEnvironment(randKey)
	while (createdRecently(potentialEnvironment)) :
		randKey = MegaFile.Environment_FilesDictionary.keys()[randi_range(0,myRange)]
		potentialEnvironment = MegaFile.getEnvironment(randKey)
	previousEnvironments.append(randKey)
	return potentialEnvironment
	
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
	
## Drops are now added on combat end. Instead of drop lists, beastiary will now show tags indicating what categories can and cannot be dropped.
func addDrops(encounter : Encounter) -> void :
	return
	#for enemy in encounter.enemies :
		#var itemPool = $ItemPoolHandler.getItemPoolForEnemy(enemy)
		#$DropHandler.reset(itemPool)
		#var newDrops = $DropHandler.getDrops(enemy)
		#var createdDrops : Array[Equipment] = []
		#for drop in newDrops :
			#createdDrops.append(drop.getAdjustedCopy(1.0))
		#enemy.drops.append_array(createdDrops)
		#enemy.dropChances.append_array($DropHandler.getDropChances(newDrops.size()))
	#
func createCentralEncounter() -> Encounter :
	var retVal = Encounter.new()
	retVal.enemies.append(createVeteran())
	if (randi_range(0,2) == 0) :
		retVal.enemies.append(createVeteran())
	else :
		for index in range(0,randi_range(2,3)) :
			retVal.enemies.append(createNormal())
	addDrops(retVal)
	return retVal

func createSideEncounter() -> Encounter :
	var retVal = Encounter.new()
	if (randi_range(0,2)==0) :
		retVal.enemies.append(createVeteran())
		if (randi_range(0,2) == 0) :
			retVal.enemies.append(createNormal())
	elif (randi_range(0,9) == 0) :
		var enemy = createNormal()
		enemy.getResourceName()
		for index in range(0,5) :
			retVal.enemies.append(enemy.duplicate())
	else :
		for index in range(0, randi_range(2,3)) :
			retVal.enemies.append(createNormal())
	addDrops(retVal)
	return retVal

func createBossEncounter() -> Encounter :
	var retVal = Encounter.new()
	retVal.enemies.append(createElite())
	if (randi_range(0,1) == 0) :
		retVal.enemies.append(createVeteran())
	else :
		for index in range(0,randi_range(2,3)) :
			retVal.enemies.append(createNormal())
	addDrops(retVal)
	return retVal
		
func createNormal() -> ActorPreset :
	#var test = $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.normal)
	#if (test == null): 
		#print("null")
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.normal).getAdjustedCopy(1)
func createVeteran() -> ActorPreset :
	#var test = $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.veteran)
	#if (test == null): 
		#print("null")
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.veteran).getAdjustedCopy(1)
func createElite() -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.elite).getAdjustedCopy(1)
	
############# Saving
var previousEnvironments : Array = []
var myReady : bool = false
func _ready() :
	myReady = true
func getSaveDictionary() -> Dictionary :
	var retVal : Dictionary = {}
	retVal["previousEnvironments"] = previousEnvironments
	return retVal
func beforeLoad(_newGame) :
	$EnemyPoolHandler.initialiseMiscPool(getAllMisc())
func onLoad(loadDict : Dictionary) :
	if (loadDict.get("previousEnvironments") != null) :
		previousEnvironments = loadDict["previousEnvironments"]
