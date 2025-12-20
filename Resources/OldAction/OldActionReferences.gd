extends Node

const AttacksDictionary = {
	"bite" : preload("res://Resources/OldAction/Attacks/Enemies/bite.tres"),
	"leech_bolt_1_enemy" : preload("res://Resources/OldAction/Attacks/Enemies/leech_bolt_1_enemy.tres"),
	"mandragora" : preload("res://Resources/OldAction/Attacks/Enemies/mandragora.tres"),
	"multi_peck" : preload("res://Resources/OldAction/Attacks/Enemies/multi_peck.tres"),
	"peck" : preload("res://Resources/OldAction/Attacks/Enemies/peck.tres"),
	"ram" : preload("res://Resources/OldAction/Attacks/Enemies/ram.tres"),
	"vampiric_bite" : preload("res://Resources/OldAction/Attacks/Enemies/vampiric_bite.tres"),
	"bludgeon" : preload("res://Resources/OldAction/Attacks/Tutorial/bludgeon.tres"),
	"claw_zombie" : preload("res://Resources/OldAction/Attacks/Tutorial/claw_zombie.tres"),
	"knifehand" : preload("res://Resources/OldAction/Attacks/Tutorial/knifehand.tres"),
	"knifehand_2" : preload("res://Resources/OldAction/Attacks/Tutorial/knifehand_2.tres"),
	"nibble" : preload("res://Resources/OldAction/Attacks/Tutorial/nibble.tres"),
	"psy_blast" : preload("res://Resources/OldAction/Attacks/Tutorial/psy_blast.tres"),
	"psy_blast_2" : preload("res://Resources/OldAction/Attacks/Tutorial/psy_blast_2.tres"),
	"punch" : preload("res://Resources/OldAction/Attacks/Tutorial/punch.tres"),
	"punch_2" : preload("res://Resources/OldAction/Attacks/Tutorial/punch_2.tres"),
	"weak_stab" : preload("res://Resources/OldAction/Attacks/Tutorial/weak_stab.tres"),
	"claw_basic" : preload("res://Resources/OldAction/Attacks/claw_basic.tres"),
	"dagger_basic" : preload("res://Resources/OldAction/Attacks/dagger_basic.tres"),
	"dart_basic" : preload("res://Resources/OldAction/Attacks/dart_basic.tres"),
	"executioners_sword_basic" : preload("res://Resources/OldAction/Attacks/executioners_sword_basic.tres"),
	"godpunch" : preload("res://Resources/OldAction/Attacks/godpunch.tres"),
	"kinetic_blast" : preload("res://Resources/OldAction/Attacks/kinetic_blast.tres"),
	"leech_bolt_1" : preload("res://Resources/OldAction/Attacks/leech_bolt_1.tres"),
	"light_laser_1" : preload("res://Resources/OldAction/Attacks/light_laser_1.tres"),
	"sling_basic" : preload("res://Resources/OldAction/Attacks/sling_basic.tres"),
	"spear_basic" : preload("res://Resources/OldAction/Attacks/spear_basic.tres"),
	"triple_peck" : preload("res://Resources/OldAction/Attacks/triple_peck.tres")}


static func getAttacks(resourceName : String) :
	return AttacksDictionary.get(resourceName)

static func getOldAction(resourceName : String) :
	var retVal
	retVal = AttacksDictionary.get(resourceName)
	if retVal != null : return retVal
	return null

static func getDictionary(type : String) :
	if type == "Attacks" : 
		return AttacksDictionary

static func getAllOldAction() :
	var retVal : Array = []
	retVal.append_array(AttacksDictionary.values())
	return retVal
