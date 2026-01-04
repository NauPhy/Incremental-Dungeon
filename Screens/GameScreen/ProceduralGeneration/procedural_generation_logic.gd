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
	if (previousMaps.size() == 0) :
		newMap.shopName = "routine"
	elif (previousMaps.size() == 1) :
		newMap.shopName = "armor"
	elif (previousMaps.size() == 2) :
		newMap.shopData = "weapon"
	elif (previousMaps.size() == 3) :
		newMap.shopData = "soul"
	previousMaps.append(newMap)
	return newMap
	
## moderately inefficent
func generateDrops(room : Node, environment : MyEnvironment) -> Dictionary :
	var retVal1 : Array[Equipment] = []
	$ItemPoolHandler.reset(environment, getAllItems())
	var roomName : String = room.name
	var row = roomName.substr(1,1) as int
	var penaliseElemental : bool = !(environment.earthPermitted || environment.firePermitted || environment.icePermitted || environment.waterPermitted)
	for enemy in room.getEncounterRef().enemies :
		$DropHandler.reset($ItemPoolHandler.getItemPoolForEnemy(enemy))
		retVal1.append_array($DropHandler.createDropsForEnemy(enemy, getEquipmentScaling(row), penaliseElemental))
	var averageGold = getGoldScaling(row)
	var goldRoll = randf_range(0, averageGold)
	var goldCount : int = round(goldRoll)
	
	var retVal2 : Array[int] = [goldCount]
	
	var retVal = {
		"equipment" : retVal1,
		"currency" : retVal2
	}
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
	if (previousMaps.size() == 7) :
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
	var nodeCount = 10
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
	if (previousMaps.size() == 7) :
		retVal.bossEncounter = createFinalBossEncounter(nodeCount)
	else :
		retVal.bossEncounter = createBossEncounter(nodeCount)
	return retVal
	
## Drops are now added on combat end. Instead of drop lists, beastiary will now show tags indicating what categories can and cannot be dropped.
func addDrops(_encounter : Encounter) -> void :
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
	
func createFinalBossEncounter(row) -> Encounter :
	var retVal = Encounter.new()
	var hellKnightResource = EnemyDatabase.getEnemy("hell_knight")
	var archfiendResource = EnemyDatabase.getEnemy("arch_fiend")
	var apophisResource = EnemyDatabase.getEnemy("apophis")
	retVal.enemies.append(hellKnightResource.getAdjustedCopy(getEnemyScaling(row)))
	retVal.enemies.append(archfiendResource.getAdjustedCopy(getEnemyScaling(row)))
	retVal.enemies.append(apophisResource.getAdjustedCopy(getEnemyScaling(row+1.71)))
	retVal.enemies.append(hellKnightResource.getAdjustedCopy(getEnemyScaling(row)))
	retVal.enemies.append(hellKnightResource.getAdjustedCopy(getEnemyScaling(row)))
	retVal.introTitle = ""
	retVal.introText = ""
	retVal.victoryTitle = ""
	retVal.victoryText = ""
	addDrops(retVal)
	return retVal
		
func createNormal(row) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.normal).getAdjustedCopy(getEnemyScaling(row))
func createVeteran(row) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.veteran).getAdjustedCopy(getEnemyScaling(row))
func createElite(row) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.elite).getAdjustedCopy(getEnemyScaling(row))
	
func getEnemyScaling(row : int) :
	var nodes = row + 1
	for map in previousMaps :
		nodes += map.rows.size() + 1
	if (nodes <= 6) :
		return pow(4.18, nodes)
	return pow(4.18,6)*pow(2,nodes-6)
	
func getEquipmentScaling(row : int) -> float :
	var nodes = row + 1
	for index in range(0, previousMaps.size()-1) :
		nodes += previousMaps[index].rows.size() + 1
	if (nodes <= 6) :
		return pow(4.18, nodes/4.0)
	else :
		return pow(4.18,6/4.0)*pow(2,(nodes-6)/4.0)

func getGoldScaling(row : int) :
	var nodes = row
	for index in range(0, previousMaps.size()-1) :
		nodes += previousMaps[index].rows.size() + 1
	return pow(2,nodes/4.0)
	
func createRandomShopItem(type : Definitions.equipmentTypeEnum, scaling : float) -> Equipment :
	var items = getAllItems()
	var index = 0
	while (index < items.size()) :
		if (items[index] is Armor && type != Definitions.equipmentTypeEnum.armor) :
			items.remove_at(index)
		elif (items[index] is Weapon && type != Definitions.equipmentTypeEnum.weapon) :
			items.remove_at(index)
		elif (items[index] is Currency || items[index] is Accessory) :
			items.remove_at(index)
		else :
			index += 1
	$ItemPoolHandler.reset(MegaFile.getEnvironment("chaos"), items)
	$DropHandler.reset(items)
	var quality = $DropHandler.getDropQualities(1)
	var newItem : Equipment = $DropHandler.getItemOfQuality_penaliseElemental(quality, true)
	return newItem.getAdjustedCopy(scaling)
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
