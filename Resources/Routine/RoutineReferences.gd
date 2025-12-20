extends Node

const FilesDictionary = {
	"lift_weights" : preload("res://Resources/Routine/Files/lift_weights.tres"),
	"pickpocket_goblins" : preload("res://Resources/Routine/Files/pickpocket_goblins.tres"),
	"punch_walls" : preload("res://Resources/Routine/Files/punch_walls.tres"),
	"read_novels" : preload("res://Resources/Routine/Files/read_novels.tres"),
	"spar" : preload("res://Resources/Routine/Files/spar.tres")}


static func getFiles(resourceName : String) :
	return FilesDictionary.get(resourceName)

static func getRoutine(resourceName : String) :
	if (FilesDictionary.has(resourceName)) :
		return FilesDictionary[resourceName]
	return null

static func getDictionary(type : String) :
	if type == "Files" : 
		return FilesDictionary
static func getAllRoutine() -> Array :
	var retVal : Array = []
	retVal.append_array(FilesDictionary.values())
	return retVal
