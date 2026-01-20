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
	if (previousMaps.size() == 0) :
		for enemy in newMap.rows[0].centralEncounter.enemies :
			enemy.MAXHP *= 0.6
		for room in newMap.rows[0].leftEncounters :
			for enemy in room.enemies :
				enemy.MAXHP *= 0.7
		for room in newMap.rows[0].rightEncounters :
			for enemy in room.enemies :
				enemy.MAXHP *= 0.7
	previousMaps.append(newMap)
	return newMap
	
## moderately inefficent
func generateDrops(currentFloor : int, room : Node, environment : MyEnvironment, magicFind : float) -> Dictionary :
	var retVal1 : Array[Equipment] = []
	$ItemPoolHandler.reset(environment, getAllItems())
	var roomName : String = room.name
	var currentRow = (roomName.substr(1,1) as int)
	var penaliseElemental : bool = !(environment.earthPermitted || environment.firePermitted || environment.icePermitted || environment.waterPermitted)
	for enemy in room.getEncounterRef().enemies :
		$DropHandler.reset($ItemPoolHandler.getItemPoolForEnemy(enemy))
		retVal1.append_array($DropHandler.createDropsForEnemy(enemy, getEquipmentScaling(getScalingRows_mapFinished(currentFloor, currentRow)), penaliseElemental, magicFind))
	for item in retVal1 :
		var scalingAmount = getScalingRows_mapFinished(currentFloor, currentRow)
		if (scalingAmount > 1) :
			item.title += " +"+str(scalingAmount-1)
	var averageGold = getGoldScaling(getScalingRows_mapFinished(currentFloor, currentRow))
	var goldRoll = randf_range(0, averageGold)
	var goldCount : int = round(goldRoll)
	var retVal2 : Array[int] = [goldCount]
	var averageOre = getOreScaling(getScalingRows_mapFinished(currentFloor, currentRow))
	var oreRoll = randf_range(0,averageOre)
	var oreCount : int = round(oreRoll)
	retVal2.append(oreCount)
	var averageSouls = getSoulScaling(getScalingRows_mapFinished(currentFloor, currentRow))
	var soulRoll = randf_range(0,averageSouls)
	var soulCount : int = round(soulRoll)
	retVal2.append(soulCount)
	if (room.has_method("getEncounterRef")) :
		var enemies = room.getEncounterRef().enemies
		var goldDragon : bool = false
		for enemy in enemies :
			if (enemy.getResourceName() == "gold_dragon") :
				goldDragon = true
				break
		if (goldDragon) :
			for index in range(0, retVal2.size()) :
				retVal2[index] = retVal2[index] * 3
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

## The goal is:
## Central encounter power = 2
## Side encounter power = 1 BUT with +sqrt(2) scaling, i.e. halfway to next node
## Boss encounter power = 3
## with normal = (1/3), vet = 1, boss = 2
func createEncounters() -> MapData :
	var retVal = MapData.new()
	var rowCount = 5
	for index in range(0,rowCount) :
		var newRow = MapRow.new()
		newRow.centralEncounter = createCentralEncounter(index)
		var sideNodeCount = randi_range(2,3)
		var leftNodeCount = randi_range(0,sideNodeCount)
		var rightNodeCount = sideNodeCount-leftNodeCount
		for leftIndex in range(0,leftNodeCount) :
			newRow.leftEncounters.append(createSideEncounter(index))
		for rightIndex in range(0,rightNodeCount) :
			newRow.rightEncounters.append(createSideEncounter(index))
		retVal.rows.append(newRow)
	if (previousMaps.size() == 9) :
		retVal.bossEncounter = createFinalBossEncounter(rowCount)
	else :
		retVal.bossEncounter = createBossEncounter(rowCount)
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
	if (randi_range(0,1) == 0) :
		retVal.enemies.append(createVeteran(row))
	else :
		for index in range(0,randi_range(2,3)) :
			retVal.enemies.append(createNormal(row))
	addDrops(retVal)
	retVal = compensateForMultiEnemy(retVal, row, "center")
	return retVal
	
func compensateForMultiEnemy(encounter : Encounter,row, type) -> Encounter :
	if (encounter.enemies.size() == 1) :
		return encounter
	var retVal = encounter.duplicate(true)
	var scalingRows = getScalingRows_mapInProgress(row)
	var roomBudget
	if (type == "center") :
		roomBudget = ActorPreset.referencePowerLevel*getEnemyScaling(scalingRows)*2
	elif (type == "side") :
		roomBudget = ActorPreset.referencePowerLevel*getEnemyScaling(scalingRows)*sqrt(2)
	else :
		roomBudget = ActorPreset.referencePowerLevel*getEnemyScaling(scalingRows)*3
		
	var enemyVals : Array[Dictionary] = []
	for enemy : ActorPreset in retVal.enemies :
		var tempDict : Dictionary = {}
		tempDict["eHP"] = enemy.MAXHP * (enemy.PHYSDEF + enemy.MAGDEF)/2.0
		tempDict["eDPS"] = enemy.AR * enemy.DR * (enemy.actions[0].getPower() / enemy.actions[0].getWarmup())
		tempDict["ratio"] = tempDict["eDPS"]/tempDict["eHP"]
		enemyVals.append(tempDict)
	enemyVals.sort_custom(func(a,b): return a["ratio"]>b["ratio"])
	var actualPower = 0
	for index in range(0,enemyVals.size()) :
		var lifespan = enemyVals[index]["eHP"]
		var damage = 0
		for innerIndex in range(index, enemyVals.size()) :
			damage += enemyVals[innerIndex]["eDPS"]
		actualPower += lifespan*damage

	var correctionRatio = 1.0/(pow(actualPower/roomBudget,1.0/4.0))
	for enemy : ActorPreset in retVal.enemies :
		enemy.AR *= correctionRatio
		enemy.DR *= correctionRatio
		enemy.MAXHP *= correctionRatio
		enemy.PHYSDEF *= correctionRatio
		enemy.MAGDEF *= correctionRatio
	if (actualPower > 1.5*roomBudget) :
		print("corrected " + type + " room with " + str(retVal.enemies.size()) + " enemies from " + str(actualPower) + " to " + str(roomBudget))
	return retVal

## Side encounters have a unit power of 1, but use stronger enemies- halfway to the next node.
## This may result in side encounters feeling a bit trivial, but they're meant for farming, not challenge.
func createSideEncounter(row) -> Encounter :
	var roll = randf_range(0,1)
	var retVal = Encounter.new()
	if (roll <= 0.333*0.95) :
		retVal.enemies.append(createVeteran(row+0.5))
	elif (roll <= 0.95) :
		for index in range(0, 3) :
			retVal.enemies.append(createNormal(row+0.5))
		if (randi_range(0,2) == 0) :
			retVal.enemies.append(createNormal(row+0.5))
	else :
		var enemy = createNormal(row+0.5)
		for index in range(0,5) :
			retVal.enemies.append(enemy.getAdjustedCopy(enemy.myScalingFactor))
	addDrops(retVal)
	retVal = compensateForMultiEnemy(retVal, row, "side")
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
	retVal = compensateForMultiEnemy(retVal, row, "boss")
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
	retVal.introText = "You had heard that the royal family was uniquely powerful among Archfiends, and as you enter the throne room, you finally see why. Half demon, half fire dragon, the Demon King towers over the Archfiend at his side. He glowers at you with 3 sets of eyes and signals a phalanx of hell knights to advance on you."
	retVal.victoryTitle = "Victory!"
	retVal.victoryText = "After a long and brutal fight, Apophis finally falls, and with him, the Demons' hopes of world domination."
	addDrops(retVal)
	retVal = compensateForMultiEnemy(retVal, currentRow,"boss")
	return retVal
		
func createNormal(currentRow) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.normal).getAdjustedCopy(getEnemyScaling(getScalingRows_mapInProgress(currentRow)))
func createVeteran(currentRow) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.veteran).getAdjustedCopy(getEnemyScaling(getScalingRows_mapInProgress(currentRow)))
func createElite(currentRow) -> ActorPreset :
	return $EnemyPoolHandler.getEnemyOfType(EnemyGroups.enemyQualityEnum.elite).getAdjustedCopy(getEnemyScaling(getScalingRows_mapInProgress(currentRow)))

##currentRow starts at 0
func getScalingRows_mapFinished(currentFloor, currentRow) -> int :
	if (currentFloor == 0): 
		return 0
	if (currentFloor == 1) :
		return currentRow+1
	if (currentFloor == 2) :
		return 6 + currentRow
	var scalingRows = 6
	for index in range(1, currentFloor-1) :
		scalingRows += 5
	return scalingRows + currentRow

##currentRow starts at 0
func getScalingRows_mapInProgress(currentRow) -> float :
	var scalingRows = 0
	if (previousMaps.size() == 0): 
		return currentRow+1
	if (previousMaps.size() == 1) :
		return 6 + currentRow
	scalingRows = 6
	for index in range(1, previousMaps.size()) :
		scalingRows += 5
	return scalingRows + currentRow
	
func getEnemyScaling(scalingRows) :
	var retVal = enemyScalingLookupTable.get(scalingRows as int)
	if (retVal== null) :
		var prev = enemyScalingLookupTable.get((scalingRows as int)-1)
		if (prev == null) :
			var currentVal = enemyScalingLookupTable[11]
			for index in range(12, scalingRows+1) :
				currentVal *= 2
				enemyScalingLookupTable[index as int] = currentVal
			prev = enemyScalingLookupTable[(scalingRows as int)-1]
		enemyScalingLookupTable[scalingRows as int] = prev*2
		retVal = enemyScalingLookupTable[scalingRows as int]
	if (is_equal_approx(scalingRows-floor(scalingRows),0.5)) :
		retVal *= sqrt(2)
	if ((scalingRows as int - 7)%5 == 0) :
		retVal *= 1.25
	return retVal
				
	
var enemyScalingLookupTable : Dictionary = {}
## I'm less likely to make a mistake if I do this a bit at a time, but it's rather computationally expensive so:
func createLookupTable() :
	enemyScalingLookupTable = {}
	var currentVal = 1
	## The first 5 rows scale quickly to get the player to the point where it takes 10 minutes to increase their stat total by a factor of 4throot(2)
	for index in range(1,5+1) :
		currentVal *= 5.284368
		enemyScalingLookupTable[index] = currentVal
	## First boss is currently the same
	for index in range(6,6+1) :
		currentVal *= 5.284368
		enemyScalingLookupTable[index] = currentVal
	## From here on it's x2 every row
	for index in range(7,11+1) :
		currentVal *= 2
		enemyScalingLookupTable[index] = currentVal

	
func getEquipmentScaling(scalingRows) :
	var rows
	if (is_equal_approx(scalingRows-floor(scalingRows),0.5)) :
		rows = floor(scalingRows)
	else :
		rows = scalingRows
	return pow(getEnemyScaling(floor(rows)), 0.25)
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
	
func createRandomShopItem(type : Definitions.equipmentTypeEnum, myFloor, currentRow) -> Equipment :
	var scalingRow = getScalingRows_mapFinished(myFloor, currentRow)
	var scaling = getEquipmentScaling(scalingRow)
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
	var quality = $DropHandler.getDropQualities(1.0, 1)
	var newItem : Equipment = $DropHandler.getItemOfQuality_penaliseElemental(quality[0],type, true)
	var retVal = newItem.getAdjustedCopy(scaling)
	retVal.title += " +" + str(scalingRow-1)
	return retVal
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
	createLookupTable()
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
