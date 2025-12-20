extends Node

const signatureEquipmentList = {
	"orc_warlord" : "adamantium_greataxe",
	"iron_golem" : "blunderbuss",
	"death" : "deaths_scythe",
	"titan" : "crackling_greataxe"
}

var itemPool : Array[Equipment]
var qualityCounts : Array[int] = [0,0,0,0,0]

func reset(items) :
	itemPool = items
	
func getDrops(enemy) -> Array[Equipment] :
	updateQualityCounts()
	var dropCount = getDropCount()
	var qualities = getDropQualities(dropCount)
	var items = getItemsOfQualities(qualities)
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
	
func handleSignatureItem(enemy : ActorPreset, itemList : Array[Equipment]) -> Array[Equipment] :
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
	var retVal : Array[Equipment] = []
	for index in range(0,qualities.size()) :
		var targetQuality = qualities[index]
		for quality in range(targetQuality as int, qualityCounts.size()) :
			if (qualityCounts[quality] == 0) :
				targetQuality -= 1
		if (targetQuality < (EquipmentGroups.qualityEnum.common as int)) :
			continue
		var roll = randi_range(0,qualityCounts[targetQuality])
		var currentCount = 0
		for item in itemPool :
			if (item.equipmentGroups.quality == targetQuality) :
				if (currentCount == roll) :
					retVal.append(item)
					break;
				else :
					currentCount += 1
	return retVal
		
func updateQualityCounts() :
	for count in qualityCounts :
		count = 0
	for item in itemPool :
		var quality = item.equipmentGroups.quality
		qualityCounts[quality as int] += 1
