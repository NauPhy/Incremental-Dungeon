@tool
extends Resource

class_name Equipment
@export var title : String = "Sample title"
@export_multiline var description : String = "Sample description"
@export var myPacket : ModifierPacket = ModifierPacket.new()

## For procedural generation
@export var equipmentGroups : EquipmentGroups = EquipmentGroups.new()

var resourceName : String = ""
func getItemName() :
	if (resourceName == "") :
		resourceName = resource_path.get_file().get_basename()
	return resourceName
func getAdjustedCopy(_scalingFactor : float) -> Equipment :
	var retVal = self.duplicate()
	retVal.resourceName = getItemName()
	return retVal
func createSampleCopy() -> Equipment :
	return getAdjustedCopy(1)

func reset() :
	myPacket = ModifierPacket.new()
func resetNew() :
	if (myPacket == null) :
		myPacket = ModifierPacket.new()
	elif (myPacket.attributeMods.size() != Definitions.attributeDictionary.keys().size()) :
		myPacket = ModifierPacket.new()
	elif (myPacket.statMods.size() != Definitions.baseStatDictionary.keys().size()) :
		myPacket = ModifierPacket.new()
func resetOtherModsIfWrong() :
	var localReset : bool = myPacket.otherMods.size() != Definitions.otherStatDictionary.keys().size()
	if (localReset) :
		var oldPacket = myPacket.duplicate()
		myPacket = ModifierPacket.new()
		myPacket.attributeMods = oldPacket.attributeMods
		myPacket.statMods = oldPacket.statMods

func getModifierPacket() -> ModifierPacket :
	return myPacket
func getName() :
	return title
func getType() :
	return Definitions.equipmentTypeEnum.currency
func getSaveDictionary() -> Dictionary :
	var retVal : Dictionary = {}
	retVal["resourceName"] = resourceName
	return retVal
func createFromSaveDictionary(loadDict : Dictionary) -> Equipment :
	var resource = EquipmentDatabase.getEquipment(loadDict["resourceName"])
	if (!Helpers.equipmentIsNew(resource)) :
		return resource
	var retVal = resource.duplicate()
	retVal.resourceName = loadDict["resourceName"]
	return retVal
