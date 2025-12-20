extends Node

const Floor0Dictionary = {
	"goblin" : preload("res://Resources/OldActor/Floor0/goblin.tres"),
	"hobgoblin" : preload("res://Resources/OldActor/Floor0/hobgoblin.tres"),
	"orc" : preload("res://Resources/OldActor/Floor0/orc.tres"),
	"rat" : preload("res://Resources/OldActor/Floor0/rat.tres"),
	"zombie" : preload("res://Resources/OldActor/Floor0/zombie.tres")}


static func getFloor0(resourceName : String) :
	return Floor0Dictionary.get(resourceName)

const Floor1Dictionary = {
	"cave_mole" : preload("res://Resources/OldActor/Floor1/cave_mole.tres"),
	"dire_rat" : preload("res://Resources/OldActor/Floor1/dire_rat.tres"),
	"giant_magpie" : preload("res://Resources/OldActor/Floor1/giant_magpie.tres"),
	"goose_hydra" : preload("res://Resources/OldActor/Floor1/goose_hydra.tres"),
	"kiwi" : preload("res://Resources/OldActor/Floor1/kiwi.tres"),
	"mandragora" : preload("res://Resources/OldActor/Floor1/mandragora.tres"),
	"manticore" : preload("res://Resources/OldActor/Floor1/manticore.tres"),
	"mini_roc" : preload("res://Resources/OldActor/Floor1/mini_roc.tres"),
	"mountain_goat" : preload("res://Resources/OldActor/Floor1/mountain_goat.tres"),
	"mountain_lion" : preload("res://Resources/OldActor/Floor1/mountain_lion.tres"),
	"rock_dove" : preload("res://Resources/OldActor/Floor1/rock_dove.tres"),
	"vampire_bat" : preload("res://Resources/OldActor/Floor1/vampire_bat.tres")}


static func getFloor1(resourceName : String) :
	return Floor1Dictionary.get(resourceName)

const MiscDictionary = {
	"fighter_preset" : preload("res://Resources/OldActor/Misc/fighter_preset.tres"),
	"human" : preload("res://Resources/OldActor/Misc/human.tres")}


static func getMisc(resourceName : String) :
	return MiscDictionary.get(resourceName)

static func getOldActor(resourceName : String) :
	if (Floor0Dictionary.has(resourceName)) :
		return Floor0Dictionary[resourceName]
	if (Floor1Dictionary.has(resourceName)) :
		return Floor1Dictionary[resourceName]
	if (MiscDictionary.has(resourceName)) :
		return MiscDictionary[resourceName]
	return null

static func getDictionary(type : String) :
	if type == "Floor0" : 
		return Floor0Dictionary
	if type == "Floor1" : 
		return Floor1Dictionary
	if type == "Misc" : 
		return MiscDictionary
static func getAllOldActor() -> Array :
	var retVal : Array = []
	retVal.append_array(Floor0Dictionary.values())
	retVal.append_array(Floor1Dictionary.values())
	retVal.append_array(MiscDictionary.values())
	return retVal
