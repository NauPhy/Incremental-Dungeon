extends Node

const resourceLoader0 = preload("res://Resources/NewEquipment/NewEquipmentReferences.gd")
const resourceLoader1 = preload("res://Resources/OldEquipment/OldEquipmentReferences.gd")

func getEquipment(myName : String) :
	var try = resourceLoader0.getNewEquipment(myName)
	if (try != null) :
		return try
	return resourceLoader1.getOldEquipment(myName)

func getAllEquipment() -> Array[Equipment] :
	var list = resourceLoader0.getAllNewEquipment()
	list.append_array(resourceLoader1.getAllOldEquipment())
	return list
