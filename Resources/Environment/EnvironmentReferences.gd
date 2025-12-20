extends Node

const FilesDictionary = {
	"desert" : preload("res://Resources/Environment/Files/desert.tres"),
	"fort" : preload("res://Resources/Environment/Files/fort.tres"),
	"freeze_flame" : preload("res://Resources/Environment/Files/freeze_flame.tres"),
	"magic_forest" : preload("res://Resources/Environment/Files/magic_forest.tres"),
	"ocean" : preload("res://Resources/Environment/Files/ocean.tres"),
	"tundra" : preload("res://Resources/Environment/Files/tundra.tres"),
	"volcano" : preload("res://Resources/Environment/Files/volcano.tres")}


static func getFiles(resourceName : String) :
	return FilesDictionary.get(resourceName)

static func getEnvironment(resourceName : String) :
	var retVal
	retVal = FilesDictionary.get(resourceName)
	if retVal != null : return retVal
	return null

static func getDictionary(type : String) :
	if type == "Files" : 
		return FilesDictionary

static func getAllEnvironment() :
	var retVal : Array = []
	retVal.append_array(FilesDictionary.values())
	return retVal
