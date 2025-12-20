extends Node

func getEquipment(myName : String) :
	var try = MegaFile.getNewEquipment(myName)
	if (try != null) :
		return try
	return MegaFile.getOldEquipment(myName)

func getAllEquipment() -> Array[Equipment] :
	var list = MegaFile.getAllNewEquipment()
	list.append_array(MegaFile.getAllOldEquipment())
	return list
