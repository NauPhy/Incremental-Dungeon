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
signal playerPortraitRequested
func _on_player_portrait_requested(emitter) :
	emit_signal("playerPortraitRequested", emitter)
##########################
func getMostRecentEquipmentScaling() -> float :
	var currentRow = $MapContainer.get_children().back().getFurthestProgression()
	var scalingRows = $ProceduralGenerationLogic.getScalingRows_mapFinished(currentRow)
	return $ProceduralGenerationLogic.getEquipmentScaling(scalingRows)
func getMostRecentCurrencyScaling(type) -> float :
	if $MapContainer.get_child_count() == 1 :
		return 0
	var currentRow = $MapContainer.get_children().back().getFurthestProgression()
	var scalingRows = $ProceduralGenerationLogic.getScalingRows_mapFinished(currentRow)
	if (type == "routine") :
		return $ProceduralGenerationLogic.getGoldScaling(scalingRows)
	elif (type == "armor" || type == "weapon") :
		return $ProceduralGenerationLogic.getOreScaling(scalingRows)
	elif (type == "soul") :
		return $ProceduralGenerationLogic.getSoulScaling(scalingRows)
	else :
		return 0
func getFurthestProgression() :
	return $MapContainer.get_children().back().getFurthestProgression()
func createRandomShopItem(type : Definitions.equipmentTypeEnum) -> Equipment :
	return $ProceduralGenerationLogic.createRandomShopItem(type, getMostRecentEquipmentScaling())
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
		rewards = $ProceduralGenerationLogic.generateDrops(currentRoom, currentFloor.getEnvironment())
	else :
		var rewardsTutorial = currentRoom.getEncounterRef().getRewards(magicFind)
		rewards = {
			"equipment" : rewardsTutorial,
			"currency" : [0]
		}
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
	$CombatPanel.visible = false
	showMapAndUI()
	
signal playerClassRequested
func _on_player_class_requested(emitter) :
	emit_signal("playerClassRequested", emitter)
	
func getTypicalEnemyDefense(floor : int) :
	return $MapContainer.get_child(floor).getTypicalEnemyDefense()
	
signal newFloorCompleted
func _on_map_completed(emitter) :
	var completedIndex = Helpers.findIndexInContainer($MapContainer, emitter)
	if (completedIndex == maxFloor) :
		## The only boss that starts with Hell Knight is the final boss
		if (currentFloor.has_method("getBossName") && currentFloor.getBossName() != "Hell Knight") :
			var outroText = "As the " + currentFloor.getBossName() + " falls, the path forward opens."
			var title = "Victory!"
			var button = "Descend"
			launchNarrative(title, outroText, button, false, false)
		maxFloor += 1
		$FloorDisplay.setMaxFloor(maxFloor)
		var typicalEnemyDefense = emitter.getTypicalEnemyDefense()
		createNewFloor()
		if (narrativeWorking) :
			await $NarrativePanel.continueSignal
		_on_floor_display_floor_down()
		if (currentFloor.has_method("getEnvironment")) :
			var environment : MyEnvironment = currentFloor.getEnvironment()
			var title = environment.getName()
			var myText = environment.introText
			var button = "Continue"
			await launchNarrative(title, myText, button, true, true)
		emit_signal("newFloorCompleted", typicalEnemyDefense)

var narrativeWorking : bool = false
func launchNarrative(title : String, myText : String, buttonText : String, waitToFinish : bool, isEnvironmentIntro : bool) :
	narrativeWorking = true
	$NarrativePanel.setTitle(title)
	$NarrativePanel.setText(myText)
	$NarrativePanel.setButtonText(buttonText)
	disableUI()
	$NarrativePanel.visible = true
	var factions = $NarrativePanel/VBoxContainer/VBoxContainer/FactionSymbol
	var elements = $NarrativePanel/VBoxContainer/VBoxContainer/Elements
	if (isEnvironmentIntro) :
		factions.visible = true
		elements.visible = true
		factions.setEnvironment(currentFloor.getEnvironment())
		elements.setEnvironment(currentFloor.getEnvironment())
	else :
		factions.visible = false
		elements.visible = false
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
	if (currentFloor.has_method("getEnvironment")) :
		$FloorDisplay.setEnvironment(currentFloor.getEnvironment())
	else :
		$FloorDisplay.setTutorialBiome()

func _on_floor_display_floor_down() -> void:
	var currentFloorIndex = Helpers.findIndexInContainer($MapContainer, currentFloor)
	if (currentFloorIndex != null && currentFloorIndex != maxFloor) :
		currentFloor.visible = false
		currentFloor = $MapContainer.get_child(currentFloorIndex+1)
		currentFloor.visible = true
		$FloorDisplay.setFloor(currentFloorIndex+1)
	if (currentFloor.has_method("getEnvironment")) :
		$FloorDisplay.setEnvironment(currentFloor.getEnvironment())
	else :
		$FloorDisplay.setTutorialBiome()
		
signal addChildRequested
func _on_add_child_requested(emitter, node : Node) :
	emit_signal("addChildRequested",emitter, node)
		
signal routineUnlockRequested
func _on_routine_unlock_requested(emitter, routine : AttributeTraining) :
	emit_signal("routineUnlockRequested", emitter, routine)
	
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
	if (currentFloor != null) :
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
	if (map.has_signal("addChildRequested")) :
		map.connect("addChildRequested", _on_add_child_requested)
	if (map.has_signal("apophisKilled")) :
		map.connect("apophisKilled", _on_apophis_killed)
	map.connect("mapCompleted", _on_map_completed)
	
signal apophisKilled
func _on_apophis_killed() :
	emit_signal("apophisKilled")

const combatRewardsLoader = preload("res://Screens/GameScreen/Tabs/Combat/CombatRewards/combat_rewards.tscn")
var firstReward : bool = true
func handleCombatRewards(rewards : Dictionary) :
	var nullify : bool = rewards["equipment"].is_empty()
	for index in range(0, rewards["currency"].size()) :
		nullify = nullify && rewards["currency"][index] == 0
	if (nullify) :
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
signal myReadySignal
var doneLoading : bool = false
signal doneLoadingSignal
func _ready() :
	for map in $MapContainer.get_children() :
		if(!map.myReady) :
			await map.myReadySignal
	myReady = true
	emit_signal("myReadySignal")
	
func beforeLoad(newGame) :
	myReady = false
	disableUI()
	$MapContainer.visible = false
	$NarrativePanel.connect("continueSignal", _on_narrative_panel_complete)
	for map in $MapContainer.get_children() :
		if (!map.is_in_group("Saveable")) :
			map.beforeLoad(newGame)
		connectToMapSignals(map)
	friendlyParty.resize(1)
	if (newGame) :
		currentFloor = $MapContainer.get_child(0)
		$FloorDisplay.setFloor(0)
		$FloorDisplay.setTutorialBiome()
		$MapContainer.visible = true
		currentFloor.visible = true
		enableUI()
	myReady = true
	emit_signal("myReadySignal")
	if (newGame) :
		doneLoading = true
		emit_signal("doneLoadingSignal")
		
func onLoad(loadDict : Dictionary) :
	myReady = false
	var hardMapCount = $MapContainer.get_child_count()
	for index in range(0, loadDict["maps"].size()) :
		if (index < hardMapCount) :
			pass
			#$MapContainer.get_child(index).onLoad(loadDict["maps"][index])
		else :
			var newMap = mapLoader.instantiate()
			$MapContainer.add_child(newMap)
			newMap.visible = false
			if (!newMap.myReady) :
				await newMap.myReadySignal
			newMap.initialise(loadDict["maps"][index])
	var maps = $MapContainer.get_children()
	for index in range(0, maps.size()) :
		var child = maps[index]
		if (child.has_signal("fullyInitialisedSignal") && !child.fullyInitialised) :
			await child.fullyInitialisedSignal
		if (child.has_signal("fullyInitialisedSignal")) :
			child.beforeLoad()
			child.onLoad(loadDict["maps"][index])
			connectToMapSignals(child)
		
	firstReward = loadDict["firstReward"]
	maxFloor = loadDict["maxFloor"]
	$FloorDisplay.setMaxFloor(maxFloor)
	var currentFloorIndex = loadDict["currentFloorIndex"]
	if (currentFloorIndex is String && currentFloorIndex == "null") :
		currentFloor = $MapContainer.get_child(0)
		$FloorDisplay.setFloor(0)
		$FloorDisplay.setTutorialBiome()
	else :
		currentFloor = $MapContainer.get_child(currentFloorIndex)
		$FloorDisplay.setFloor(currentFloorIndex)
		if (currentFloorIndex == 0) :
			$FloorDisplay.setTutorialBiome()
		else : 
			$FloorDisplay.setEnvironment(currentFloor.getEnvironment())
	enableUI()
	$MapContainer.visible = true
	currentFloor.visible = true
	myReady = true
	emit_signal("myReadySignal")
	doneLoading = true
	emit_signal("doneLoadingSignal")


signal playerModifierDictionaryRequested
func _on_combat_panel_player_modifier_dictionary_requested(emitter) -> void:
	emit_signal("playerModifierDictionaryRequested", emitter)

signal playerSubclassRequested
func _on_combat_panel_player_subclass_requested(emitter) -> void:
	emit_signal("playerSubclassRequested", emitter)
	
signal weaponResourceRequested
func _on_combat_panel_weapon_resource_requested(emitter) -> void:
	emit_signal("weaponResourceRequested", emitter)
