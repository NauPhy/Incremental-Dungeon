extends Node

const AttacksDictionary = {
	"axe_1h" : preload("res://Resources/NewAction/Attacks/axe_1h.tres"),
	"axe_2h" : preload("res://Resources/NewAction/Attacks/axe_2h.tres"),
	"bow" : preload("res://Resources/NewAction/Attacks/bow.tres"),
	"club_1h" : preload("res://Resources/NewAction/Attacks/club_1h.tres"),
	"crack" : preload("res://Resources/NewAction/Attacks/crack.tres"),
	"crossbow" : preload("res://Resources/NewAction/Attacks/crossbow.tres"),
	"curse" : preload("res://Resources/NewAction/Attacks/curse.tres"),
	"dagger" : preload("res://Resources/NewAction/Attacks/dagger.tres"),
	"flame_whip" : preload("res://Resources/NewAction/Attacks/flame_whip.tres"),
	"frost_slash" : preload("res://Resources/NewAction/Attacks/frost_slash.tres"),
	"icicle_spike" : preload("res://Resources/NewAction/Attacks/icicle_spike.tres"),
	"katana_attack" : preload("res://Resources/NewAction/Attacks/katana_attack.tres"),
	"kinetic_blast" : preload("res://Resources/NewAction/Attacks/kinetic_blast.tres"),
	"lance" : preload("res://Resources/NewAction/Attacks/lance.tres"),
	"laser" : preload("res://Resources/NewAction/Attacks/laser.tres"),
	"lightning" : preload("res://Resources/NewAction/Attacks/lightning.tres"),
	"lucky_star" : preload("res://Resources/NewAction/Attacks/lucky_star.tres"),
	"mace_1h" : preload("res://Resources/NewAction/Attacks/mace_1h.tres"),
	"scythe" : preload("res://Resources/NewAction/Attacks/scythe.tres"),
	"shortbow" : preload("res://Resources/NewAction/Attacks/shortbow.tres"),
	"slashing_sword_1h" : preload("res://Resources/NewAction/Attacks/slashing_sword_1h.tres"),
	"slashing_sword_2h" : preload("res://Resources/NewAction/Attacks/slashing_sword_2h.tres"),
	"sling" : preload("res://Resources/NewAction/Attacks/sling.tres"),
	"spear_1h" : preload("res://Resources/NewAction/Attacks/spear_1h.tres"),
	"spear_2h" : preload("res://Resources/NewAction/Attacks/spear_2h.tres"),
	"thresh" : preload("res://Resources/NewAction/Attacks/thresh.tres"),
	"throw_axe" : preload("res://Resources/NewAction/Attacks/throw_axe.tres"),
	"throw_boulder" : preload("res://Resources/NewAction/Attacks/throw_boulder.tres"),
	"throw_kunai" : preload("res://Resources/NewAction/Attacks/throw_kunai.tres"),
	"thrust_sword_1h" : preload("res://Resources/NewAction/Attacks/thrust_sword_1h.tres"),
	"thrust_sword_2h" : preload("res://Resources/NewAction/Attacks/thrust_sword_2h.tres"),
	"water_jet" : preload("res://Resources/NewAction/Attacks/water_jet.tres")}


static func getAttacks(resourceName : String) :
	return AttacksDictionary.get(resourceName)

static func getNewAction(resourceName : String) :
	var retVal
	retVal = AttacksDictionary.get(resourceName)
	if retVal != null : return retVal
	return null

static func getDictionary(type : String) :
	if type == "Attacks" : 
		return AttacksDictionary

static func getAllNewAction() :
	var retVal : Array = []
	retVal.append_array(AttacksDictionary.values())
	return retVal
