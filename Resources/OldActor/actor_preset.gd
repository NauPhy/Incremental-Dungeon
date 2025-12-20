@tool
extends Resource

class_name ActorPreset
@export var portrait : Texture2D = null
@export var text : String = "Undef Actor"
@export_multiline var description : String = ""
@export var MAXHP : float = -1
var HP : float = 1
@export var AR : float = -1
@export var DR : float = -1
@export var PHYSDEF : float = -1
@export var MAGDEF : float = -1
var dead : bool = false
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
func getAdjustedCopy(scalingFactor : float) -> ActorPreset :
	if (!enemyGroups.isEligible) :
		return self.duplicate()
	var strengthMultiplier
	if (enemyGroups.enemyQuality == enemyGroups.enemyQualityEnum.normal) :
		strengthMultiplier = 0.333
	elif (enemyGroups.enemyQuality == enemyGroups.enemyQualityEnum.veteran) :
		strengthMultiplier = 1.0
	elif (enemyGroups.enemyQuality == enemyGroups.enemyQualityEnum.elite) :
		strengthMultiplier = 1.67
	else :
		return self.duplicate()
	var powerLevel = referencePowerLevel*scalingFactor*strengthMultiplier
	var retVal : ActorPreset = ActorPreset.new()
	var eDPS = sqrt(powerLevel/(30/enemyGroups.glassCannonIndex))
	var eHP = powerLevel/eDPS
	var theoreticalDefense = sqrt(eHP/10/enemyGroups.HPToDefRatio)
	## Algebra'd from theoreticalDefense = AVERAGE(PHYSDEF, MAGDEF)
	## and defRatio = PHYSDEF/MAGDEF
	retVal.MAGDEF = (2*theoreticalDefense)/(enemyGroups.defRatio+1)
	retVal.PHYSDEF = enemyGroups.defRatio*retVal.MAGDEF
	retVal.HP = eHP/theoreticalDefense
	var product = eDPS*actions[0].getPower()/actions[0].getWarmup()
	retVal.AR = sqrt(product/enemyGroups.atkRatio)
	retVal.DR = product/retVal.AR
	return retVal
	
		
func getDrops(magicFind) -> Array[Equipment] :
	var retVal : Array[Equipment] = []
	for index in range(0,drops.size()) :
		if (randf() < dropChances[index]*magicFind) :
			retVal.append(drops[index])
	return retVal

func getHP() :
	return HP
func setHP(val) :
	HP = val
	
func getName() : return text
func getResourceName() : return resource_path.get_file().get_basename()
func getDesc() : return description
