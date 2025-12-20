extends Node

const AccessoriesDictionary = {
	"clown_horn" : preload("res://Resources/OldEquipment/Accessories/clown_horn.tres"),
	"kiwi" : preload("res://Resources/OldEquipment/Accessories/kiwi.tres"),
	"magpie_eye" : preload("res://Resources/OldEquipment/Accessories/magpie_eye.tres"),
	"mandragora_potion" : preload("res://Resources/OldEquipment/Accessories/mandragora_potion.tres"),
	"manticore_tooth" : preload("res://Resources/OldEquipment/Accessories/manticore_tooth.tres"),
	"manticore_venom" : preload("res://Resources/OldEquipment/Accessories/manticore_venom.tres"),
	"ram_horn" : preload("res://Resources/OldEquipment/Accessories/ram_horn.tres")}


static func getAccessories(resourceName : String) :
	return AccessoriesDictionary.get(resourceName)

const ArmorDictionary = {
	"casual" : preload("res://Resources/OldEquipment/Armor/casual.tres"),
	"enchanted_robes" : preload("res://Resources/OldEquipment/Armor/enchanted_robes.tres"),
	"feathered_cloak" : preload("res://Resources/OldEquipment/Armor/feathered_cloak.tres"),
	"lion_armor" : preload("res://Resources/OldEquipment/Armor/lion_armor.tres"),
	"manticore_armor" : preload("res://Resources/OldEquipment/Armor/manticore_armor.tres"),
	"mole_armor" : preload("res://Resources/OldEquipment/Armor/mole_armor.tres"),
	"scraps" : preload("res://Resources/OldEquipment/Armor/scraps.tres")}


static func getArmor(resourceName : String) :
	return ArmorDictionary.get(resourceName)

const CurrencyDictionary = {
	"pebble" : preload("res://Resources/OldEquipment/Currency/pebble.tres")}


static func getCurrency(resourceName : String) :
	return CurrencyDictionary.get(resourceName)

const WeaponsDictionary = {
	"bat_bat" : preload("res://Resources/OldEquipment/Weapons/bat_bat.tres"),
	"bat_staff" : preload("res://Resources/OldEquipment/Weapons/bat_staff.tres"),
	"cat_claws" : preload("res://Resources/OldEquipment/Weapons/cat_claws.tres"),
	"executioners_sword" : preload("res://Resources/OldEquipment/Weapons/executioners_sword.tres"),
	"goose_flail" : preload("res://Resources/OldEquipment/Weapons/goose_flail.tres"),
	"kiwi_dagger" : preload("res://Resources/OldEquipment/Weapons/kiwi_dagger.tres"),
	"magic_stick_int" : preload("res://Resources/OldEquipment/Weapons/magic_stick_int.tres"),
	"magic_stick_str" : preload("res://Resources/OldEquipment/Weapons/magic_stick_str.tres"),
	"manticore_dart" : preload("res://Resources/OldEquipment/Weapons/manticore_dart.tres"),
	"manticore_wand" : preload("res://Resources/OldEquipment/Weapons/manticore_wand.tres"),
	"mole_pickaxe" : preload("res://Resources/OldEquipment/Weapons/mole_pickaxe.tres"),
	"ram_spear" : preload("res://Resources/OldEquipment/Weapons/ram_spear.tres"),
	"ruby_staff" : preload("res://Resources/OldEquipment/Weapons/ruby_staff.tres"),
	"shiv" : preload("res://Resources/OldEquipment/Weapons/shiv.tres"),
	"sling" : preload("res://Resources/OldEquipment/Weapons/sling.tres"),
	"unarmed_Fighter" : preload("res://Resources/OldEquipment/Weapons/unarmed_Fighter.tres"),
	"unarmed_Mage" : preload("res://Resources/OldEquipment/Weapons/unarmed_Mage.tres"),
	"unarmed_Rogue" : preload("res://Resources/OldEquipment/Weapons/unarmed_Rogue.tres")}


static func getWeapons(resourceName : String) :
	return WeaponsDictionary.get(resourceName)

static func getOldEquipment(resourceName : String) :
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

static func getAllOldEquipment() :
	var retVal : Array = []
	retVal.append_array(AccessoriesDictionary.values())
	retVal.append_array(ArmorDictionary.values())
	retVal.append_array(CurrencyDictionary.values())
	retVal.append_array(WeaponsDictionary.values())
	return retVal
