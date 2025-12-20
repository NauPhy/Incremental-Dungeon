#This auto-generated singleton preloads small nodes such as equipment and can instantiate them as needed
extends Node

#Equipment section
const equipmentSceneDictionary = {
#Weapon
	"arming_sword" : preload("res://ScenePreloads/Equipment_new/Weapon/arming_sword.tscn"),
	"estoc" : preload("res://ScenePreloads/Equipment_new/Weapon/estoc.tscn"),
	"rapier" : preload("res://ScenePreloads/Equipment_new/Weapon/rapier.tscn"),
	"ruby_staff_new" : preload("res://ScenePreloads/Equipment_new/Weapon/ruby_staff_new.tscn"),
	"shortsword" : preload("res://ScenePreloads/Equipment_new/Weapon/shortsword.tscn"),
	"sling_new" : preload("res://ScenePreloads/Equipment_new/Weapon/sling_new.tscn"),
	"bat_bat" : preload("res://ScenePreloads/Equipment_old/Weapon/bat_bat.tscn"),
	"bat_staff" : preload("res://ScenePreloads/Equipment_old/Weapon/bat_staff.tscn"),
	"cat_claws" : preload("res://ScenePreloads/Equipment_old/Weapon/cat_claws.tscn"),
	"executioners_sword" : preload("res://ScenePreloads/Equipment_old/Weapon/executioners_sword.tscn"),
	"goose_flail" : preload("res://ScenePreloads/Equipment_old/Weapon/goose_flail.tscn"),
	"kiwi_dagger" : preload("res://ScenePreloads/Equipment_old/Weapon/kiwi_dagger.tscn"),
	"magic_stick_int" : preload("res://ScenePreloads/Equipment_old/Weapon/magic_stick_int.tscn"),
	"magic_stick_str" : preload("res://ScenePreloads/Equipment_old/Weapon/magic_stick_str.tscn"),
	"manticore_dart" : preload("res://ScenePreloads/Equipment_old/Weapon/manticore_dart.tscn"),
	"manticore_wand" : preload("res://ScenePreloads/Equipment_old/Weapon/manticore_wand.tscn"),
	"mole_pickaxe" : preload("res://ScenePreloads/Equipment_old/Weapon/mole_pickaxe.tscn"),
	"ram_spear" : preload("res://ScenePreloads/Equipment_old/Weapon/ram_spear.tscn"),
	"ruby_staff" : preload("res://ScenePreloads/Equipment_old/Weapon/ruby_staff.tscn"),
	"shiv" : preload("res://ScenePreloads/Equipment_old/Weapon/shiv.tscn"),
	"sling" : preload("res://ScenePreloads/Equipment_old/Weapon/sling.tscn"),
	"unarmed_Fighter" : preload("res://ScenePreloads/Equipment_old/Weapon/unarmed_Fighter.tscn"),
	"unarmed_Mage" : preload("res://ScenePreloads/Equipment_old/Weapon/unarmed_Mage.tscn"),
	"unarmed_Rogue" : preload("res://ScenePreloads/Equipment_old/Weapon/unarmed_Rogue.tscn"),
#Armor
	"casual" : preload("res://ScenePreloads/Equipment_old/Armor/casual.tscn"),
	"enchanted_robes" : preload("res://ScenePreloads/Equipment_old/Armor/enchanted_robes.tscn"),
	"feathered_cloak" : preload("res://ScenePreloads/Equipment_old/Armor/feathered_cloak.tscn"),
	"lion_armor" : preload("res://ScenePreloads/Equipment_old/Armor/lion_armor.tscn"),
	"manticore_armor" : preload("res://ScenePreloads/Equipment_old/Armor/manticore_armor.tscn"),
	"mole_armor" : preload("res://ScenePreloads/Equipment_old/Armor/mole_armor.tscn"),
	"scraps" : preload("res://ScenePreloads/Equipment_old/Armor/scraps.tscn"),
#Accessory
	"clown_horn" : preload("res://ScenePreloads/Equipment_old/Accessory/clown_horn.tscn"),
	"kiwi" : preload("res://ScenePreloads/Equipment_old/Accessory/kiwi.tscn"),
	"magpie_eye" : preload("res://ScenePreloads/Equipment_old/Accessory/magpie_eye.tscn"),
	"mandragora_potion" : preload("res://ScenePreloads/Equipment_old/Accessory/mandragora_potion.tscn"),
	"manticore_tooth" : preload("res://ScenePreloads/Equipment_old/Accessory/manticore_tooth.tscn"),
	"manticore_venom" : preload("res://ScenePreloads/Equipment_old/Accessory/manticore_venom.tscn"),
	"ram_horn" : preload("res://ScenePreloads/Equipment_old/Accessory/ram_horn.tscn"),
#Currency
	"pebble" : preload("res://ScenePreloads/Equipment_old/Currency/pebble.tscn")}

func createEquipmentScene(itemName : String) :
	var newScene = equipmentSceneDictionary[itemName].instantiate()
	newScene.core = EquipmentDatabase.getEquipment(itemName)
	return newScene
