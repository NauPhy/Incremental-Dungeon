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
		newMap.shopName = ""
	elif (previousMaps.size() == 1) :
		newMap.shopName = "routine"
	elif (previousMaps.size() == 2) :
		newMap.shopName = "armor"
	elif (previousMaps.size() == 3) :
		newMap.shopName = "weapon"
	elif (previousMaps.size() == 4) :
		newMap.shopName = "soul"
	else :
		newMap.shopName = "empty"
	previousMaps.append(newMap)
	return newMap
	
## moderately inefficent
func generateDrops(room : Node, environment : MyEnvironment) -> Dictionary :
	var retVal1 : Array[Equipment] = []
	$ItemPoolHandler.reset(environment, getAllItems())
	var roomName : String = room.name
	var currentRow = roomName.substr(1,1) as int
	var penaliseElemental : bool = !(environment.earthPermitted || environment.firePermitted || environment.icePermitted || environment.waterPermitted)
	for enemy in room.getEncounterRef().enemies :
		$DropHandler.reset($ItemPoolHandler.getItemPoolForEnemy(enemy))
		retVal1.append_array($DropHandler.createDropsForEnemy(enemy, getEquipmentScaling(getScalingRows_mapFinished(currentRow)), penaliseElemental))
	var averageGold = getGoldScaling(getScalingRows_mapFinished(currentRow))
	var goldRoll = randf_range(0, averageGold)
	var goldCount : int = round(goldRoll)
	var retVal2 : Array[int] = [goldCount]
	var averageOre = getOreScaling(getScalingRows_mapFinished(currentRow))
	var oreRoll = randf_range(0,averageOre)
	var oreCount : int = round(oreRoll)
	retVal2.append(oreCount)
	var averageSouls = getSoulScaling(getScalingRows_mapFinished(currentRow))
	var soulRoll = randf_range(0,averageSouls)
	var soulCount : int = round(soulRoll)
	retVal2.append(soulCount)
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
	if (previousMaps.size() == 9) :
		return MegaFile.getEnvironment("fort_demon")
	var myRange = MegaFile.Environment_FilesDictionary.size()-1
	var randKey = MegaFile.Environment_FilesDictionary.keys()[randi_range(0,myRange)]
	var potentialEnvironment = MegaFile.getEnvironment(randKey)
	## Outside of endless mode, the Demon Fortress is exclusive to the final floor
	while (createdRecently(potentialEnvironment) || (previousMaps.size()<10 && randKey == "fort_demon") ) :
		randKey = MegaFile.Environment_FilesDictionary.keys()[randi_range(0,myRange)]
		potentialEnvironment = MegaFile.getEnvironment(randKey)
	return potentialEnvironment
	
func createdRecently(newEnv : MyEnvironment) -> bool :
	var envName = newEnv.resource_path.get_file().get_basename()
	## There are 20 environments and 10 floors... might as well ensure no repeats whatsoever outside of endless mode
	if (previousMaps.size() < 10) :
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
	var rowCount = 5
	for index in range(0,rowCount) :
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
	if (previousMaps.size() == 9) :
		retVal.bossEncounter = createFinalBossEncounter(rowCount+1)
	else :
		retVal.bossEncounter = createBossEncounter(rowCount+1)
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
	var hasEnemies = previousMaps.size() == 0 || (row != 0)
	if (!hasEnemies) :
		return retVal
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
	
func createFinalBossEncounter(currentRow) -> Encounter :
	var retVal = Encounter.new()
	var hellKnightResource = EnemyDatabase.getEnemy("hell_knight")
	var archfiendResource = EnemyDatabase.getEnemy("arch_fiend")
	var apophisResource = EnemyDatabase.getEnemy("apophis")
	var scalingRows = getScalingRows_mapInProgress(currentRow)
	retVal.enemies.append(hellKnightResource.getAdjustedCopy(getEnemyScaling(scalingRows)))
	retVal.enemies.append(archfiendResource.getAdjustedCopy(getEnemyScaling(scalingRows)))
	retVal.enemies.append(apophisResource.getAdjustedCopy(getEnemyScaling(scalingRows+1)))
	retVal.enemies.append(hellKnightResource.getAdjustedCopy(getEnemyScaling(scalingRows)))
	retVal.enemies.append(hellKnightResource.getAdjustedCopy(getEnemyScaling(scalingRows)))
	retVal.introTitle = "This Is It"
	retVal.introText = "You had heard that the royal family was uniquely powerful among Archfiends, and as you enter the throne room, you finally see why. Half demon, half fire dragon, the Demon King towers over the archfiend at his side. He glowers at you with 3 sets of eyes and signals a phalanx of hell knights to advance on you."
	retVal.victoryTitle = "Victory!"
	retVal.victoryText = "After a long and brutal fight, Apophis finally falls, and with him, the Demons' hopes of world domination."
	addDrops(retVal)
	return retVal
		
func createNormal(currentRow) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.normal).getAdjustedCopy(getEnemyScaling(getScalingRows_mapInProgress(currentRow)))
func createVeteran(currentRow) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.veteran).getAdjustedCopy(getEnemyScaling(getScalingRows_mapInProgress(currentRow)))
func createElite(currentRow) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.elite).getAdjustedCopy(getEnemyScaling(getScalingRows_mapInProgress(currentRow)))

##currentRow starts at 0
func getScalingRows_mapFinished(currentRow) -> int :
	if (previousMaps.size() == 0): 
		return 0
	if (previousMaps.size() == 1) :
		return currentRow
	if (previousMaps.size() == 2) :
		return 6 + currentRow-1
	var scalingRows = 6
	for index in range(1, previousMaps.size()-1) :
		scalingRows += 5
	return scalingRows - 1

##currentRow starts at 0
func getScalingRows_mapInProgress(currentRow) -> int :
	var scalingRows = 0
	if (previousMaps.size() == 0): 
		return currentRow
	if (previousMaps.size() == 1) :
		return 6 + currentRow-1
	scalingRows = 6
	for index in range(1, previousMaps.size()) :
		scalingRows += 5
	return scalingRows - 1
	
func getEnemyScaling(scalingRows) :
	if (scalingRows <= 6) :
		return pow(4.18,scalingRows)
	return pow(4.18,6)*pow(2,scalingRows-6)
func getEquipmentScaling(scalingRows) :
	if (scalingRows <= 6) :
		return pow(4.18,scalingRows/4.0)
	return pow(4.18,6/4.0)*pow(2,(scalingRows-6)/4.0)
func getGoldScaling(scalingRows) :
	return pow(2,(scalingRows-1)/4.0)
func getOreScaling(scalingRows) :
	if (scalingRows < 7) :
		return 0
	return pow(2,(scalingRows - 8)/4.0)
func getSoulScaling(scalingRows) :
	if (scalingRows < 17) :
		return 0
	return pow(2,(scalingRows-18)/4.0)
	
func getScalingRowsInFloor(floorIndex) :
	if (floorIndex == 0) :
		return 0
	elif (floorIndex == 1) :
		return 6
	else :
		return 5
	
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
	#$ItemPoolHandler.reset(MegaFile.getEnvironment("chaos"), items)
	$DropHandler.reset(items)
	var quality = $DropHandler.getDropQualities(1)
	var newItem : Equipment = $DropHandler.getItemOfQuality_penaliseElemental(quality[0], true)
	return newItem.getAdjustedCopy(scaling)
############# Saving
var myReady : bool = false
signal myReadySignal
var doneLoading : bool = false
signal doneLoadingSignal
func _ready() :
	myReady = true
	emit_signal("myReadySignal")
func getSaveDictionary() -> Dictionary :
	var retVal : Dictionary = {}
	retVal["previousMaps"] = []
	for map in previousMaps :
		retVal["previousMaps"].append(map.getSaveDictionary())
	return retVal
func beforeLoad(newGame) :
	myReady = false
	$EnemyPoolHandler.initialiseMiscPool(getAllMisc())
	myReady = true
	emit_signal("myReadySignal")
	if (newGame) :
		doneLoading = true
		emit_signal("doneLoadingSignal")
func onLoad(loadDict : Dictionary) :
	myReady = false
	if (loadDict.get("previousMaps") != null) :
		for map in loadDict.get("previousMaps") :
			previousMaps.append(MapData.createFromSaveDictionary(map))
	myReady = true
	emit_signal("myReadySignal")
	doneLoading = true
	emit_signal("doneLoadingSignal")
