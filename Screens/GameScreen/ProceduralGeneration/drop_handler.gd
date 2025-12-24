extends Node

const signatureEquipmentList = {
	"orc_warlord" : "adamantium_greataxe",
	"iron_golem" : "blunderbuss",
	"death" : "deaths_scythe",
	"titan" : "crackling_greataxe",
	"lich" : "wand_of_disintigration", ##temporary??
	## add legendary trident variant for the fish lady that stabs you?
	"water_elemental" : "staff_of_water",
	"fire_elemental" : "staff_of_fire",
	"ice_elemental" : "staff_of_ice",
	"deathcap" : "staff_of_earth",##temporary
	"electric_eel" : "lightning_rod" 
}

var itemPool : Array
var qualityCounts : Array[int] = [0,0,0,0,0]

func reset(items) :
	itemPool = items
	
func getDrops(enemy) -> Array :
	updateQualityCounts()
	var dropCount = getDropCount()
	var qualities = getDropQualities(dropCount)
	var items = getItemsOfQualities(qualities)
	if (items.size() == 0) :
		print("problem")
	return handleSignatureItem(enemy, items)
	
func getDropCount() :
	var roll = randi_range(0,1)
	if (roll == 0) :
		return 1
	else :
		roll = randi_range(0,2)
		if (roll == 0) :
			return 3
	return 2
	
func handleSignatureItem(enemy : ActorPreset, itemList : Array) -> Array :
	var retVal = itemList
	var enemyName = enemy.resource_path.get_file().get_basename()
	if (signatureEquipmentList.get(enemyName) == null) :
		return retVal
	var roll = randi_range(0,3)
	if (roll != 0) :
		return retVal
	var signatureItem : Equipment = EquipmentDatabase.getEquipment(signatureEquipmentList[enemyName])
	if (retVal.is_empty()) :
		retVal.append(signatureItem)
	else :
		retVal[0] = signatureItem
	return retVal
	
const chances : Dictionary = {
	1 : 0.222,
	2 : 0.167,
	3 : 0.148
}
func getDropChances(count : int) -> Array[float] :
	var retVal : Array[float] = []
	for index in range(0,count) :
		retVal.append(chances[count])
	return retVal
	
const qualityThresholds : Array[int] = [1.5,5,15,40,100]
func getDropQualities(count : int) -> Array[EquipmentGroups.qualityEnum] :
	var retVal : Array[EquipmentGroups.qualityEnum] = []
	for index in range(0,count) :
		var roll = randf_range(0,100)
		#var quality
		for qualityIndex in range(0,qualityThresholds.size()) :
			if (roll <= qualityThresholds[qualityIndex]) :
				retVal.append((4-qualityIndex) as EquipmentGroups.qualityEnum)
				break
	return retVal
	
func getItemsOfQualities(qualities : Array[EquipmentGroups.qualityEnum]) :
	var indices : Array[int] = []
	for quality in qualities :
		#var actualQuality = reduceToValidQuality(quality, indices)
		var newIndex = getIndexOfQuality(quality, indices)
		if (newIndex != -1) :
			indices.append(newIndex)
	var retVal : Array[Equipment] = []
	for index in indices :
		retVal.append(itemPool[index])
	return retVal
	
func reduceToValidQuality(startingQuality, excludedIndices) :
	var currentQuality = startingQuality
	while (true) :
		var availableSpots = qualityCounts[currentQuality] - getQualityCountInList(currentQuality, excludedIndices)
		if (availableSpots <= 0) :
			currentQuality -= 1
		if (availableSpots > 0 || currentQuality == -1) :
			break
	if (currentQuality == -1) :
		return null
	return currentQuality
	
func getIndexOfQuality(targetQuality, excludedIndices) :
	var actualQuality = reduceToValidQuality(targetQuality, excludedIndices)
	if (actualQuality == null) :
		return -1
	var adjustedCount = qualityCounts[actualQuality] - getQualityCountInList(actualQuality, excludedIndices)
	var roll = randi_range(0,adjustedCount-1)
	var currentCount = 0
	for index in range(0, itemPool.size()) :
		if (excludedIndices.find(index) != -1) :
			continue
		if (itemPool[index].equipmentGroups.quality == actualQuality) :
			if (currentCount == roll) :
				return index
			else :
				currentCount += 1
	#for index in range(0, itemPool.size()) :
		#if (excludedIndices.find(index) != -1) :
			#continue
		#if (itemPool[index].equipmentGroups.quality == targetQuality) :
			#if (currentCount == roll) :
				#return index
			#else :
				#currentCount += 1
	return -1
			
func getQualityCountInList(targetQuality, list) :
	var count = 0
	for item in list :
		if itemPool[item].equipmentGroups.quality == targetQuality :
			count += 1
	return count
		
func updateQualityCounts() :
	qualityCounts = [0,0,0,0,0]
	for item in itemPool :
		var quality = item.equipmentGroups.quality
		qualityCounts[quality as int] += 1
