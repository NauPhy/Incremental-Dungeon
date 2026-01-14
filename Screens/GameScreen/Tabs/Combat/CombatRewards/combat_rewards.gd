extends Panel

signal finished
signal waitingForUser

const entryLoader = preload("res://Screens/GameScreen/Tabs/Combat/CombatRewards/combat_reward_entry.tscn")

func _ready() :
	self.visible = false
	$Content/Details.setOption0(" Take ")
	$Content/Details.setOption1(" Discard ")

var initialisationPending : bool = false
signal initialisationComplete
func initialise(rewards : Dictionary) :
	initialisationPending = true
	for index in range(0, rewards["currency"].size()) :
		if (rewards["currency"][index] == 0) :
			continue
		var entry = entryLoader.instantiate()
		$Content/InventoryPanel/VBoxContainer.add_child(entry)
		entry.initialise_currency(index, rewards["currency"][index])
		entry.connect("wasSelected", _on_entry_selected)
	for index in range(0,rewards["equipment"].size()) :
		var entry = entryLoader.instantiate()
		$Content/InventoryPanel/VBoxContainer.add_child(entry)
		entry.initialise(rewards["equipment"][index])
		entry.connect("wasSelected", _on_entry_selected)
	var changed : bool = false
	var optionsCopy = IGOptions.getIGOptionsCopy()
	var encounteredItems : Array = optionsCopy["encounteredItems"]
	for entry in getItemList() :
		if (encounteredItems.find(entry.getItemSceneRef().getItemName()) == -1) :
			changed = true
			encounteredItems.append(entry.getItemSceneRef().getItemName())
	if (changed) :
		encounteredItems.sort_custom(func(a,b) : a<b)
		optionsCopy["encounteredItems"] = encounteredItems
		IGOptions.saveAndUpdateIGOptions(optionsCopy)
		
	for entry in getItemList() :
		var indivSetting = optionsCopy["individualEquipmentTake"].get(entry.getItemSceneRef().getItemName())
		if (indivSetting == null) :
			indivSetting = 0
		# wait
		if (indivSetting == 0) :
			pass
		# always take
		elif (indivSetting == 1) :
			waitingForResponse = true
			emit_signal("addToInventoryRequested", entry.getItemSceneRef(), true)
			if (waitingForResponse) :
				await responseReceived
		# always discard
		elif (indivSetting == 2) :
			entry.queue_free()
		else :
			initialisationPending = false
			emit_signal("initialisationComplete")
			return
	await get_tree().process_frame
	if (getItemList().is_empty()) :
		suicide()
	else :
		var firstEntry = $Content/InventoryPanel/VBoxContainer.get_child(0)
		firstEntry.getItemSceneRef().select()
		$Content/Details.setItemSceneRefBase(firstEntry.getItemSceneRef())
		self.visible = true
		initialisationPending = false
		emit_signal("initialisationComplete")
		emit_signal("waitingForUser")
		
func _on_entry_selected(itemSceneRef) :
	$Content/Details.setItemSceneRefBase(itemSceneRef)
	for child in getItemList() :
		if (child.getItemSceneRef() != itemSceneRef) :
			child.getItemSceneRef().deselect()

signal addToInventoryRequested
func _on_details_option_pressed(itemSceneRef, val : int) -> void:
	if (val == 0) :
		waitingForResponse = true
		emit_signal("addToInventoryRequested", itemSceneRef, false)
	else :
		removeItemFromList(itemSceneRef)
	
func findItem(item : Equipment) :
	for child in $Content/InventoryPanel/VBoxContainer.get_children() :
		if (child.getItemSceneRef() == item) :
			return child
	return null
	
func getItemList() :
	return $Content/InventoryPanel/VBoxContainer.get_children()

func removeItemFromList(itemSceneRef) :
	var itemList = $Content/InventoryPanel/VBoxContainer.get_children()
	var killableIndex
	var killableScene
	for index in range(0,itemList.size()) :
		if (itemList[index].getItemSceneRef() == itemSceneRef) :
			killableIndex = index
			killableScene = itemList[index]
			break
	#Explicitly remove child because sometimes it seems to take more than 1 frame
	$Content/InventoryPanel/VBoxContainer.remove_child(killableScene)
	killableScene.queue_free()
	await get_tree().process_frame
	var newItemList = $Content/InventoryPanel/VBoxContainer.get_children()
	if (newItemList.is_empty()) :
		suicide()
		return
	var newIndex
	if (killableIndex == newItemList.size()) :
		newIndex = newItemList.size()-1
	else :
		newIndex = killableIndex
	if (newItemList.size()-1>=newIndex && newItemList[newIndex] != null) :
		$Content/Details.setItemSceneRefBase(newItemList[newIndex].getItemSceneRef())
	newItemList[newIndex].getItemSceneRef().select()
	waitingForResponse = false
	addDenied = false
	emit_signal("responseReceived")
	
func denyAddToInventory() :
	waitingForResponse = false
	addDenied = true
	emit_signal("responseReceived")

var waitingForResponse : bool = false
var addDenied : bool = false
signal responseReceived
func _on_take_all_button_pressed() -> void:
	for item in getItemList() :
		if (waitingForResponse) :
			await responseReceived
		if (addDenied) :
			addDenied = false
			return
		waitingForResponse = true
		emit_signal("addToInventoryRequested", item.getItemSceneRef(), false)
	if (waitingForResponse) :
		await responseReceived
	if (addDenied) :
		addDenied = false
		return
	suicide()

func suicide() :
	if (initialisationPending) :
		initialisationPending = false
		emit_signal("initialisationComplete")
	finishedBool = true
	emit_signal("finished")
	queue_free()

var finishedBool : bool = false
func isFinished() -> bool :
	return finishedBool
	
