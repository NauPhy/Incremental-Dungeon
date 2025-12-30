extends Node

## createX() -> X implies that X.new() or X.duplicate() is called-- it returns a runtime instance
## getX() -> X implies that the "readonly" disk version of X is returned- or a reference to a member in another class

var previousMaps : Array[MapData] = []
func createMap() -> MapData :
	var environment : MyEnvironment = getEnvironment()
	$EnemyPoolHandler.reset(environment, getAllEnemies())
	#$ItemPoolHandler.reset(environment, getAllItems())
	var newMap : MapData = createEncounters()
	newMap.environmentName = environment.getFileName()
	previousMaps.append(newMap)
	return newMap


## moderately inefficent
func generateDrops(room : Node, environment : MyEnvironment) -> Array[Equipment]:
	var retVal : Array[Equipment] = []
	$ItemPoolHandler.reset(environment, getAllItems())
	var roomName : String = room.name
	var row = roomName.substr(1,1) as int
	for enemy in room.getEncounterRef().enemies :
		$DropHandler.reset($ItemPoolHandler.getItemPoolForEnemy(enemy))
		retVal.append_array($DropHandler.createDropsForEnemy(enemy, getEquipmentScaling(row)))
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
	if (previousMaps.size() == 9) :
		return MegaFile.getEnvironment("fort_demon")
	var myRange = MegaFile.Environment_FilesDictionary.size()-1
	var randKey = MegaFile.Environment_FilesDictionary.keys()[randi_range(0,myRange)]
	var potentialEnvironment = MegaFile.getEnvironment(randKey)
	while (createdRecently(potentialEnvironment)) :
		randKey = MegaFile.Environment_FilesDictionary.keys()[randi_range(0,myRange)]
		potentialEnvironment = MegaFile.getEnvironment(randKey)
	return potentialEnvironment
	
func createdRecently(newEnv : MyEnvironment) -> bool :
	var envName = newEnv.resource_path.get_file().get_basename()
	if (previousMaps.size() < 4) :
		for map in previousMaps :
			if (map.environmentName == envName) :
				return true
		return false
	else :
		var mostRecentPermitted = previousMaps.size()-4
		for index in range(0,previousMaps.size()) :
			if (previousMaps[index].environmentName == envName) :
				return index < mostRecentPermitted
		return false
	
func createEncounters() -> MapData :
	var retVal = MapData.new()
	var nodeCount = randi_range(4,7)
	for index in range(0,nodeCount) :
		var newRow = MapRow.new()
		newRow.centralEncounter = createCentralEncounter(index)
		var sideNodeCount = randi_range(2,5)
		var leftNodeCount = randi_range(0,sideNodeCount)
		var rightNodeCount = sideNodeCount-leftNodeCount
		for leftIndex in range(0,leftNodeCount) :
			newRow.leftEncounters.append(createSideEncounter(index))
		for rightIndex in range(0,rightNodeCount) :
			newRow.rightEncounters.append(createSideEncounter(index))
		retVal.rows.append(newRow)
	retVal.bossEncounter = createBossEncounter(nodeCount)
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
func createCentralEncounter(row) -> Encounter :
	var retVal = Encounter.new()
	retVal.enemies.append(createVeteran(row))
	if (randi_range(0,2) == 0) :
		retVal.enemies.append(createVeteran(row))
	else :
		for index in range(0,randi_range(2,3)) :
			retVal.enemies.append(createNormal(row))
	addDrops(retVal)
	return retVal

func createSideEncounter(row) -> Encounter :
	var retVal = Encounter.new()
	if (randi_range(0,2)==0) :
		retVal.enemies.append(createVeteran(row))
		if (randi_range(0,2) == 0) :
			retVal.enemies.append(createNormal(row))
	elif (randi_range(0,9) == 0) :
		var enemy = createNormal(row)
		for index in range(0,5) :
			retVal.enemies.append(enemy.getAdjustedCopy(enemy.myScalingFactor))
	else :
		for index in range(0, randi_range(2,3)) :
			retVal.enemies.append(createNormal(row))
	addDrops(retVal)
	return retVal

func createBossEncounter(row) -> Encounter :
	var retVal = Encounter.new()
	retVal.enemies.append(createElite(row))
	if (randi_range(0,1) == 0) :
		retVal.enemies.append(createVeteran(row))
	else :
		for index in range(0,randi_range(2,3)) :
			retVal.enemies.append(createNormal(row))
	addDrops(retVal)
	return retVal
		
func createNormal(row) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.normal).getAdjustedCopy(getEnemyScaling(row))
func createVeteran(row) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.veteran).getAdjustedCopy(getEnemyScaling(row))
func createElite(row) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.elite).getAdjustedCopy(getEnemyScaling(row))
	
func getEnemyScaling(row : int) :
	var nodes = row
	for map in previousMaps :
		nodes += map.rows.size() + 1
	return pow(1.5,nodes)
	
func getEquipmentScaling(row : int) :
	var nodes = row
	for map in previousMaps :
		nodes += map.rows.size() + 1
	return pow(1.5,nodes/4.0)
	
############# Saving
var myReady : bool = false
func _ready() :
	myReady = true
func getSaveDictionary() -> Dictionary :
	var retVal : Dictionary = {}
	retVal["previousMaps"] = []
	for map in previousMaps :
		retVal["previousMaps"].append(map.getSaveDictionary())
	return retVal
func beforeLoad(_newGame) :
	$EnemyPoolHandler.initialiseMiscPool(getAllMisc())
func onLoad(loadDict : Dictionary) :
	if (loadDict.get("previousMaps") != null) :
		for map in loadDict.get("previousMaps") :
			previousMaps.append(MapData.createFromSaveDictionary(map))
