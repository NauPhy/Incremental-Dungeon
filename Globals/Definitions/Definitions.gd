extends Node
const currentVersion : String = "V0.6 development"
var GODMODE : bool = true
var DEVMODE : bool = false

func _ready() :
	attributeCount = 0
	for key in attributeDictionary :
		attributeCount += 1
	if (currentVersion != "V0.6 development") :
		GODMODE = false
		DEVMODE = false

## Not every saveable scene needs to have a load dependency name, but every saveable scene
## that has a dependency or is a dependency does.
enum loadDependencyName {
	player,
	inventory
}
const loadDependencyNameArray = [
	loadDependencyName.player,
	loadDependencyName.inventory
]
		
## Doesn't need to be all inclusive, but you shouldn't save any dictionaries
## that have enum keys not included in this list
#enum enumType {
	#baseStatEnum, 
	#attributeEnum, 
	#classEnum, 
	#saveSlots, 
	#scalingEnum, 
	#equipmentTypeEnum, 
	#damageTypeEnum,
	#optionType,
	#options,
	#tutorialName,
	#tutorialType
	#}
#const enumTypeDictionary = {
	#enumType.baseStatEnum : "baseStatEnum",
	#enumType.attributeEnum : "attributeEnum",
	#enumType.classEnum : "classEnum",
	#enumType.saveSlots : "saveSlots",
	#enumType.scalingEnum : "scalingEnum",
	#enumType.equipmentTypeEnum : "equipmentTypeEnum",
	#enumType.damageTypeEnum : "damageTypeEnum",
	#enumType.optionType : "optionType",
	#enumType.options : "option",
	#enumType.tutorialName : "tutorialName",
	#enumType.tutorialType : "tutorialType"
#}

enum baseStatEnum {
	MAXHP,AR,DR,PHYSDEF,MAGDEF
}
const baseStatDictionary = {
	baseStatEnum.MAXHP : "Max HP",
	baseStatEnum.AR : "Attack Rating",
	baseStatEnum.DR : "Damage Rating",
	baseStatEnum.PHYSDEF : "Physical Defense",
	baseStatEnum.MAGDEF : "Magic Defense"
}
const baseStatDictionaryShort = {
	baseStatEnum.MAXHP : "MAXHP",
	baseStatEnum.AR : "AR",
	baseStatEnum.DR : "DR",
	baseStatEnum.PHYSDEF : "PHYSDEF",
	baseStatEnum.MAGDEF : "MAGDEF"
}
enum attributeEnum {
	DEX,DUR,INT,SKI,STR
}
const attributeDictionary = {
	attributeEnum.DEX : "Dexterity",
	attributeEnum.DUR : "Durability",
	attributeEnum.INT : "Intelligence",
	attributeEnum.SKI : "Skill",
	attributeEnum.STR : "Strength"
}
const attributeDictionaryShort = {
	attributeEnum.DEX : "DEX",
	attributeEnum.DUR : "DUR",
	attributeEnum.INT : "INT",
	attributeEnum.SKI : "SKI",
	attributeEnum.STR : "STR"
}
enum otherStatEnum {
	magicDamageDealt,
	physicalDamageDealt,
	magicDamageTaken,
	physicalDamageTaken,
	magicConversion,
	physicalConversion,
	magicFind,
	routineEffect,
	#dex
	routineSpeed_0,
	#dur
	routineSpeed_1,
	#int
	routineSpeed_2,
	#ski
	routineSpeed_3,
	#str
	routineSpeed_4,
	#all
	routineSpeed_5,
}
const otherStatDictionary = {
	otherStatEnum.magicDamageDealt : "Magic Damage Dealt",
	otherStatEnum.physicalDamageDealt : "Physical Damage Dealt",
	otherStatEnum.magicDamageTaken : "Magic Damage Taken",
	otherStatEnum.physicalDamageTaken : "Physical Damage Taken", 
	otherStatEnum.magicConversion : "Magic Conversion",
	otherStatEnum.physicalConversion : "Physical Conversion",
	otherStatEnum.magicFind : "Magic Find",
	otherStatEnum.routineEffect : "Routine Effect",
	otherStatEnum.routineSpeed_0 : "Routine Speed (DEX)",
	otherStatEnum.routineSpeed_1 : "Routine Speed (DUR)",
	otherStatEnum.routineSpeed_2 : "Routine Speed (INT)",
	otherStatEnum.routineSpeed_3 : "Routine Speed (SKI)",
	otherStatEnum.routineSpeed_4 : "Routine Speed (STR)",
	otherStatEnum.routineSpeed_5 : "Routine Speed"
}
enum classEnum {
	fighter,mage,rogue
}
var attributeCount : int
const classDictionary = {
	classEnum.fighter : "Fighter",
	classEnum.mage : "Mage",
	classEnum.rogue: "Rogue"
}
enum saveSlots {
	nullVal,slot0,slot1,slot2,slot3,current
}
const tempSlot = "user://temp_save_slot.json"
const emergencySlot = "user://backup_save_slot.json"
var slotPaths = {
	saveSlots.current : "",
	saveSlots.slot0 : "user://save_slot_0.json",
	saveSlots.slot1 : "user://save_slot_1.json",
	saveSlots.slot2 : "user://save_slot_2.json",
	saveSlots.slot3 : "user://save_slot_3.json"
}
var slotNames = {
	saveSlots.slot0 : "save slot 0",
	saveSlots.slot1 : "save slot 1",
	saveSlots.slot2 : "save slot 2",
	saveSlots.slot3 : "save slot 3"
}
const mainSettingsPath = "user://main_settings.json"
#enum scalingEnum {
	#STR,INT,DEX
#}
enum equipmentTypeEnum {
	weapon,armor,accessory,currency
}
const equipmentTypeDictionary = {
	equipmentTypeEnum.weapon : "Weapon",
	equipmentTypeEnum.armor : "Armor",
	equipmentTypeEnum.accessory : "Accessory",
	equipmentTypeEnum.currency : "Currency"
}
const equippableDictionary = {
	equipmentTypeEnum.weapon : "Weapon",
	equipmentTypeEnum.armor : "Armor",
	equipmentTypeEnum.accessory : "Accessory",
}
func isEquippable(item) :
	if (item is Node) :
		return equippableDictionary.get(item.getType()) != null
	elif (item is Equipment) :
		return equippableDictionary.get(item.type) != null
enum damageTypeEnum {
	physical,magic
}
const damageTypeDictionary = {
	damageTypeEnum.physical : "Physical",
	damageTypeEnum.magic : "Magic"
}
const equipmentPaths = {
	equipmentTypeEnum.weapon : "res://Global Scene Preloads/Equipment/Resources/Weapon",
	equipmentTypeEnum.armor : "res://Global Scene Preloads/Equipment/Resources/Armor",
	equipmentTypeEnum.accessory : "res://Global Scene Preloads/Equipment/Resources/Accessory",
	equipmentTypeEnum.currency : "res://Global Scene Preloads/Equipment/Resources/Currency"
}

enum elementEnum {
	earth,fire,ice,water
}
const elementDictionary = {
	elementEnum.earth : "Earth",
	elementEnum.fire : "Fire",
	elementEnum.ice : "Ice",
	elementEnum.water : "Water"
}
enum subclass{
	barb,
	knight,
	ammo,
	whirl,
	enchant,
	soul
}
const subclassDictionary= {
	subclass.barb : "Barbarian",
	subclass.knight : "Knight",
	subclass.ammo : "Munitions Expert",
	subclass.whirl : "Whirlwind",
	subclass.enchant : "Enchanter",
	subclass.soul : "Soul Collector"
}
const subclassDescriptions = {
	subclass.barb : "-MAGDEF Multiplier [color=red]x0.8[/color].\n-PHYSDEF Multiplier [color=red]x0.8[/color].\n-Attack speed Multiplier [color=green]x1.25[/color].\n-DR Multiplier [color=green]x1.25[/color]\n\nAH-KLORAAAA!",
	subclass.knight : "-DR Multiplier [color=red]x0.75[/color].\n-Bonus to Base DR of [color=green]+N[/color], where N = 190% of the average of your equipped Armor's PHYSDEF and MAGDEF.\n\nYou feel naked in anything less than full plate.",
	subclass.ammo : "While a ranged (or neither) weapon is equipped:\n-AR Multiplier [color=green]x1.35[/color].\n-All damage is dealt to the lower of your enemy's resistances.\n\nYour custom ammunition always hits the enemy where it's weakest.",
	subclass.whirl : "While a melee (or neither) weapon is equipped:\n-Attack speed Multiplier [color=green]x1.16[/color]\n-PHYSDEF Multiplier [color=green]x1.08[/color]\n-MAGDEF Multiplier [color=green]x1.08[/color]\n\nYou fight with such ferocity that no opponent can get within arms reach unharmed.",
	subclass.enchant : "While an elemental weapon is equipped:\n-DR Multiplier [color=green]x1.1[/color].\nWhile an elemental armor is equipped:\n-MAGDEF and PHYSDEF Multiplier [color=green]x1.1[/color].\nWhile an elemental accessory is equipped:\n-Skill Multiplier [color=green]x1.05[/color].\n-The effect of Elemental synergy is increased from [color=green]1.25x[/color] to [color=green]1.3125x[/color]\n\nYou've spent countless hours studying and attuning to enchanted equipment, and can use it expertly.",
	subclass.soul : "-HP Multiplier [color=red]x0.85[/color]\n-Bonus to HP Standard Multiplier of [color=green]+N[/color]\n-Bonus to DR Standard Multiplier of [color=green]+N[/color]\n-N=-0.00004x^2+0.0105x-0.25\n\nYou performed a ritual that allows your body to gain power from the souls of your enemies. Your heart stopped for a couple seconds and now you have jaundice, but it's probably nothing to worry about."
}
