@tool
extends Resource

class_name ActorPreset
@export var portrait : Texture2D = null
@export var text : String = "Undef Actor"
@export_multiline var description : String = ""
@export var MAXHP : float = -1
@export var AR : float = -1
@export var DR : float = -1
@export var PHYSDEF : float = -1
@export var MAGDEF : float = -1
@export var actions : Array[Action] = []
@export var drops : Array[Equipment] = []
@export var dropChances : Array[float] = []
@export var enemyGroups : EnemyGroups = EnemyGroups.new()

func setStat(type : Definitions.baseStatEnum, val : float) :
	if (Engine.is_editor_hint()) :
		return
	if (type == Definitions.baseStatEnum.MAXHP) : MAXHP = val
	elif (type == Definitions.baseStatEnum.AR) : AR = val
	elif (type == Definitions.baseStatEnum.DR) : DR = val
	elif (type == Definitions.baseStatEnum.PHYSDEF) : PHYSDEF = val
	elif (type == Definitions.baseStatEnum.MAGDEF) : MAGDEF = val
	else :
		return

func getStat(type : Definitions.baseStatEnum) -> float :
	if (Engine.is_editor_hint()) :
		return 0
	if (type == Definitions.baseStatEnum.MAXHP) : return MAXHP
	elif (type == Definitions.baseStatEnum.AR) : return AR
	elif (type == Definitions.baseStatEnum.DR) : return DR
	elif (type == Definitions.baseStatEnum.PHYSDEF) : return PHYSDEF
	elif (type == Definitions.baseStatEnum.MAGDEF) : return MAGDEF
	else :
		return -1

const referencePowerLevel = 442000000
var myScalingFactor : float = -1
func getAdjustedCopy(scalingFactor : float) -> ActorPreset :
	myScalingFactor = scalingFactor
	var retVal = self.duplicate()
	retVal.resourceName = self.getResourceName()
	if (!enemyGroups.isEligible) :
		return retVal
	var strengthMultiplier
	if (enemyGroups.enemyQuality == enemyGroups.enemyQualityEnum.normal) :
		strengthMultiplier = 0.333
	elif (enemyGroups.enemyQuality == enemyGroups.enemyQualityEnum.veteran) :
		strengthMultiplier = 1.0
	elif (enemyGroups.enemyQuality == enemyGroups.enemyQualityEnum.elite) :
		strengthMultiplier = 1.67
	else :
		return retVal
	var powerLevel = referencePowerLevel*scalingFactor*strengthMultiplier
	var eDPS = sqrt(powerLevel/(30/enemyGroups.glassCannonIndex))
	var eHP = powerLevel/eDPS
	var theoreticalDefense = sqrt(eHP/10/enemyGroups.HPToDefRatio)
	## Algebra'd from theoreticalDefense = AVERAGE(PHYSDEF, MAGDEF)
	## and defRatio = PHYSDEF/MAGDEF
	retVal.MAGDEF = (2*theoreticalDefense)/(enemyGroups.defRatio+1)
	retVal.PHYSDEF = enemyGroups.defRatio*retVal.MAGDEF
	retVal.MAXHP = eHP/theoreticalDefense
	if (!(actions[0].has_method("getPower"))) :
		retVal.AR = 0
		retVal.DR = 0
	else :
		var product = eDPS*actions[0].getPower()/actions[0].getWarmup()
		retVal.AR = sqrt(product/enemyGroups.atkRatio)
		retVal.DR = product/retVal.AR
	retVal.resourceName = getResourceName()
	return retVal
	
		
func getDrops(magicFind) -> Array[Equipment] :
	var retVal : Array[Equipment] = []
	for index in range(0,drops.size()) :
		if (randf() < dropChances[index]*magicFind) :
			retVal.append(drops[index])
	return retVal
	
func getName() : return text
var resourceName : String = ""
func getResourceName() : 
	if (resourceName == "") :
		resourceName = resource_path.get_file().get_basename()
	return resourceName
func getDesc() : return description

func getSaveDictionary() -> Dictionary :
	var retVal = {}
	if (!enemyGroups.isEligible) :
		return retVal
	retVal["name"] = getResourceName()
	retVal["myScalingFactor"] = myScalingFactor
	return retVal
	
static func createFromSaveDictionary(val : Dictionary) -> ActorPreset :
	if (val.is_empty()) :
		return ActorPreset.new()
	var scalingFactor = val["myScalingFactor"]
	if (scalingFactor != -1) :
		return EnemyDatabase.getEnemy(val["name"]).getAdjustedCopy(scalingFactor)
	else :
		return EnemyDatabase.getEnemy(val["name"]).duplicate()
