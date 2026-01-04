@tool
extends Equipment

class_name Armor
@export var PHYSDEF : float = 0
@export var MAGDEF : float = 0
var type = Definitions.equipmentTypeEnum.armor

func getAdjustedCopy(scalingFactor : float) -> Armor :
	var retVal = super(scalingFactor) as Armor
	if (PHYSDEF == 0 && MAGDEF == 0) :
		retVal.calculateDefenses(scalingFactor, false)
	return retVal
	
func createSampleCopy() -> Armor :
	var retVal = super() as Armor
	if (PHYSDEF == 0 && MAGDEF == 0) :
		retVal.calculateDefenses(1, true)
	return retVal

const ratioMin = [0.500, 0.741, 1.350]
const ratioMax = [0.741, 1.350, 2.000]
const referenceDefense = 15.7426
func calculateDefenses(scalingFactor, useAverage) :
	var myQuality = equipmentGroups.quality
	var myType = equipmentGroups.armorClass
	var qualityFactor = pow(1.08, myQuality as int)
	var ratio
	if (useAverage) :
		ratio = (ratioMin[myType] + ratioMax[myType])/2.0
	else :
		ratio = randf_range(ratioMin[myType], ratioMax[myType])
	MAGDEF = (2*referenceDefense)/(1+ratio)
	PHYSDEF = 2*referenceDefense-MAGDEF
	MAGDEF *= scalingFactor * qualityFactor
	PHYSDEF *= scalingFactor * qualityFactor
	
func getSaveDictionary() -> Dictionary :
	var retVal = super()
	if (!Helpers.equipmentIsNew(self)) :
		return retVal
	retVal["PHYSDEF"] = PHYSDEF
	retVal["MAGDEF"] = MAGDEF
	return retVal
	
func createFromSaveDictionary(loadDict) -> Armor :
	var retVal = super(loadDict) as Armor
	if (!Helpers.equipmentIsNew(retVal)) :
		return retVal
	retVal.PHYSDEF = loadDict["PHYSDEF"]
	retVal.MAGDEF = loadDict["MAGDEF"]
	return retVal
