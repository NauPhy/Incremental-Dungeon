extends "res://Graphic Elements/Shop/shop_window.gd"
var shopType : Definitions.equipmentTypeEnum
func getShopType() :
	return shopType
	
func setFromDetails(det : ShopDetails) :
	if (det.shopName == "Armory") :
		shopType = Definitions.equipmentTypeEnum.armor
	elif (det.shopName == "Weaponsmith") :
		shopType = Definitions.equipmentTypeEnum.weapon
	Shopping._on_equipment_shop_launched(shopType)
	super(det)
	
func _process(_delta) :
	var remaining = Shopping.getEquipmentTime(shopType)
#
#func getReforgeHovered() :
	#return $VBoxContainer/Shop/ReforgeColumn.getReforgeHovered()
	#
#func setFromDetails(det : ShopDetails) :
	#const refStr = "Reforge"
	#var newDet = det
	#var myReforgeName : String = "invalid"
	#var myReforgeIndex : int = 0
	#var columns = newDet.shopContents
	#for index in range(0,columns.size()) :
		#if ((columns[index].columnName as String).substr(0,refStr.length()) == refStr) :
			#myReforgeName = columns[index].columnName
			#myReforgeIndex = index
			#newDet.shopContents.remove_at(index)
			#break
	#$VBoxContainer/Shop/ReforgeColumn.setCategoryName(myReforgeName)
	#super(newDet)
	#$VBoxContainer/Shop.move_child($VBoxContainer/Shop/ReforgeColumn, myReforgeIndex)
	#
