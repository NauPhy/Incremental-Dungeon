extends Resource

class_name MyEnvironment
@export var title : String = ""
@export var permittedFactions : Array[EnemyGroups.factionEnum] = []
@export var firePermitted : bool = false
@export var icePermitted : bool = false
@export var earthPermitted : bool = false
@export var waterPermitted : bool = false

func getName() :
	return title
