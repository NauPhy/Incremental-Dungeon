extends Node

const WeaponsDictionary = {
	"adamantium_greataxe" : preload("res://Resources/NewEquipment/Weapons/adamantium_greataxe.tres"),
	"arming_sword" : preload("res://Resources/NewEquipment/Weapons/arming_sword.tres"),
	"bardiche" : preload("res://Resources/NewEquipment/Weapons/bardiche.tres"),
	"blade_of_darkness" : preload("res://Resources/NewEquipment/Weapons/blade_of_darkness.tres"),
	"blade_of_sin" : preload("res://Resources/NewEquipment/Weapons/blade_of_sin.tres"),
	"blunderbuss" : preload("res://Resources/NewEquipment/Weapons/blunderbuss.tres"),
	"club" : preload("res://Resources/NewEquipment/Weapons/club.tres"),
	"crackling_greataxe" : preload("res://Resources/NewEquipment/Weapons/crackling_greataxe.tres"),
	"crossbow" : preload("res://Resources/NewEquipment/Weapons/crossbow.tres"),
	"crystal_sword" : preload("res://Resources/NewEquipment/Weapons/crystal_sword.tres"),
	"cutlass" : preload("res://Resources/NewEquipment/Weapons/cutlass.tres"),
	"dagger" : preload("res://Resources/NewEquipment/Weapons/dagger.tres"),
	"deaths_scythe" : preload("res://Resources/NewEquipment/Weapons/deaths_scythe.tres"),
	"diamond_staff" : preload("res://Resources/NewEquipment/Weapons/diamond_staff.tres"),
	"divine_greatmace" : preload("res://Resources/NewEquipment/Weapons/divine_greatmace.tres"),
	"earth_hammer" : preload("res://Resources/NewEquipment/Weapons/earth_hammer.tres"),
	"earth_staff" : preload("res://Resources/NewEquipment/Weapons/earth_staff.tres"),
	"emerald_staff" : preload("res://Resources/NewEquipment/Weapons/emerald_staff.tres"),
	"fire_spitter" : preload("res://Resources/NewEquipment/Weapons/fire_spitter.tres"),
	"fire_staff" : preload("res://Resources/NewEquipment/Weapons/fire_staff.tres"),
	"flail" : preload("res://Resources/NewEquipment/Weapons/flail.tres"),
	"flamberge" : preload("res://Resources/NewEquipment/Weapons/flamberge.tres"),
	"force_wand" : preload("res://Resources/NewEquipment/Weapons/force_wand.tres"),
	"frostfire_twindaggers" : preload("res://Resources/NewEquipment/Weapons/frostfire_twindaggers.tres"),
	"great_flail" : preload("res://Resources/NewEquipment/Weapons/great_flail.tres"),
	"greataxe" : preload("res://Resources/NewEquipment/Weapons/greataxe.tres"),
	"greatsword" : preload("res://Resources/NewEquipment/Weapons/greatsword.tres"),
	"halberd" : preload("res://Resources/NewEquipment/Weapons/halberd.tres"),
	"hammer" : preload("res://Resources/NewEquipment/Weapons/hammer.tres"),
	"handaxe" : preload("res://Resources/NewEquipment/Weapons/handaxe.tres"),
	"hungering_blade" : preload("res://Resources/NewEquipment/Weapons/hungering_blade.tres"),
	"ice_lance" : preload("res://Resources/NewEquipment/Weapons/ice_lance.tres"),
	"ice_staff" : preload("res://Resources/NewEquipment/Weapons/ice_staff.tres"),
	"ice_sword" : preload("res://Resources/NewEquipment/Weapons/ice_sword.tres"),
	"katana" : preload("res://Resources/NewEquipment/Weapons/katana.tres"),
	"khopesh" : preload("res://Resources/NewEquipment/Weapons/khopesh.tres"),
	"kunai" : preload("res://Resources/NewEquipment/Weapons/kunai.tres"),
	"lance" : preload("res://Resources/NewEquipment/Weapons/lance.tres"),
	"lightning_rod" : preload("res://Resources/NewEquipment/Weapons/lightning_rod.tres"),
	"long_axe" : preload("res://Resources/NewEquipment/Weapons/long_axe.tres"),
	"longbow" : preload("res://Resources/NewEquipment/Weapons/longbow.tres"),
	"longsword" : preload("res://Resources/NewEquipment/Weapons/longsword.tres"),
	"mace" : preload("res://Resources/NewEquipment/Weapons/mace.tres"),
	"magma_greatsword" : preload("res://Resources/NewEquipment/Weapons/magma_greatsword.tres"),
	"masamune" : preload("res://Resources/NewEquipment/Weapons/masamune.tres"),
	"morning_star" : preload("res://Resources/NewEquipment/Weapons/morning_star.tres"),
	"muramasa" : preload("res://Resources/NewEquipment/Weapons/muramasa.tres"),
	"occult_wand" : preload("res://Resources/NewEquipment/Weapons/occult_wand.tres"),
	"pike" : preload("res://Resources/NewEquipment/Weapons/pike.tres"),
	"rapier" : preload("res://Resources/NewEquipment/Weapons/rapier.tres"),
	"recurve_bow" : preload("res://Resources/NewEquipment/Weapons/recurve_bow.tres"),
	"rhomphaia" : preload("res://Resources/NewEquipment/Weapons/rhomphaia.tres"),
	"rondel_dagger" : preload("res://Resources/NewEquipment/Weapons/rondel_dagger.tres"),
	"ruby_staff_new" : preload("res://Resources/NewEquipment/Weapons/ruby_staff_new.tres"),
	"sapphire_staff" : preload("res://Resources/NewEquipment/Weapons/sapphire_staff.tres"),
	"scimitar" : preload("res://Resources/NewEquipment/Weapons/scimitar.tres"),
	"scythe" : preload("res://Resources/NewEquipment/Weapons/scythe.tres"),
	"shamshir" : preload("res://Resources/NewEquipment/Weapons/shamshir.tres"),
	"shortbow" : preload("res://Resources/NewEquipment/Weapons/shortbow.tres"),
	"shortsword" : preload("res://Resources/NewEquipment/Weapons/shortsword.tres"),
	"shotel" : preload("res://Resources/NewEquipment/Weapons/shotel.tres"),
	"sling_new" : preload("res://Resources/NewEquipment/Weapons/sling_new.tres"),
	"spear" : preload("res://Resources/NewEquipment/Weapons/spear.tres"),
	"staff_of_pain" : preload("res://Resources/NewEquipment/Weapons/staff_of_pain.tres"),
	"star_rod" : preload("res://Resources/NewEquipment/Weapons/star_rod.tres"),
	"throwing_axe" : preload("res://Resources/NewEquipment/Weapons/throwing_axe.tres"),
	"topaz_staff" : preload("res://Resources/NewEquipment/Weapons/topaz_staff.tres"),
	"trident" : preload("res://Resources/NewEquipment/Weapons/trident.tres"),
	"umbral_dagger" : preload("res://Resources/NewEquipment/Weapons/umbral_dagger.tres"),
	"void_blade" : preload("res://Resources/NewEquipment/Weapons/void_blade.tres"),
	"wand_of_disintigration" : preload("res://Resources/NewEquipment/Weapons/wand_of_disintigration.tres"),
	"warbrand" : preload("res://Resources/NewEquipment/Weapons/warbrand.tres"),
	"water_staff" : preload("res://Resources/NewEquipment/Weapons/water_staff.tres"),
	"whip" : preload("res://Resources/NewEquipment/Weapons/whip.tres")}


static func getWeapons(resourceName : String) :
	return WeaponsDictionary.get(resourceName)

static func getNewEquipment(resourceName : String) :
	if (WeaponsDictionary.has(resourceName)) :
		return WeaponsDictionary[resourceName]
	return null

static func getDictionary(type : String) :
	if type == "Weapons" : 
		return WeaponsDictionary
static func getAllNewEquipment() -> Array :
	var retVal : Array = []
	retVal.append_array(WeaponsDictionary.values())
	return retVal
