extends Node

class_name MainOptionsHelpers

static func getDefaultSettings() -> Dictionary :
	var tempDict : Dictionary = {}
	tempDict["Window Mode"] = 0
	tempDict["gameCompleted"] = false
	tempDict["globalEncyclopedia"] = {
		"beastiary" : {},
		"items" : []
	}
	tempDict["herophile"] = false
	return tempDict

static func applyWindowMode(val) :
	if (val == 0) :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif (val == 1) :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else :
		return
		
static func loadSettings() :
	var text = FileAccess.open(Definitions.mainSettingsPath, FileAccess.READ).get_as_text()
	var dict = JSON.parse_string(text)
	if (dict.get("gameCompleted") == null) :
		dict["gameCompleted"] = false
	if (dict.get("globalEncyclopedia") == null) :
		dict["globalEncyclopedia"] = {
			"beastiary" : {},
			"items" : []
		}
	if (dict.get("herophile") == null) :
		dict["herophile"] = dict["globalEncyclopedia"]["beastiary"]["champion_of_poseidon"] >= 1
	return dict
	
static func saveSettings(settings) :
	var saveFile = FileAccess.open(Definitions.mainSettingsPath, FileAccess.WRITE)
	saveFile.store_string(JSON.stringify(settings))
	saveFile.close()
