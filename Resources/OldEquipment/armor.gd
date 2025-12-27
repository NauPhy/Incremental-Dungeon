@tool
extends Equipment

class_name Armor
@export var PHYSDEF : float = 0
@export var MAGDEF : float = 0
var type = Definitions.equipmentTypeEnum.armor

func getAdjustedCopy(scalingFactor : float) -> Armor :
	var retVal = super(scalingFactor) as Armor
	if (PHYSDEF == 0 && MAGDEF == 0) :
		retVal.calculateDefenses(scalingFactor)
	return retVal

const ratioMin = [0.500, 0.741, 1.350]
const ratioMax = [0.741, 1.350, 2.000]
const referenceDefense = 186
func calculateDefenses(scalingFactor) :
	var myQuality = equipmentGroups.quality
	var myType = equipmentGroups.armorClass
	var qualityFactor = pow(1.08, myQuality as int)
	var ratio = randf_range(ratioMin[myType], ratioMax[myType])
	MAGDEF = (2*referenceDefense)/(1+ratio)
	PHYSDEF = 2*referenceDefense-MAGDEF
	MAGDEF *= scalingFactor * qualityFactor
	PHYSDEF *= scalingFactor * qualityFactor
	
