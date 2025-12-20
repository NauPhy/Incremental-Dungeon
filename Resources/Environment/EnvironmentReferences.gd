extends Node

const FilesDictionary = {
	"chaos" : preload("res://Resources/Environment/Files/chaos.tres"),
	"demonic_city" : preload("res://Resources/Environment/Files/demonic_city.tres"),
	"desert" : preload("res://Resources/Environment/Files/desert.tres"),
	"element_earth" : preload("res://Resources/Environment/Files/element_earth.tres"),
	"element_fire" : preload("res://Resources/Environment/Files/element_fire.tres"),
	"element_fire_earth" : preload("res://Resources/Environment/Files/element_fire_earth.tres"),
	"element_fire_ice" : preload("res://Resources/Environment/Files/element_fire_ice.tres"),
	"element_ice" : preload("res://Resources/Environment/Files/element_ice.tres"),
	"element_ice_earth" : preload("res://Resources/Environment/Files/element_ice_earth.tres"),
	"element_water" : preload("res://Resources/Environment/Files/element_water.tres"),
	"fort_demon" : preload("res://Resources/Environment/Files/fort_demon.tres"),
	"fort_greenskin" : preload("res://Resources/Environment/Files/fort_greenskin.tres"),
	"fort_merfolk" : preload("res://Resources/Environment/Files/fort_merfolk.tres"),
	"fort_undead" : preload("res://Resources/Environment/Files/fort_undead.tres"),
	"hell" : preload("res://Resources/Environment/Files/hell.tres"),
	"hellforge" : preload("res://Resources/Environment/Files/hellforge.tres"),
	"pit_of_depravity" : preload("res://Resources/Environment/Files/pit_of_depravity.tres"),
	"reef_community" : preload("res://Resources/Environment/Files/reef_community.tres"),
	"unholy_alliance" : preload("res://Resources/Environment/Files/unholy_alliance.tres"),
	"unlikely_alliance" : preload("res://Resources/Environment/Files/unlikely_alliance.tres")}


static func getFiles(resourceName : String) :
	return FilesDictionary.get(resourceName)

static func getEnvironment(resourceName : String) :
	if (FilesDictionary.has(resourceName)) :
		return FilesDictionary[resourceName]
	return null

static func getDictionary(type : String) :
	if type == "Files" : 
		return FilesDictionary
static func getAllEnvironment() -> Array :
	var retVal : Array = []
	retVal.append_array(FilesDictionary.values())
	return retVal
