extends Node

const AccessoriesDictionary = {
}


static func getAccessories(resourceName : String) :
	return AccessoriesDictionary.get(resourceName)

const ArmorDictionary = {
}


static func getArmor(resourceName : String) :
	return ArmorDictionary.get(resourceName)

const CurrencyDictionary = {
}


static func getCurrency(resourceName : String) :
	return CurrencyDictionary.get(resourceName)

const WeaponsDictionary = {
	"arming_sword" : preload("res://Resources/NewEquipment/Weapons/arming_sword.tres"),
	"bardiche" : preload("res://Resources/NewEquipment/Weapons/bardiche.tres"),
	"club" : preload("res://Resources/NewEquipment/Weapons/club.tres"),
	"crossbow" : preload("res://Resources/NewEquipment/Weapons/crossbow.tres"),
	"cutlass" : preload("res://Resources/NewEquipment/Weapons/cutlass.tres"),
	"dagger" : preload("res://Resources/NewEquipment/Weapons/dagger.tres"),
	"earth_staff" : preload("res://Resources/NewEquipment/Weapons/earth_staff.tres"),
	"emerald_staff" : preload("res://Resources/NewEquipment/Weapons/emerald_staff.tres"),
	"estoc" : preload("res://Resources/NewEquipment/Weapons/estoc.tres"),
	"fire_staff" : preload("res://Resources/NewEquipment/Weapons/fire_staff.tres"),
	"flail" : preload("res://Resources/NewEquipment/Weapons/flail.tres"),
	"flamberge" : preload("res://Resources/NewEquipment/Weapons/flamberge.tres"),
	"force_wand" : preload("res://Resources/NewEquipment/Weapons/force_wand.tres"),
	"great_flail" : preload("res://Resources/NewEquipment/Weapons/great_flail.tres"),
	"greataxe" : preload("res://Resources/NewEquipment/Weapons/greataxe.tres"),
	"greatsword" : preload("res://Resources/NewEquipment/Weapons/greatsword.tres"),
	"halberd" : preload("res://Resources/NewEquipment/Weapons/halberd.tres"),
	"hammer" : preload("res://Resources/NewEquipment/Weapons/hammer.tres"),
	"handaxe" : preload("res://Resources/NewEquipment/Weapons/handaxe.tres"),
	"ice_staff" : preload("res://Resources/NewEquipment/Weapons/ice_staff.tres"),
	"ice_sword" : preload("res://Resources/NewEquipment/Weapons/ice_sword.tres"),
	"katana" : preload("res://Resources/NewEquipment/Weapons/katana.tres"),
	"kunai" : preload("res://Resources/NewEquipment/Weapons/kunai.tres"),
	"lance" : preload("res://Resources/NewEquipment/Weapons/lance.tres"),
	"lightning_rod" : preload("res://Resources/NewEquipment/Weapons/lightning_rod.tres"),
	"long_axe" : preload("res://Resources/NewEquipment/Weapons/long_axe.tres"),
	"longbow" : preload("res://Resources/NewEquipment/Weapons/longbow.tres"),
	"longsword" : preload("res://Resources/NewEquipment/Weapons/longsword.tres"),
	"mace" : preload("res://Resources/NewEquipment/Weapons/mace.tres"),
	"morning_star" : preload("res://Resources/NewEquipment/Weapons/morning_star.tres"),
	"occult_wand" : preload("res://Resources/NewEquipment/Weapons/occult_wand.tres"),
	"pike" : preload("res://Resources/NewEquipment/Weapons/pike.tres"),
	"rapier" : preload("res://Resources/NewEquipment/Weapons/rapier.tres"),
	"recurve_bow" : preload("res://Resources/NewEquipment/Weapons/recurve_bow.tres"),
	"rondel_dagger" : preload("res://Resources/NewEquipment/Weapons/rondel_dagger.tres"),
	"ruby_staff_new" : preload("res://Resources/NewEquipment/Weapons/ruby_staff_new.tres"),
	"scimitar" : preload("res://Resources/NewEquipment/Weapons/scimitar.tres"),
	"scythe" : preload("res://Resources/NewEquipment/Weapons/scythe.tres"),
	"shamshir" : preload("res://Resources/NewEquipment/Weapons/shamshir.tres"),
	"shortbow" : preload("res://Resources/NewEquipment/Weapons/shortbow.tres"),
	"shortsword" : preload("res://Resources/NewEquipment/Weapons/shortsword.tres"),
	"shotel" : preload("res://Resources/NewEquipment/Weapons/shotel.tres"),
	"sling_new" : preload("res://Resources/NewEquipment/Weapons/sling_new.tres"),
	"spear" : preload("res://Resources/NewEquipment/Weapons/spear.tres"),
	"star_rod" : preload("res://Resources/NewEquipment/Weapons/star_rod.tres"),
	"throwing_axe" : preload("res://Resources/NewEquipment/Weapons/throwing_axe.tres"),
	"topaz_staff" : preload("res://Resources/NewEquipment/Weapons/topaz_staff.tres"),
	"trident" : preload("res://Resources/NewEquipment/Weapons/trident.tres"),
	"umbral_dagger" : preload("res://Resources/NewEquipment/Weapons/umbral_dagger.tres"),
	"wakizashi" : preload("res://Resources/NewEquipment/Weapons/wakizashi.tres"),
	"water_staff" : preload("res://Resources/NewEquipment/Weapons/water_staff.tres"),
	"whip" : preload("res://Resources/NewEquipment/Weapons/whip.tres")}


static func getWeapons(resourceName : String) :
	return WeaponsDictionary.get(resourceName)

static func getNewEquipment(resourceName : String) :
	var retVal
	retVal = AccessoriesDictionary.get(resourceName)
	if retVal != null : return retVal
	retVal = ArmorDictionary.get(resourceName)
	if retVal != null : return retVal
	retVal = CurrencyDictionary.get(resourceName)
	if retVal != null : return retVal
	retVal = WeaponsDictionary.get(resourceName)
	if retVal != null : return retVal
	return null

static func getDictionary(type : String) :
	if type == "Accessories" : 
		return AccessoriesDictionary

	if type == "Armor" : 
		return ArmorDictionary

	if type == "Currency" : 
		return CurrencyDictionary

	if type == "Weapons" : 
		return WeaponsDictionary

static func getAllNewEquipment() :
	var retVal : Array = []
	retVal.append_array(AccessoriesDictionary.values())
	retVal.append_array(ArmorDictionary.values())
	retVal.append_array(CurrencyDictionary.values())
	retVal.append_array(WeaponsDictionary.values())
	return retVal
