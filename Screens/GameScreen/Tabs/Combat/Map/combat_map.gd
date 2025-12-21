extends Panel

signal levelChosen2
signal tutorialRequested

@export var isPresentInNG : bool = false

var UIEnabled : bool = true
func disableUI() :
	UIEnabled = false
	$HomeButton.visible = false
	$TextureRect.visible = false
func enableUI() :
	UIEnabled = true
	$HomeButton.visible = true
	$TextureRect.visible = true

func onCombatLoss(room) :
	room.onCombatLoss()
func onCombatRetreat(room) :
	room.onCombatRetreat()

##This prevents a warning
func doNotCall() :
	emit_signal("tutorialRequested")
################################
#map
func _on_level_chosen(emitter) :
	emit_signal("levelChosen2", emitter, emitter.getEncounterRef())
	
signal mapCompleted
func completeRoom(completedRoom) :
	var firstCompletion = !completedRoom.isCompleted()
	completedRoom.onCombatComplete()
	if (firstCompletion) :
		#For all rooms, find rooms linked to this one
		for connection in $CombatMap/ConnectionContainer.get_children() :
			var adjacentRoom = null
			if (connection.Room1 == completedRoom) : 
				adjacentRoom = connection.Room2
			if (connection.Room2 == completedRoom) : 
				adjacentRoom = connection.Room1
			#For rooms linked to this one
			if (adjacentRoom != null) :
				#Fully reveal
				adjacentRoom.setVisibility("full")
				connection.fullReveal()
				if (adjacentRoom.isShop) :
					completeRoom(adjacentRoom)
				#Find rooms that are 2 links away
				for potentialLooseConnection in $CombatMap/ConnectionContainer.get_children() :
					var overAdjacentRoom = null
					if (potentialLooseConnection.Room1 == adjacentRoom) : 
						overAdjacentRoom = potentialLooseConnection.Room2
					elif (potentialLooseConnection.Room2 == adjacentRoom) : 
						overAdjacentRoom = potentialLooseConnection.Room1
					#Half reveal
					if (overAdjacentRoom != null && overAdjacentRoom.getVisibility() != 2) :
						overAdjacentRoom.setVisibility("partial")
						potentialLooseConnection.halfReveal()
		var completedIndex = Helpers.findIndexInContainer($CombatMap/RoomContainer, completedRoom)
		if (completedIndex == $CombatMap/RoomContainer.get_child_count()-1) :
			emit_signal("mapCompleted", self)
	
#scroll
var mapPosRatio : Vector2 = Vector2(-99,-99)
func setMapPosRatio() :
	if (minX > maxX) :
		mapPosRatio.x = -1
	else :
		mapPosRatio.x = $CombatMap.position.x/(maxX-minX)
	if (minY > maxY) :
		mapPosRatio.y = -1
	else :
		mapPosRatio.y = $CombatMap.position.y/(maxY-minY)

@export var scrollStepSize : int = 80
var homePosition : Vector2
var minX : float
var maxX : float
var minY : float
var maxY : float

func initScroll() :
	#var mapSize = $CombatMap.size
	#var viewportSize = size
	var tempPos = Vector2(-$CombatMap.size.x/2.0, -$CombatMap.size.y)
	#await(get_tree().process_frame)
	if (minX > maxX) :
		homePosition.x = size.x/2-$CombatMap.size.x/2
	else :
		homePosition.x = tempPos.x+(size.x/2.0)
	if (minY > maxY) :
		homePosition.y = size.y/2-$CombatMap.size.y/2
	else :
		homePosition.y = tempPos.y+size.y
	
	setBoundaries()
	
func setBoundaries() :
	maxY = homePosition.y+$CombatMap.size.y-size.y
	minY = homePosition.y
	maxX = homePosition.x + ($CombatMap.size.x/2.0)-(size.x/2.0)
	minX = homePosition.x - ($CombatMap.size.x/2.0)+(size.x/2.0)

func forceBoundaries() :
	if ($CombatMap.position.x < minX) :
		$CombatMap.position.x = minX
	elif ($CombatMap.position.x > maxX) :
		$CombatMap.position.x = maxX
	elif ($CombatMap.position.y < minY) :
		$CombatMap.position.y = minY
	elif ($CombatMap.position.y > maxY) :
		$CombatMap.position.y = maxY
		
#func _on_visibility_changed() -> void:
#	if (visible) :
#		grab_focus()

var debounceTimer = 0
func _process(delta) :
	debounceTimer += delta
func _unhandled_input(event: InputEvent) -> void:
	if (!is_visible_in_tree() || !UIEnabled) :
		return
	if (debounceTimer < 0.1 && !event.is_echo()) :
		return
	if (event.is_action("ui_left")) :
		accept_event()
		if ($CombatMap.position.x < maxX - 0.9*scrollStepSize) :
				$CombatMap.position.x += scrollStepSize
	elif (event.is_action("ui_right")) :
		accept_event()
		if ($CombatMap.position.x > minX + 0.9*scrollStepSize) :
				$CombatMap.position.x -= scrollStepSize
	elif (event.is_action("ui_up")) :
		accept_event()
		if ($CombatMap.position.y < maxY - 0.9*scrollStepSize) :
				$CombatMap.position.y += scrollStepSize
	elif (event.is_action("ui_down")) :
		accept_event()
		if ($CombatMap.position.y > minY + 0.9*scrollStepSize) :
				$CombatMap.position.y -= scrollStepSize
	setMapPosRatio()
	debounceTimer = 0
	
func goHome() :
	$CombatMap.position = homePosition
	setMapPosRatio()
	
#######################
## Scope creep but could add in map layout specifiers to environment - like making barracks symmetric
const roomLoader = preload("res://Screens/GameScreen/Tabs/Combat/Map/room.tscn")
const connectionLoader = preload("res://Screens/GameScreen/Tabs/Combat/Map/connection.tscn")
var mapData : MapData = null
func setFromMapData(val : MapData) :
	mapData = val
	for index in range(0,val.rows.size()) :
		addRow(val, index)
	addBossRoom(val)
	internalInitialise()
	
func addRow(val : MapData, row : int) :
	var centerRoom = roomLoader.instantiate()
	$CombatMap/RoomContainer.add_child(centerRoom)
	centerRoom.name = "N" + str(row)
	centerRoom.encounter = val.rows[row].centralEncounter
	setRoomToOrigin(centerRoom)
	setRoomPosVertical(centerRoom, row, false)
	if (row == 0) :
		centerRoom.visibilityOnStartup = 2
	else :
		var newConnection = connectionLoader.instantiate()
		newConnection.Room1 = $CombatMap/RoomContainer.get_node("N"+str(row))
		newConnection.Room2 = centerRoom
		if (row == 1) :
			centerRoom.visibilityOnStartup = 1
			newConnection.visibilityOnStartup = 1
	for index in range(0, val.rows[row].leftEncounters.size()) :
		addSideRoom(val, row, index, true)
	for index in range(0, val.rows[row].rightEncounters.size()) :
		addSideRoom(val, row, index, false)
	
func addSideRoom(val : MapData, row : int, leafCounter : int, isLeft : bool) :
	var newRoom = roomLoader.instantiate()
	$CombatMap/RoomContainer.add_child(newRoom)
	var leftRightChar
	if (isLeft) :
		leftRightChar = "L"
	else :
		leftRightChar = "R"
	newRoom.name = "N" + str(row) + leftRightChar + str(leafCounter)
	if (isLeft) :
		newRoom.encounter = val.rows[row].leftEncounters[leafCounter]
	else :
		newRoom.encounter = val.rows[row].rightEncounters[leafCounter]
	setRoomToOrigin(newRoom)
	setRoomPosVertical(newRoom, row, false)
	var horizontalPos = leafCounter+1
	if (isLeft) :
		horizontalPos *= -1
	setRoomPosHorizontal(newRoom, horizontalPos)
	var newConnection = connectionLoader.instantiate()
	$CombatMap/ConnectionContainer.add_child(newConnection)
	newConnection.Room2 = newRoom
	if (leafCounter == 0) :
		newConnection.Room1 = $CombatMap/RoomContainer.get_node("N"+str(row))
	else :
		newConnection.Room1 = $CombatMap/RoomContainer.get_node("N"+str(row)+leftRightChar+str(leafCounter-1))
		
func addBossRoom(val : MapData) :
	var bossRoom = roomLoader.instantiate()
	$CombatMap/RoomContainer.add_child(bossRoom)
	bossRoom.name = "N" + str(val.rows.size())
	bossRoom.encounter = val.bossEncounter
	setRoomToOrigin(bossRoom)
	setRoomPosVertical(bossRoom, val.rows.size(), true)
	var bossConnection = connectionLoader.instantiate()
	bossConnection.Room1 = $CombatMap/RoomContainer.get_node("N"+str(val.rows.size()-1))
	bossConnection.Room2 = bossRoom
		
#func nameTaken(myName : String) :
	#var currentList = $CombatMap/RoomContainer.get_children()
	#for child in currentList :
		#if (child.name == myName) :
			#return true
	#return false
		
func setRoomToOrigin(room : Button) :
	room.anchor_left = 0.5
	room.anchor_right = 0.5
	room.anchor_top = 1.0
	room.anchor_bottom = 1.0
	room.offset_bottom = -20
	room.offset_top = 0
	room.offset_left = 0
	room.offset_right = 0
	room.grow_horizontal = Control.GROW_DIRECTION_BOTH
	room.grow_vertical = Control.GROW_DIRECTION_BEGIN
func setRoomPosHorizontal(room : Button, amount : int) :
	room.offset_left = 300*amount
	room.offset_right = 300*amount
func setRoomPosVertical(room : Button, amount : int, isBoss : bool) :
	if (isBoss) :
		room.offset_bottom = -200*(amount-1) - 300
	else :
		room.offset_bottom = -200*amount
	
func getTypicalEnemyDefense() :
	var numArr : Array[float] = []
	for room in $CombatMap/RoomContainer.get_children() :
		for enemy in room.getEncounterRef().enemies :
			numArr.append(enemy.PHYSDEF)
			numArr.append(enemy.MAGDEF)
	if (numArr.size()%2 != 0) :
		return numArr[(numArr.size()-1)/2]
	else :
		return (numArr[(numArr.size()-2)/2]+numArr[numArr.size()/2])/2.0
	
signal shopRequested
func _on_shop_requested(details : ShopDetails) :
	emit_signal("shopRequested", details)
	
var fullyInitialised : bool = false

func _on_home_button_was_selected(_emitter) -> void:
	goHome()

func _on_resized() -> void:
	if (fullyInitialised) :
		initScroll()
		setFromMapPosRatio()
		
func setFromMapPosRatio() :
	if (mapPosRatio.x == -99 || (minX > maxX)) :
		$CombatMap.position.x = size.x/2-$CombatMap.size.x/2
	else :
		$CombatMap.position.x = (maxX-minX)*mapPosRatio.x
	if (mapPosRatio.y == -99 || (minY>maxY)) :
		$CombatMap.position.y = size.y/2-$CombatMap.size.y/2
	else :
		$CombatMap.position.y = (maxY-minY)*mapPosRatio.y

############################################################
func getSaveDictionary() -> Dictionary :
	var retVal : Dictionary = {}
	retVal["isRuntime"] = !isPresentInNG
	if (!isPresentInNG) :
		retVal["seed"] = mapData.getSaveDictionary()
	var rooms = $CombatMap/RoomContainer.get_children()
	for index in range(0, rooms.size()) :
		retVal["room"+str(index)] = rooms[index].getSaveDictionary()
	var connections = $CombatMap/ConnectionContainer.get_children()
	for index in range(0, connections.size()) :
		retVal["connection"+str(index)] = connections[index].getSaveDictionary()
	retVal["mapPosX"] = mapPosRatio.x
	retVal["mapPosY"] = mapPosRatio.y
	return retVal

func beforeLoad(newGame) :
	if (!isPresentInNG) :
		return
	internalInitialise()
	if (newGame) :
		fullyInitialised = true
	
func internalInitialise() :
	clip_contents = true
	setupSignals()
	initScroll()
	goHome()
	for room in $
	
func onLoad(loadDict : Dictionary) :
	if (loadDict["isRuntime"]) :
		var data = MapData.createFromSaveDictionary(loadDict["seed"])
		setFromMapData(data)
	var rooms = $CombatMap/RoomContainer.get_children()
	for index in range(0, rooms.size()) :
		rooms[index].onLoad(loadDict["room"+str(index)])
	var connections = $CombatMap/ConnectionContainer.get_children()
	for index in range(0, connections.size()) :
		connections[index].onLoad(loadDict["connection"+str(index)])
	mapPosRatio = Vector2(loadDict["mapPosX"], loadDict["mapPosY"])
	setFromMapPosRatio()
	fullyInitialised = true

		
func setupSignals() :
	for child in $CombatMap/RoomContainer.get_children() :
		child.connect("levelChosen", _on_level_chosen)
		if (child.has_signal("shopRequested")) :
			child.connect("shopRequested", _on_shop_requested)

#var myReady : bool = false
#func _ready() :
	#myReady = true
#
#func beforeLoad(newSave) :
	#clip_contents = true
	##for child in $CombatMap/RoomContainer.get_children() :
		##child.connect("levelChosen", _on_level_chosen)
		##if (child.has_signal("shopRequested")) :
			##child.connect("shopRequested", _on_shop_requested)
	#initScroll()
	#goHome()
	#if (newSave) :
		#fullyInitialised = true
#
#func onLoad(loadDict) -> void :
	#if (!isPresentInNG) :
		#var data = MapData.createFromSaveDictionary(loadDict["mapData"])
		#if (data != null) :
			#setFromMapData(data)
	#var connections = $CombatMap/ConnectionContainer.get_children()
	#for index in range (connections.size()) :
		#var key : String = "connection" + str(index) 
		#connections[index].setVisibility(loadDict[key])
	#var rooms = $CombatMap/RoomContainer.get_children()
	#for index in range (rooms.size()) :
		#var key : String = "room" + str(index)
		#var overridePath = loadDict[key+"override"]
		#if (overridePath != "null") :
			#rooms[index].overrideEncounter(load(overridePath), loadDict[key+"override_once"])
	#mapPosRatio = Vector2(loadDict["mapPosX"], loadDict["mapPosY"])
	#setFromMapPosRatio()
	#fullyInitialised = true
#
#func getSaveDictionary() -> Dictionary :
	#var tempDict = {}
	#if (!isPresentInNG) :
		#if (mapData == null) :
			#tempDict["mapData"] = "null"
		#else :
			#tempDict["mapData"] = mapData.getSaveDictionary()
	#var connections = $CombatMap/ConnectionContainer.get_children()
	#for index in range (connections.size()) :
		#var key : String = "connection" + str(index)
		#tempDict[key] = connections[index].getVisibility()
	#var rooms = $CombatMap/RoomContainer.get_children()
	#for index in range (rooms.size()) :
		#var key : String = "room" + str(index)
		#tempDict[key+"override"] = rooms[index].getOverridePath()
		#tempDict[key+"override_once"] = rooms[index].getOverrideOnce()
		#tempDict[key+"saveData"] = rooms[index].getSaveDictionary()
	#tempDict["mapPosX"] = mapPosRatio.x
	#tempDict["mapPosY"] = mapPosRatio.y
	#return tempDict
