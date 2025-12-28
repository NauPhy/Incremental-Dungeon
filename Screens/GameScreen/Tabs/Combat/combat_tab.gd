extends Panel

var currentFloor = null
var maxFloor : int = 0
var currentRoom = null
var friendlyParty : Array[ActorPreset]

#########################
var playerCore_comm : ActorPreset = null
var waitingForPlayerCore : bool = false
signal playerCoreRequested
signal playerCoreReceived

func getPlayerCore() -> ActorPreset:
	waitingForPlayerCore = true
	emit_signal("playerCoreRequested", self)
	if (waitingForPlayerCore) :
		await playerCoreReceived
	return playerCore_comm
	
func providePlayerCore(val : ActorPreset) :
	playerCore_comm = val
	waitingForPlayerCore = false
	emit_signal("playerCoreReceived")
##########################

func _on_level_chosen(emitter, encounter) -> void:
	friendlyParty[0] = await getPlayerCore()
	currentRoom = emitter
	if (currentRoom.isFirstEntry()) :
		currentRoom.enter()
		if (encounter.introText != "") :
			$NarrativePanel.text = encounter.introText
			$NarrativePanel.title = encounter.introTitle
			$NarrativePanel.visible = true
			await($NarrativePanel.continueSignal)
			$NarrativePanel.visible = false
	if (encounter.enemies.is_empty()) :
		_on_combat_panel_victory(false)
		return
	var copy : Array[ActorPreset]
	for elem in friendlyParty :
		copy.append(elem.duplicate())
	$CombatPanel.resetCombat(copy, encounter.enemies)
	hideMapAndUI()
	$CombatPanel.visible = true
	
signal tutorialRequested
func _on_tutorial_requested(tutorialName, tutorialPos) :
	emit_signal("tutorialRequested", tutorialName, tutorialPos)

func _on_combat_panel_victory(automaticReset : bool) -> void:
	if (currentRoom.getEncounterRef().victoryText != "") :
		$NarrativePanel.text = currentRoom.getEncounterRef().victoryText
		$NarrativePanel.title = currentRoom.getEncounterRef().victoryTitle
		$NarrativePanel.visible = true
		await($NarrativePanel.continueSignal)
		$NarrativePanel.visible = false	
	var magicFind = await getMagicFind()
	var rewards
	## New
	if (currentFloor.has_method("getEnvironment")) :
		rewards = $ProceduralGenerationLogic.generateDrops(currentRoom.getEncounterRef().enemies, currentFloor.getEnvironment())
	else :
		rewards = currentRoom.getEncounterRef().getRewards(magicFind)
	await handleCombatRewards(rewards)		
	currentFloor.completeRoom(currentRoom)
	if (automaticReset) :
		friendlyParty[0] = await getPlayerCore()
		var copy : Array[ActorPreset]
		for elem in friendlyParty :
			copy.append(elem.duplicate())
		$CombatPanel.resetCombat(copy, currentRoom.getEncounterRef().enemies)
	else :
		currentRoom = null
		$CombatPanel.visible = false
		if (!narrativeWorking) :
			showMapAndUI()

var waitingForMagicFind : bool = false
signal magicFindDone
signal magicFindRequested
var magicFind_comm
func getMagicFind() :
	waitingForMagicFind = true
	emit_signal("magicFindRequested", self)
	if (waitingForMagicFind) :
		await magicFindDone
	return magicFind_comm
func provideMagicFind(val) :
	magicFind_comm = val
	waitingForMagicFind = false
	emit_signal("magicFindDone")

func _on_combat_panel_defeat() -> void:
	currentFloor.onCombatLoss(currentRoom)
	startDefeatCoroutine()
	
func _on_combat_panel_retreat() -> void:
	interruptDefeatCoroutine()
	currentFloor.onCombatRetreat(currentRoom)
	currentRoom = null
	showMapAndUI()
	
signal playerClassRequested
func _on_player_class_requested(emitter) :
	emit_signal("playerClassRequested", emitter)
	
signal newFloorCompleted
func _on_map_completed(emitter) :
	var completedIndex = Helpers.findIndexInContainer($MapContainer, emitter)
	if (completedIndex == maxFloor) :
		var isNarrative : bool = false
		if (currentFloor.has_method("getBossName")) :
			isNarrative = true
			var outroText = "As the " + currentFloor.getBossName() + " falls, the path forward opens."
			var title = "Victory!"
			var button = "Descend"
			launchNarrative(title, outroText, button, false)
		maxFloor += 1
		$FloorDisplay.setMaxFloor(maxFloor)
		var typicalEnemyDefense = emitter.getTypicalEnemyDefense()
		if (completedIndex >= 1) :
			createNewFloor()
		if (narrativeWorking) :
			await $NarrativePanel.continueSignal
		_on_floor_display_floor_down()
		if (currentFloor.has_method("getEnvironment")) :
			var environment : MyEnvironment = currentFloor.getEnvironment()
			var title = environment.getName()
			var myText = environment.introText
			var button = "Continue"
			launchNarrative(title, myText, button, true)
		emit_signal("newFloorCompleted", typicalEnemyDefense)

var narrativeWorking : bool = false
func launchNarrative(title : String, myText : String, buttonText : String, waitToFinish : bool) :
	$NarrativePanel.setTitle(title)
	$NarrativePanel.setText(myText)
	$NarrativePanel.setButtonText(buttonText)
	disableUI()
	$NarrativePanel.visible = true
	if (waitToFinish) :
		await $NarrativePanel.continueSignal
	
func _on_narrative_panel_complete() :
	$NarrativePanel.visible = false
	showMapAndUI()
	narrativeWorking = false

const mapLoader = preload("res://Screens/GameScreen/Tabs/Combat/Map/Map_Runtime/combat_map_template_runtime.tscn")
func createNewFloor() :
	var mapData : MapData = $ProceduralGenerationLogic.createMap()
	var newFloor = mapLoader.instantiate()
	$MapContainer.add_child(newFloor)
	if (!newFloor.myReady) :
		await newFloor.myReadySignal
	await newFloor.initialise(mapData)
	newFloor.beforeLoad()
	newFloor.name = "Floor" + str($MapContainer.get_child_count()-1)
	connectToMapSignals(newFloor)
	
func _on_floor_display_floor_up() -> void:
	var currentFloorIndex = Helpers.findIndexInContainer($MapContainer, currentFloor)
	if (currentFloorIndex != null && currentFloorIndex != 0) :
		currentFloor.visible = false
		currentFloor = $MapContainer.get_child(currentFloorIndex-1)
		currentFloor.visible = true
		$FloorDisplay.setFloor(currentFloorIndex-1)

func _on_floor_display_floor_down() -> void:
	var currentFloorIndex = Helpers.findIndexInContainer($MapContainer, currentFloor)
	if (currentFloorIndex != null && currentFloorIndex != maxFloor) :
		currentFloor.visible = false
		currentFloor = $MapContainer.get_child(currentFloorIndex+1)
		currentFloor.visible = true
		$FloorDisplay.setFloor(currentFloorIndex+1)
		
signal routineUnlockRequested
func _on_routine_unlock_requested(routine : AttributeTraining) :
	emit_signal("routineUnlockRequested", routine)
	
signal shopRequested
func _on_shop_requested(details) :
	emit_signal("shopRequested", details)
	
func showMapAndUI() :
	$MapContainer.visible = true
	enableUI()
func hideMapAndUI() :
	$MapContainer.visible = false
	disableUI()
func disableUI() :
	currentFloor.disableUI()
	$FloorDisplay.visible = false
func enableUI() :
	currentFloor.enableUI()
	$FloorDisplay.visible = true

#######################################
var defeatCoroutineRunning : bool = false
var defeatCoroutineInterrupted : bool = false

func startDefeatCoroutine() :
	if (defeatCoroutineRunning) :
		return
	defeatCoroutineRunning = true
	defeatCoroutineInterrupted = false
	await get_tree().create_timer(3.0).timeout
	if (defeatCoroutineInterrupted) :
		defeatCoroutineRunning = false
		return
	friendlyParty[0] = await getPlayerCore()
	var copy : Array[ActorPreset]
	for elem in friendlyParty :
		copy.append(elem.duplicate())
	$CombatPanel.resetCombat(copy, currentRoom.getEncounterRef().enemies)
	defeatCoroutineRunning = false
	
func interruptDefeatCoroutine() :
	defeatCoroutineInterrupted = true
	
func connectToMapSignals(map : Node) :
	if (map.has_signal("levelChosen")) :
		map.connect("levelChosen", _on_level_chosen)
	if (map.has_signal("playerClassRequested")) :
		map.connect("playerClassRequested", _on_player_class_requested)
	if (map.has_signal("tutorialRequested")) :
		map.connect("tutorialRequested", _on_tutorial_requested)
	if (map.has_signal("routineUnlockRequested")) :
		map.connect("routineUnlockRequested", _on_routine_unlock_requested)
	if (map.has_signal("shopRequested")) :
		map.connect("shopRequested", _on_shop_requested)
	map.connect("mapCompleted", _on_map_completed)

const combatRewardsLoader = preload("res://Screens/GameScreen/Tabs/Combat/CombatRewards/combat_rewards.tscn")
var firstReward : bool = true
func handleCombatRewards(rewards : Array[Equipment]) :
	if (rewards.is_empty()) :
		return
	if (firstReward) :
		firstReward = false
		emit_signal("tutorialRequested", Encyclopedia.tutorialName.equipment, Vector2(0,0))
	var rewardHandler = combatRewardsLoader.instantiate()
	add_child(rewardHandler)
	rewardHandler.connect("addToInventoryRequested", _on_add_to_inventory_request)
	rewardHandler.initialise(rewards)
	#if (rewardHandler.initialisationPending) :
		#await rewardHandler.initialisationComplete
	if (!rewardHandler.isFinished()) :
		await rewardHandler.finished

signal addToInventoryRequested
func _on_add_to_inventory_request(itemSceneRef, isAutomatic : bool) :
	emit_signal("addToInventoryRequested", itemSceneRef, isAutomatic)

func removeCombatRewardEntry(itemSceneRef) :
	get_node("CombatRewards").removeItemFromList(itemSceneRef)
	
func denyAddToInventory() :
	get_node("CombatRewards").denyAddToInventory()
	
func getSaveDictionary() -> Dictionary :
	var tempDict : Dictionary = {}
	tempDict["firstReward"] = firstReward
	tempDict["maxFloor"] = maxFloor
	var currentFloorIndex = Helpers.findIndexInContainer($MapContainer, currentFloor)
	if (currentFloorIndex == null) :
		currentFloorIndex = "null"
	tempDict["currentFloorIndex"] = currentFloorIndex
	tempDict["maps"] = []
	for map in $MapContainer.get_children() :
		tempDict["maps"].append(map.getSaveDictionary())
	return tempDict
	
var myReady : bool = false
func _ready() :
	for map in $MapContainer.get_children() :
		if(!map.myReady) :
			await map.myReadySignal
	myReady = true
	
func beforeLoad(newGame) :
	$NarrativePanel.connect("continueSignal", _on_narrative_panel_complete)
	for map in $MapContainer.get_children() :
		if (!map.is_in_group("Saveable")) :
			map.beforeLoad(newGame)
		connectToMapSignals(map)
	friendlyParty.resize(1)
	if (newGame) :
		currentFloor = $MapContainer.get_child(0)
		$FloorDisplay.setFloor(0)
		currentFloor.visible = true
		
func onLoad(loadDict : Dictionary) :
	var hardMapCount = $MapContainer.get_child_count()
	for index in range(0, loadDict["maps"].size()) :
		if (index < hardMapCount) :
			pass
			#$MapContainer.get_child(index).onLoad(loadDict["maps"][index])
		else :
			var newMap = mapLoader.instantiate()
			$MapContainer.add_child(newMap)
			if (!newMap.myReady) :
				await newMap.myReadySignal
			await newMap.initialise(loadDict["maps"][index])
			newMap.beforeLoad()
			newMap.onLoad(loadDict["maps"][index])
			connectToMapSignals(newMap)
		
	firstReward = loadDict["firstReward"]
	maxFloor = loadDict["maxFloor"]
	$FloorDisplay.setMaxFloor(maxFloor)
	var currentFloorIndex = loadDict["currentFloorIndex"]
	if (currentFloorIndex is String && currentFloorIndex == "null") :
		currentFloor = $MapContainer.get_child(0)
		$FloorDisplay.setFloor(0)
	else :
		currentFloor = $MapContainer.get_child(currentFloorIndex)
		$FloorDisplay.setFloor(currentFloorIndex)
	currentFloor.visible = true
