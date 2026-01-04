extends Node

const signatureEquipmentList = {
	"orc_warlord" : "adamantium_greataxe",
	"iron_golem" : "blunderbuss",
	"death" : "deaths_scythe",
	"titan" : "crackling_greataxe",
	"lich1" : "tome_death_2",
	"lich2" : "lich_crown",
	"amelia" : "amelia_wand",
	"lindwurm" : "coating_earth_2",
	"fire_snake" : "coating_fire_2",
	"ice_hydra" : "tome_ice_2",
	"arch_fiend" : "tome_fire_2",
	"ilsuiw" : "tome_water_2",
	"balrog" : "ring_authority",
	"tormentor" : "rampart_agony",
	"hellion" : "ring_malice",
	"hell_sentinel" : "rune_advanced_automation",
	"champion_of_poseidon" : "aegis",
	"kraken" : "armor_cephalopod",
	"fire_dragon" : "dragonbone_plate",
	"water_dragon" : "dragonbone_plate",
	"ice_dragon" : "dragonbone_plate",
	"gold_dragon" : "dragonbone_plate",
	"shadow_dragon" : "dragonbone_plate",
	"swamp_dragon" : "dragonbone_plate",
	"iron_dragon" : "dragonbone_plate",
	"bone_dragon" : "dragonbone_plate",
}

var itemPool : Array
var qualityCounts : Array[int] = [0,0,0,0,0]
#
func reset(items) :
	itemPool = items
	updateQualityCounts()
	#
##func getDrops(enemy : ActorPreset) -> Array :
	#
##func getDrops(enemy) -> Array :
	##updateQualityCounts()
	##var dropCount = getDropCount()
	##var qualities = getDropQualities(dropCount)
	##var items = getItemsOfQualities(qualities)
	##if (items.size() == 0) :
		##print("problem")
	##return handleSignatureItem(enemy, items)
#
#func handleSignatureItem(enemy : ActorPreset, itemList : Array) -> Array :
	#var retVal = itemList
	#var enemyName = enemy.resource_path.get_file().get_basename()
	#if (signatureEquipmentList.get(enemyName) == null) :
		#return retVal
	#var roll = randi_range(0,3)
	#if (roll != 0) :
		#return retVal
	#var signatureItem : Equipment = EquipmentDatabase.getEquipment(signatureEquipmentList[enemyName])
	#if (retVal.is_empty()) :
		#retVal.append(signatureItem)
	#else :
		#retVal[0] = signatureItem
	#return retVal
	#
#const chances : Dictionary = {
	#1 : 0.222,
	#2 : 0.167,
	#3 : 0.148
#}
#func getDropChances(count : int) -> Array[float] :
	#var retVal : Array[float] = []
	#for index in range(0,count) :
		#retVal.append(chances[count])
	#return retVal
	
const possibleDrops = [2,3,5]
const dropChance = [0.134,0.157,0.167]
func getDropCount(enemy : ActorPreset) :
	var dropCount = 0
	for index in range(0,possibleDrops[enemy.enemyGroups.enemyQuality as int]) :
		if (randf_range(0,1) < dropChance[enemy.enemyGroups.enemyQuality as int]) :
			dropCount += 1
	return dropCount

func createDropsForEnemy(enemy : ActorPreset, scalingFactor : float, penaliseElemental : bool) -> Array[Equipment] :
	var retVal : Array[Equipment] = []
	var dropCount = getDropCount(enemy)
	if (dropCount == 0) :
		return retVal
	var signatureDropped : bool = false
	if (enemy.enemyGroups.enemyQuality == EnemyGroups.enemyQualityEnum.elite && !(enemy.getResourceName() == "apophis")) :
		var roll = randf_range(0,100)
		if (roll < 3) : 
			signatureDropped = true
	if (signatureDropped) :
		retVal.append(getSignature(enemy).getAdjustedCopy(scalingFactor))
		dropCount -= 1
	var qualities = getDropQualities(dropCount)
	for index in range(0,dropCount) :
		var actualQuality = reduceToValidQuality(qualities[index])
		if (actualQuality == null) :
			continue
		var item
		if (penaliseElemental) :
			item = getItemOfQuality_penaliseElemental(actualQuality, false)
		else :
			item = getItemOfQuality(actualQuality)
		if (item == null) :
			continue
		retVal.append(item.getAdjustedCopy(scalingFactor))
	return retVal
	
func getSignature(enemy : ActorPreset) :
	return EquipmentDatabase.getEquipment(signatureEquipmentList[enemy.getResourceName()])
	
const qualityThresholds : Array[int] = [1.5,5,15,40,100]
func getDropQualities(count : int) -> Array[EquipmentGroups.qualityEnum] :
	var retVal : Array[EquipmentGroups.qualityEnum] = []
	for index in range(0,count) :
		var roll = randf_range(0,100)
		for qualityIndex in range(0,qualityThresholds.size()) :
			if (roll <= qualityThresholds[qualityIndex]) :
				retVal.append((4-qualityIndex) as EquipmentGroups.qualityEnum)
				break
	return retVal
	
#func getItemsOfQualities(qualities : Array[EquipmentGroups.qualityEnum], enemy : ActorPreset) -> Array[Equipment] :
	#var retVal : Array[Equipment] = []
	#var signatureSpawned : bool = false
	#for quality in qualities :
		#if (enemy.enemyGroups.enemyQuality == EnemyGroups.enemyQualityEnum.elite && quality == EquipmentGroups.qualityEnum.legendary) :
			#if ()
		#var actualQuality = reduceToValidQuality(quality)
		#if (actualQuality == null) :
			#continue
		#var newItem = getItemOfQuality(actualQuality)
		#if (newItem != null) :
			#retVal.append(newItem)
	#return retVal
	
func reduceToValidQuality(startingQuality) :
	var currentQuality = startingQuality
	while (qualityCounts[currentQuality] == 0 && currentQuality != -1) :
		currentQuality -= 1
	if (currentQuality == -1) :
		return null
	return currentQuality
	
func getItemOfQuality(quality) :
	var roll = randi_range(0,qualityCounts[quality]-1)
	var current = 0
	for item : Equipment in itemPool :
		if (item.equipmentGroups.quality == quality) :
			if (roll == current) :
				return item
			current += 1
	return null
	
func getItemOfQuality_penaliseElemental(quality, isHalved : bool) :
	var poolContainsNonelemental : bool = false
	for item in itemPool :
		if (!item.equipmentGroups.isElemental()) :
			poolContainsNonelemental = true
			break
	if (!poolContainsNonelemental) :
		return getItemOfQuality(quality)
	
	var sample = getItemOfQuality(quality)
	if (sample == null) :
		return null
	var maxVal
	if (isHalved) :
		maxVal = 1
	else :
		maxVal = 3
	while (sample.equipmentGroups.isElemental() && randi_range(0,maxVal) != 0) :
		sample = getItemOfQuality(quality)
	
#func getItemsOfQualities(qualities : Array[EquipmentGroups.qualityEnum]) :
	#var indices : Array[int] = []
	#for quality in qualities :
		##var actualQuality = reduceToValidQuality(quality, indices)
		#var newIndex = getIndexOfQuality(quality, indices)
		#if (newIndex != -1) :
			#indices.append(newIndex)
	#var retVal : Array[Equipment] = []
	#for index in indices :
		#retVal.append(itemPool[index])
	#return retVal
	#
#func reduceToValidQuality(startingQuality, excludedIndices) :
	#var currentQuality = startingQuality
	#while (true) :
		#var availableSpots = qualityCounts[currentQuality] - getQualityCountInList(currentQuality, excludedIndices)
		#if (availableSpots <= 0) :
			#currentQuality -= 1
		#if (availableSpots > 0 || currentQuality == -1) :
			#break
	#if (currentQuality == -1) :
		#return null
	#return currentQuality
	#
#func getIndexOfQuality(targetQuality, excludedIndices) :
	#var actualQuality = reduceToValidQuality(targetQuality, excludedIndices)
	#if (actualQuality == null) :
		#return -1
	#var adjustedCount = qualityCounts[actualQuality] - getQualityCountInList(actualQuality, excludedIndices)
	#var roll = randi_range(0,adjustedCount-1)
	#var currentCount = 0
	#for index in range(0, itemPool.size()) :
		#if (excludedIndices.find(index) != -1) :
			#continue
		#if (itemPool[index].equipmentGroups.quality == actualQuality) :
			#if (currentCount == roll) :
				#return index
			#else :
				#currentCount += 1
	##for index in range(0, itemPool.size()) :
		##if (excludedIndices.find(index) != -1) :
			##continue
		##if (itemPool[index].equipmentGroups.quality == targetQuality) :
			##if (currentCount == roll) :
				##return index
			##else :
				##currentCount += 1
	#return -1
			#
#func getQualityCountInList(targetQuality, list) :
	#var count = 0
	#for item in list :
		#if itemPool[item].equipmentGroups.quality == targetQuality :
			#count += 1
	#return count
		#
func updateQualityCounts() :
	qualityCounts = [0,0,0,0,0]
	for item in itemPool :
		var quality = item.equipmentGroups.quality
		qualityCounts[quality as int] += 1
