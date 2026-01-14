@tool
extends Equipment

class_name Weapon
@export var scaling : Dictionary = {}
@export var attackBonus : float
@export var basicAttack : AttackAction
@export var isUnarmed : bool = false
var type = Definitions.equipmentTypeEnum.weapon

func _init() :
	resetScaling()

func reset() :
	super()
	resetScaling()
	
func resetNew() :
	super()
	if (scaling == null || scaling == {} || scaling.keys().size() != Definitions.attributeDictionary.keys().size()) :
		resetScaling()
	
func resetScaling() :
	scaling = {}
	for key in Definitions.attributeDictionary.keys() :
		scaling[Definitions.attributeDictionary[key]] = 0.0
		
func getScaling(key : int) :
	return scaling[Definitions.attributeDictionary[key as Definitions.attributeEnum]]
	
func getScalingArray() -> Array[float] :
	var retVal : Array[float] = []
	for key in scaling.keys() :
		retVal.append(scaling[key])
	return retVal
		
##Where E = 1 and S = 6, letter = log1.5(x/0.7)+2
## E- (0-0.0833) (0.0417)
## E (0.0833-0.167) (0.125)
## E+ (0.167-0.250) (0.209)
## D- (0.250-0.333) (0.292)
## D (0.333-0.417) (0.375)
## D+ (0.417-0.500) (0.459)
## C- (0.500-0.583) (0.542)
## C (0.583-0.667) (0.625)
## C+ (0.667-0.75) (0.708)
## B- (0.750-0.833) (0.792)
## B (0.833-0.917) (0.875)
## B+ (0.917-1.00) (0.959)
## A- (1.00-1.08) (1.04)
## A (1.08-1.17) (1.125)
## A+ (1.17-1.25) (1.21)
## S- (1.25-1.33) (1.29)
## S (1.33-1.42) (1.375)
## S+ (1.42-1.5) (1.46)
## S++ is reserved for legendary weapons that scale off of 1 stat only
static func scalingToLetter(scalingVal : float) -> String :
	if (scalingVal < -0.001) :
		return "N"
	elif (is_zero_approx(scalingVal)) :
		return "--"
	elif (scalingVal <= 0.25) :
		return "E"
	elif (scalingVal <= 0.5) :
		return "D"
	elif (scalingVal <= 0.75) :
		return "C"
	elif (scalingVal <= 1) :
		return "B"
	elif (scalingVal <= 1.25) :
		return "A"
	elif (scalingVal <= 1.50) :
		return "S"
	else :
		return "S+"

const referenceValue = 0.3429401
func getAdjustedCopy(scalingFactor : float) -> Weapon :
	var retVal = super(scalingFactor) as Weapon##not sure if copies weapon properties
	retVal.attackBonus *= scalingFactor*referenceValue
	return retVal
	
func getSaveDictionary() -> Dictionary :
	var retVal = super() 
	if (!Helpers.equipmentIsNew(self)) :
		return retVal
	retVal["attack"] = attackBonus
	return retVal

func createFromSaveDictionary(loadDict : Dictionary) -> Weapon :
	var retVal = super(loadDict) as Weapon
	if (!Helpers.equipmentIsNew(retVal)) :
		return retVal
	retVal.attackBonus = loadDict["attack"]
	return retVal

func getType() :
	return type
