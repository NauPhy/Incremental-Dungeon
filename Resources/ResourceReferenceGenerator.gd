@tool
extends EditorScript

const resourcePath = "res://Resources/"
const texturePath = "res://Resources/Textures/"

const excludedResources = ["fighter_preset.tres","human.tres","unarmed_Rogue.tres","unarmed_Mage.tres","unarmed_Fighter.tres"]

func _run() :
	print("NEW RUNNING")
	var resourceTypes = getResourceTypes(false)
	#print("Resource types are: ", resourceTypes)
	createResourceReference(resourceTypes, false)
	var textureTypes = getResourceTypes(true)
	#print("Resource types are: ", textureTypes)
	createResourceReference(textureTypes, true)

func createResourceReference(resourceTypes, isTexture : bool) :
	for resourceType in resourceTypes.keys() :
		var scriptContent : String = "extends Node\n\n"
		var resources : Dictionary = getAllResourcesAsDictionary(resourceTypes[resourceType] + "/", isTexture)
		for filename in excludedResources : 
			for subdirectory in resources.keys() :
				var pos = resources[subdirectory].find_key(resourceTypes[resourceType] + filename)
				if (pos != null) :
					resources[subdirectory].erase(pos)
					print("removed ", filename)
		scriptContent += createDictionariesFromFilesystem(resources, resourceType)
		var outPath
		if (isTexture) :
			outPath = texturePath + resourceType + "/" + resourceType + "References.gd"
		else :
			outPath = resourcePath + resourceType + "/" + resourceType + "References.gd"
		var file = FileAccess.open(outPath, FileAccess.WRITE)
		#print ("outfile: ", outPath)
		#print(scriptContent)
		file.store_string(scriptContent)
		file.close()
		
func getAllResourcesAsDictionary(type, isTexture : bool) -> Dictionary :
	var retVal : Dictionary = {}
	print("opening directory: ", type)
	var dir = DirAccess.open(type)
	var directories = dir.get_directories()
	for myDir in directories :
		print("Entering directory ", type + myDir)
		#var shortDir = myDir.rstrip("/")
		retVal[myDir] = {}
		var resourcePaths : Array[String] = getAllResourcesInDirectoryRecursive(type + myDir + "/", [], isTexture)
		for resource in resourcePaths :
			retVal[myDir][resource.get_file().get_basename()] = resource
	return retVal
		
func getResourceTypes(isTextures : bool) -> Dictionary :
	var retVal = {}
	var dir
	if (isTextures) :
		dir = DirAccess.open(texturePath)
	else :
		dir = DirAccess.open(resourcePath)
	var directories = dir.get_directories()
	for directory in directories :
		if (isTextures) :
			retVal[directory] = texturePath + directory
		elif (directory == "Textures") :
			continue
		else :
			retVal[directory] = resourcePath + directory
	return retVal
	
func createDictionary(myName : String, keys : Array, values : Array) :
	var retVal : String = ""
	retVal += "const " + myName + "Dictionary = {\n"
	for index in range(0,keys.size()) :
		if (index != 0) :
			retVal += ",\n"
		retVal += "\t\"%s\" : preload(\"%s\")" % [keys[index], values[index]]
	retVal += "}\n\n"
	return retVal
	
func getAllResourcesInDirectoryRecursive(directory : String, currentValues : Array[String], isTextures : bool) -> Array[String] :
	var retVal = currentValues
	var dir = DirAccess.open(directory)
	#print("directory is ", directory)
	var directories = dir.get_directories()
	print(directories)
	for tempDir in directories :
		print("Entering directory", tempDir)
		retVal = getAllResourcesInDirectoryRecursive(directory + tempDir + "/", retVal, isTextures)
	var files = dir.get_files()
	for file in files :
		if ((!isTextures && file.get_extension() == "tres") || (isTextures && file.get_extension() == "png")) :
			print("adding file ", file)
			retVal.append(directory + file)
	return retVal

func createDictionariesFromFilesystem(resources : Dictionary, resourceType : String) -> String :
	#print ("Running stringify")
	var retVal : String = ""
	for subdirectory in resources.keys() :
		#print("Stringifying ", subdirectory)
		#print("Size is ", str(resources[subdirectory].keys().size()), " ", str(resources[subdirectory].values().size()))
		retVal += createDictionary(subdirectory, resources[subdirectory].keys(), resources[subdirectory].values())
		retVal += "\n"
		retVal += "static func get" + subdirectory + "(resourceName : String) :\n"
		retVal += "\treturn " + subdirectory + "Dictionary.get(resourceName)"
		retVal += "\n\n"
	retVal += "static func get" + resourceType + "(resourceName : String) :\n"
	retVal += "\tvar retVal\n"
	for subdirectory in resources.keys() :
		retVal += "\tretVal = " + subdirectory + "Dictionary.get(resourceName)\n"
		retVal += "\tif retVal != null : return retVal\n"
	retVal += "\treturn null\n\n"
	retVal += "static func getDictionary(type : String) :\n"
	for subdirectory in resources.keys() :
		retVal += "\tif type == \"" + subdirectory + "\" : \n"
		retVal += "\t\treturn " + subdirectory + "Dictionary\n\n" 
	retVal += "static func getAll" + resourceType + "() :\n"
	retVal += "\tvar retVal : Array = []\n"
	for subdirectory in resources.keys() :
		retVal += "\tretVal.append_array(" + subdirectory + "Dictionary.values())\n"
	retVal += "\treturn retVal\n"
	#print("Stringified Dictionary as ", retVal)
	return retVal
