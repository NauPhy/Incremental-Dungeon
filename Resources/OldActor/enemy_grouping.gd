extends Resource

class_name EnemyGroups
## All enemies need to set these
@export var isEligible : bool = true
@export var glassCannonIndex : float = 1.0
@export var HPToDefRatio : float = 1.0
@export var defRatio : float = 1.0
@export var atkRatio : float = 1.0

enum enemyQualityEnum {normal,veteran,elite}
const enemyQualityDictionary = {
	enemyQualityEnum.normal : "normal",
	enemyQualityEnum.veteran : "veteran",
	enemyQualityEnum.elite : "elite"
}
@export var enemyQuality : enemyQualityEnum = enemyQualityEnum.normal
@export var droppedArmorClasses : Array[EquipmentGroups.armorClassEnum] = []
@export var droppedWeaponClasses : Array[EquipmentGroups.weaponClassEnum] = []
@export var droppedTechnologyClasses : Array[EquipmentGroups.technologyEnum] = []


##Humanoid types
enum factionEnum {
	fire,
	water,
	earth,
	ice,
	undead,
	demonic_military,
	demonic,
	merfolk,
	greenskin,
	misc
}
@export var faction : factionEnum
