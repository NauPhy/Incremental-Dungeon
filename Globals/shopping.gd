extends Node
############################################################
## Saving
var myReady : bool = false
func _ready() :
	self.add_to_group("Saveable")
	myReady = true
	
func getSaveDictionary() -> Dictionary :
	var retVal = {}
	retVal["unlockedRoutines"] = unlockedRoutines
	retVal["itemPrices"] = itemPrices
	return retVal

func beforeLoad(newGame) :
	if (newGame) :
		var routineList = MegaFile.Routine_FilesDictionary.keys()
		unlockedRoutines.append(routineList.find("lift_weights"))
		unlockedRoutines.append(routineList.find("pickpocket_goblins"))
		unlockedRoutines.append(routineList.find("punch_walls"))
		unlockedRoutines.append(routineList.find("read_novels"))
		unlockedRoutines.append(routineList.find("spar"))
			
func onLoad(loadDict) :
	if (loadDict.get("unlockedRoutines") != null) :
		unlockedRoutines = loadDict["unlockedRoutines"]
	if (loadDict.get("itemPrices") != null) :
		itemPrices = loadDict["itemPrices"]
###################################################################################
## General
signal removeCurrencyRequested
const requestPurchase_currencyNames = ["gold_coin"]
func purchaseItem(type : String, item : int) -> bool:
	var currency : Currency
	if (type == "routine") :
		currency = EquipmentDatabase.getEquipment(requestPurchase_currencyNames[0])
	else :
		return false
	var currencyCount = await getCurrencyAmount(currency)
	if (currencyCount < itemPrices[item]) :
		return false
	if (await givePurchaseBenefit("routine", item)) :
		emit_signal("removeCurrencyRequested", EquipmentDatabase.getEquipment("gold_coins"), itemPrices[item])
	else :
		return false
	itemPrices[type][item] = getNextItemPrice(type, item)
	return true
	
func givePurchaseBenefit(type : String, item : int) -> bool:
	confirmed = false
	awaitingConfirmation = true
	if (type == "routine") :
		givePurchaseBenefit_routine(item)
	else :
		return false
	if (awaitingConfirmation) :
		await confirmationReceived
	return confirmed

func getNextItemPrice(type, item) -> int :
	var currentVal = itemPrices[type][item]
	const standardScale = pow(2,0.25)
	if (currentVal == -1) :
		return -1
	if (type == "routine") :
		if (item == routinePurchasable.speed) :
			if (currentVal < 20) :
				return currentVal + 3
			return currentVal * standardScale
		elif (item == routinePurchasable.effect) :
			if (currentVal < 28) :
				return currentVal + 4
			return currentVal * standardScale
		else :
			return -1
	else :
		return -1
##################################################################################
## Communication
signal addPermanentModiferRequested
signal confirmationReceived
var awaitingConfirmation : bool = false
var confirmed : bool = false
func provideConfirmation(val) :
	confirmed = val
	awaitingConfirmation = false
	emit_signal("confirmationReceived")

signal currencyAmountRequested
signal currencyAmountReceived
var currencyAmount_comm : int
var waitingForCurrencyAmount : bool = false
func getCurrencyAmount(item : Currency) -> int :
	waitingForCurrencyAmount = true
	var currencyType : Equipment
	emit_signal("currencyAmountRequested", item, self)
	if (waitingForCurrencyAmount) :
		await currencyAmountReceived
	return currencyAmount_comm
func provideCurrencyAmount(val) :
	currencyAmount_comm = val
	waitingForCurrencyAmount = false
	emit_signal("currencyAmountReceived")
	
func addNewShop(emitter) :
	emitter.connect("purchaseRequested", _on_purchase_requested)
	
func _on_purchase_requested(item, price, myCurrency, emitter) :
	if (item is Equipment) :
		return
	elif (item is String) :
		var type = shopNames.find_key(emitter.getName())
		var index = routinePurchasableDictionary.find_key(item)
		if (await purchaseItem(type, index)) :
			emitter.setCurrencyAmount(await getCurrencyAmount(myCurrency))
	
############################################################################################################
## Hardcoded or default values
enum routinePurchasable {
	speed,
	effect,
	mixed,
	randomRoutine,
	upgradeRoutine
}
const routinePurchasableDictionary = {
	routinePurchasable.speed : "Improved Form",
	routinePurchasable.effect : "Improved Equipment",
	routinePurchasable.mixed : "Refined Fundamentals",
	routinePurchasable.randomRoutine : "Obtain random routine",
	routinePurchasable.upgradeRoutine : "Upgrade random routine"
}
var itemPrices : Dictionary = {
	"routine" : {
		routinePurchasable.speed : 14,
		routinePurchasable.effect : 20,
		routinePurchasable.mixed : 10000,
		routinePurchasable.randomRoutine : 100, 
		routinePurchasable.upgradeRoutine : -1
	}
}
const shopNames = {
	"routine" : "sample name"
}
func createRoutineShop() -> ShopDetails :
	var retVal = ShopDetails.new()
	retVal.shopName = shopNames["routine"]
	retVal.shopCurrency = EquipmentDatabase.getEquipment("gold_coin")
	retVal.shopCurrencyTexture = SceneLoader.createEquipmentScene("gold_coin").getTextureCopy()
	var column1 : ShopColumn = ShopColumn.new()
	column1.columnName = "Routine Power"
	column1.purchasables = []
	for key in range(routinePurchasable.speed, routinePurchasable.randomRoutine) :
		var newItem : Purchasable = Purchasable.new()
		newItem.purchasableName = routinePurchasableDictionary[key]
		newItem.purchasablePrice = itemPrices["routine"][key]
		newItem.equipment_optional = null
		column1.purchasables.append(newItem)
	var column2 : ShopColumn = ShopColumn.new()
	column2.columnName = "New Routines"
	column2.purchasables = []
	for key in range(routinePurchasable.randomRoutine, routinePurchasable.upgradeRoutine + 1) :
		var newItem : Purchasable = Purchasable.new()
		newItem.purchasableName = routinePurchasableDictionary[key]
		newItem.purchasablePrice = itemPrices["routine"][key]
		newItem.equipment_optional = null
		column2.purchasables.append(newItem)
	retVal.shopContents = [column1, column2]
	return retVal
	
	
################################################################################
## Purchase benefits
signal unlockRoutineRequested
signal upgradeRoutineRequested
var unlockedRoutines : Array[int] = []
func givePurchaseBenefit_routine(item : routinePurchasable) :
	var value : Array[float]
	var type : String
	var statEnum : Array[int]
	var isMultiplicative : bool
	var source = routinePurchasableDictionary[item]
	if (item == routinePurchasable.speed) :
		value = [pow(2,0.25)]
		type = "otherStat"
		statEnum = [Definitions.otherStatEnum.routineSpeed]
		isMultiplicative = true
		awaitingConfirmation = true
		emit_signal("addPermanentModifierRequested", value, type, statEnum, source, isMultiplicative)
	elif (item == routinePurchasable.effect) :
		value = [pow(2,0.25)]
		type = "otherStat"
		statEnum = [Definitions.otherStatEnum.routineEffect]
		isMultiplicative = true
		awaitingConfirmation = true
		emit_signal("addPermanentModifierRequested", value, type, statEnum, source, isMultiplicative)
	elif (item == routinePurchasable.mixed) :
		value = [0.1, 1.2]
		type = "otherStat"
		statEnum = [Definitions.otherStatEnum.routineSpeed, Definitions.otherStatEnum.routineEffect]
		isMultiplicative = true
		awaitingConfirmation = true
		emit_signal("addPermanentModifierRequested", value, type, statEnum, source, isMultiplicative)
	elif (item == routinePurchasable.randomRoutine) :
		var routineList = MegaFile.getAllRoutine()
		if (unlockedRoutines.size() >= routineList.size()) :
			return
		var roll = randi_range(0,routineList.size()-unlockedRoutines.size()-1)
		var count = 0
		for index in range(0,routineList.size()) :
			if (unlockedRoutines.find(index) == -1) :
				continue
			elif (count != roll) :
				count += 1
			else :
				unlockedRoutines.append(index)
				break
		awaitingConfirmation = true
		emit_signal("unlockRoutineRequested", MegaFile.getRoutine(routineList[unlockedRoutines.back()]))
	elif (item == routinePurchasable.upgradeRoutine) :
		var routineList = MegaFile.getAllRoutine()
		awaitingConfirmation = true
		emit_signal("upgradeRoutineRequested", MegaFile.getRoutine(routineList[randi_range(0,routineList.size()-1)]))
	else :
		return
