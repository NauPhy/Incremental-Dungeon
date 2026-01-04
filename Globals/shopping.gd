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
	retVal["armorUnlocked"] = armorUnlocked
	retVal["weaponUnlocked"] = weaponUnlocked
	if (armorTimer.is_stopped()) :
		retVal["armorTime"] = "stopped"
	else :
		retVal["armorTime"] = armorTimer.time_left
	if (weaponTimer.is_stopped()) :
		retVal["weaponTime"] = "stopped"
	else :
		retVal["weaponTime"] = weaponTimer.time_left
	return retVal

func beforeLoad(newGame) :
	setupDescriptions()
	setupTimers()
	if (newGame) :
		resetItemPrices()
		var routineList = MegaFile.Routine_FilesDictionary.keys()
		unlockedRoutines.append(routineList.find("lift_weights"))
		unlockedRoutines.append(routineList.find("pickpocket_goblins"))
		unlockedRoutines.append(routineList.find("punch_walls"))
		unlockedRoutines.append(routineList.find("read_novels"))
		unlockedRoutines.append(routineList.find("spar"))

var armorUnlocked : bool = false
var weaponUnlocked : bool = false
func onLoad(loadDict) :
	if (loadDict.get("unlockedRoutines") != null) :
		unlockedRoutines = loadDict["unlockedRoutines"]
	if (loadDict.get("itemPrices") != null) :
		itemPrices = loadDict["itemPrices"]
	var tempArmor
	var tempWeapon
	if (!(loadDict["armorTime"] is String && loadDict["armorTime"] == "stopped")) :
		tempArmor = loadDict["armorTime"]
	else :
		tempArmor = -1
	if (!(loadDict["weaponTime"] is String && loadDict["weaponTime"] == "stopped")) :
		tempWeapon = loadDict["weaponTime"]
	else :
		tempWeapon = -1
	armorUnlocked = loadDict["armorUnlocked"]
	weaponUnlocked = loadDict["weaponUnlocked"]
	if (armorUnlocked) :
		armorTimer.start(tempArmor)
	if (weaponUnlocked) :
		weaponTimer.start(tempWeapon)
		
###################################################################################
## General
signal removeCurrencyRequested
const requestPurchase_currencyNames = ["gold_coin", "ore"]
func purchaseItem(type : String, item : int, purchase : Purchasable) -> bool:
	var currency : Currency
	if (type == "routine") :
		currency = EquipmentDatabase.getEquipment(requestPurchase_currencyNames[0])
	elif (type == "armor") :
		currency = EquipmentDatabase.getEquipment(requestPurchase_currencyNames[1])
	else :
		return false
	var currencyCount = await getCurrencyAmount(currency)
	if (currencyCount < purchase.purchasablePrice) :
		return false
	if (await givePurchaseBenefit(type, item, purchase)) :
		emit_signal("removeCurrencyRequested", currency, purchase.purchasablePrice)
	else :
		return false
	itemPrices[type][item] = getNextItemPrice(type, item)
	return true
	
func givePurchaseBenefit(type : String, item : int, purchase : Purchasable) -> bool:
	confirmed = false
	awaitingConfirmation = true
	if (type == "routine") :
		givePurchaseBenefit_routine(item)
	elif (type == "armor") :
		givePurchaseBenefit_armor(item, purchase)
	else :
		return false
	if (awaitingConfirmation) :
		await confirmationReceived
	return confirmed

func getNextItemPrice(type, item) -> int :
	var currentVal = itemPrices[type][item]
	if (currentVal == -1) :
		return -1
	if (type == "routine") :
		return getNextItemPrice_routine(item)
	elif (type == "armor") :
		return getNextItemPrice_armor(item) 
	else :
		return -1

func getNextItemPrice_routine(item) -> int :
	const standardScale = pow(2,0.125)
	var currentVal = itemPrices["routine"][item]
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
		
func getNextItemPrice_armor(item) -> int :
	var currentVal = itemPrices["armor"][item]
	if (item == armorPurchasable.premadeArmor) :
		## One time purchase
		return -1
	elif (item == armorPurchasable.newArmor) :
		## Arbitrary
		return currentVal * 1.2
	elif (item == armorPurchasable.reforge) :
		return currentVal
	elif (item == armorPurchasable.statUpgrade_phys || item == armorPurchasable.statUpgrade_mag) :
		## Arbitrary
		return currentVal * 5
	else :
		return -1
##################################################################################
## Communication
signal nodeScalingRequested
signal nodeScalingReceived
var waitingOnNodeScaling : bool = false
var nodeScaling_comm : float = 0
func getNodeScaling() :
	waitingOnNodeScaling = true
	emit_signal("nodeScalingRequested")
	if (waitingOnNodeScaling) :
		await nodeScalingReceived
	return nodeScaling_comm
func provideNodeScaling(val) :
	nodeScaling_comm = val
	waitingOnNodeScaling = false
	emit_signal("nodeScalingReceived")

signal addPermanentModifierRequested
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
	
func _on_purchase_requested(item, _price, myCurrency, emitter, purchase : Purchasable) :
	if (item is Equipment) :
		return
	elif (item is String) :
		var type = shopNames.find_key(emitter.getName())
		var index = routinePurchasableDictionary.find_key(item)
		if (await purchaseItem(type, index, purchase)) :
			emitter.setCurrencyAmount(await getCurrencyAmount(myCurrency))
			emitter.refreshPrice(item, itemPrices[type][index])
	else :
		return
		
signal randomItemRequested
var waitingForRandomItem : bool = false
signal randomItemReceived
var randomItem_comm : Equipment = null
func createRandomItem(type : Definitions.equipmentTypeEnum) :
	waitingForRandomItem = true
	emit_signal("randomItemRequested", type)
	if (waitingForRandomItem) :
		await randomItemReceived
	return randomItem_comm
func provideRandomItem(val : Equipment) :
	randomItem_comm = val
	waitingForRandomItem = false
	emit_signal("randomItemReceived")
func createRandomArmor() :
	return await createRandomItem(Definitions.equipmentTypeEnum.armor)
func createRandomWeapon() :
	return await createRandomItem(Definitions.equipmentTypeEnum.weapon)
	
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
var routineDescriptionDictionary = {}
enum armorPurchasable {
	premadeArmor,
	newArmor,
	reforge,
	statUpgrade_phys,
	statUpgrade_mag
}
const itemPriceBase : Dictionary = {
	"routine" : {
		routinePurchasable.speed : 14,
		routinePurchasable.effect : 20,
		routinePurchasable.mixed : 10000,
		routinePurchasable.randomRoutine : 100, 
		routinePurchasable.upgradeRoutine : -1
	},
	## Currency is 1x ore
	## Expected currency/node at start is 48
	"armor" : {
		armorPurchasable.premadeArmor: 30,
		armorPurchasable.newArmor : 15,
		armorPurchasable.reforge : 20,
		armorPurchasable.statUpgrade_phys : 20,
		armorPurchasable.statUpgrade_mag : 20
	}
}
func getEquipmentTime(type : Definitions.equipmentTypeEnum) -> float :
	if (type == Definitions.equipmentTypeEnum.armor) :
		return armorTimer.time_left
	elif (type == Definitions.equipmentTypeEnum.weapon) :
		return weaponTimer.time_left
	else :
		return -1
	
func _on_equipment_shop_launch(type : Definitions.equipmentTypeEnum) :
	if (type == Definitions.equipmentTypeEnum.armor) :
		if (!armorUnlocked) :
			armorUnlocked = true
			armorTimer.start()
	elif (type == Definitions.equipmentTypeEnum.weapon) :
		if (!weaponUnlocked) :
			weaponUnlocked = true
			weaponTimer.start()
	else :
		return
		
var itemPrices : Dictionary = itemPriceBase
func resetItemPrices() :
	itemPrices = itemPriceBase.duplicate()
const shopNames = {
	"routine" : "Training Instructor",
	"armor" : "Armory",
	"weapon" : "Weaponsmith"
}
func createShop(shopType) -> ShopDetails :
	if (shopType == "routine") :
		return createRoutineShop()
	elif (shopType == "armor") :
		return await createArmorShop()
	else :
		return ShopDetails.new()
func createRoutineShop() -> ShopDetails :
	var retVal = ShopDetails.new()
	retVal.shopName = shopNames["routine"]
	retVal.shopCurrency = EquipmentDatabase.getEquipment("gold_coin")
	retVal.shopCurrencyTexture = SceneLoader.createEquipmentScene("gold_coin").getTextureCopy()
	var column1 : ShopColumn = ShopColumn.new()
	column1.columnName = "Enhance Routines"
	column1.purchasables = []
	for key in range(routinePurchasable.speed, routinePurchasable.randomRoutine) :
		var newItem : Purchasable = Purchasable.new()
		newItem.purchasableName = routinePurchasableDictionary[key]
		newItem.description = routineDescriptionDictionary[key]
		newItem.purchasablePrice = itemPrices["routine"][key]
		newItem.equipment_optional = null
		column1.purchasables.append(newItem)
	var column2 : ShopColumn = ShopColumn.new()
	column2.columnName = "New Routines"
	column2.purchasables = []
	for key in range(routinePurchasable.randomRoutine, routinePurchasable.upgradeRoutine + 1) :
		var newItem : Purchasable = Purchasable.new()
		newItem.purchasableName = routinePurchasableDictionary[key]
		newItem.description = routineDescriptionDictionary[key]
		newItem.purchasablePrice = itemPrices["routine"][key]
		newItem.equipment_optional = null
		column2.purchasables.append(newItem)
	var columnArr : Array[ShopColumn] = [column1, column2]
	retVal.shopContents = columnArr
	return retVal

func createArmorShop() :
	var retVal = ShopDetails.new()
	retVal.shopName = shopNames["armor"]
	retVal.shopCurrency = EquipmentDatabase.getEquipment("ore")
	retVal.shopCurrencyTexture = SceneLoader.createEquipmentScene("ore").getTextureCopy()
	var column1 : ShopColumn = ShopColumn.new()
	column1.columnName = "Armor for Sale"
	column1.purchasables = []
	for index in range(0,3) :
		var newItem : Purchasable = Purchasable.new()
		newItem.equipment_optional = await createRandomArmor()
		newItem.purchasableName = newItem.equipment_optional.getName()
		newItem.description = ""
		newItem.purchasablePrice = itemPrices["armor"][armorPurchasable.premadeArmor] * pow(1.05,(newItem.equipment_optional.equipmentGroups.quality as int))
		column1.purchasables.append(newItem)
		
	var column2 : ShopColumn = ShopColumn.new()
	column2.columnName = "Forge New Armor"
	column2.purchasables = []
	var col2Item : Purchasable = Purchasable.new()
	col2Item.equipment_optional = null
	col2Item.purchasableName = "Buy Random Armor"
	col2Item.description = "Get a random armor! Price increases each purchase, but is reset on shop refresh. Elemental equipment has a 0.5x drop rate penalty."
	col2Item.purchasablePrice = itemPrices["armor"][armorPurchasable.newArmor]
	column2.purchasables.append(col2Item)
	
	var column3 : ShopColumn = ShopColumn.new()
	column3.columnName = "Reforge Armor"
	column3.purchasables = []
	var col3Item : Purchasable = Purchasable.new()
	col3Item.equipment_optional = null
	col3Item.purchasableName = "Reforge"
	col3Item.description = "Upgrade the stats of your currently equipped Armor to be as if dropped by your strongest defeated enemy! Price increases per-item with every use."
	col3Item.purchasablePrice = itemPrices["armor"][armorPurchasable.reforge]
	column3.purchasables.append(col3Item)
	
	var column4 : ShopColumn = ShopColumn.new()
	column4.columnName = "Stat Upgrades"
	column4.purchasables = []
	var col4Phys : Purchasable = Purchasable.new()
	col4Phys.equipment_optional = null
	col4Phys.purchasableName = "Upgrade PHYSDEF"
	col4Phys.description = "Permanently increase your PHYSDEF Standard Multiplier by +0.05"
	col4Phys.purchasablePrice = itemPrices["armor"][armorPurchasable.statUpgrade_phys]
	column4.purchasables.append(col4Phys)
	var col4Mag : Purchasable = Purchasable.new()
	col4Mag.equipment_optional = null
	col4Mag.purchasableName = "Upgrade MAGDEF"
	col4Mag.description = "Permanently increase your MAGDEF Standard Multiplier by +0.05"
	col4Mag.purchasablePrice = itemPrices["armor"][armorPurchasable.statUpgrade_mag]
	column4.purchasables.append(col4Mag)
	
	var columnArr : Array[ShopColumn] = [column1, column2, column3, column4]
	retVal.shopContents = columnArr
	return retVal
	
################################################################################
## Purchase benefits
signal unlockRoutineRequested
signal upgradeRoutineRequested
var unlockedRoutines : Array = []
func givePurchaseBenefit_routine(item : routinePurchasable) :
	var value : Array[float]
	var type : String
	var statEnum : Array[int]
	var isMultiplicative : bool
	var source = routinePurchasableDictionary[item]
	var modType = "Premultiplier"
	
	if (item == routinePurchasable.speed) :
		value = [pow(2,0.125)]
		type = "otherStat"
		statEnum = [Definitions.otherStatEnum.routineSpeed]
		isMultiplicative = true
		awaitingConfirmation = true
		emit_signal("addPermanentModifierRequested", value, type, statEnum, source, modType, isMultiplicative)
	elif (item == routinePurchasable.effect) :
		value = [pow(2,0.125)]
		type = "otherStat"
		statEnum = [Definitions.otherStatEnum.routineEffect]
		isMultiplicative = true
		awaitingConfirmation = true
		emit_signal("addPermanentModifierRequested", value, type, statEnum, source, modType, isMultiplicative)
	elif (item == routinePurchasable.mixed) :
		value = [0.1, 1.2]
		type = "otherStat"
		statEnum = [Definitions.otherStatEnum.routineSpeed, Definitions.otherStatEnum.routineEffect]
		isMultiplicative = true
		awaitingConfirmation = true
		emit_signal("addPermanentModifierRequested", value, type, statEnum, source, modType, isMultiplicative)
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

signal addToInventoryRequested
signal reforgeItemRequested
func givePurchaseBenefit_armor(item : armorPurchasable, purchase : Purchasable) :
	if (item == armorPurchasable.premadeArmor) :
		emit_signal("addToInventoryRequested", purchase)
	elif (item == armorPurchasable.newArmor) :
		var newArmor = await createRandomArmor()
		emit_signal("addToInventoryRequested", purchase)
	elif (item == armorPurchasable.reforge) :
		##Inventory keeps track of what's dragged off
		emit_signal("reforgeItemRequested")
	elif (item == armorPurchasable.statUpgrade_phys || item == armorPurchasable.statUpgrade_mag) :
		var value = 0.05
		var type = "stat"
		var statEnum
		if (item == armorPurchasable.statUpgrade_phys) :
			statEnum = Definitions.baseStatEnum.PHYSDEF
		elif (item == armorPurchasable.statUpgrade_mag) :
			statEnum = Definitions.baseStatEnum.MAGDEF
		else :
			return
		var isMultiplicative = false
		var source = "Armory Upgrade"
		var modType = "Postmultiplier"
		emit_signal("addPermanentModifierRequested", value, type, statEnum, source, modType, isMultiplicative)
	else :
		return
	
func setupDescriptions() :
	var standardScaling = pow(2,0.125)
	var standardScalingString = str(Helpers.myRound(standardScaling, 3))
	var dict1 = routineDescriptionDictionary
	dict1[routinePurchasable.speed] = Definitions.otherStatDictionary[Definitions.otherStatEnum.routineSpeed] + " Multiplier [color=green]x" + standardScalingString + "[/color]."
	dict1[routinePurchasable.effect] = Definitions.otherStatDictionary[Definitions.otherStatEnum.routineEffect] + " Multiplier [color=green]x" + standardScalingString + "[/color]."
	dict1[routinePurchasable.mixed] = Definitions.otherStatDictionary[Definitions.otherStatEnum.routineSpeed] + " Multiplier [color=red]x" + "0.1" + "[/color]." + "\n"
	dict1[routinePurchasable.mixed] += Definitions.otherStatDictionary[Definitions.otherStatEnum.routineEffect] + " Multiplier [color=green]x" + "1.2" + "[/color]."
	dict1[routinePurchasable.randomRoutine] = "Unlock a random new Routine!"
	dict1[str(routinePurchasable.randomRoutine)+"alt"] = "All routines unlocked!"
	dict1[routinePurchasable.upgradeRoutine] = "Upgrade a random routine! For a single routine, all RGR Standard Multiplier Bonuses [color=green]+" + "0.25" + "[/color]."

var armorTimer : Timer
var weaponTimer : Timer
func setupTimers() :
	armorTimer = Timer.new()
	add_child(armorTimer)
	armorTimer.one_shot = false
	armorTimer.wait_time = 30*60
	armorTimer.connect("timeout", _on_armor_timeout)
	weaponTimer = Timer.new()
	add_child(weaponTimer)
	weaponTimer.one_shot = false
	weaponTimer.wait_time = 30*60
	weaponTimer.connect("timeout", _on_weapon_timeout)
	
func _on_armor_timeout() :
	var nodeScaling = await getNodeScaling()
	itemPrices["armor"][armorPurchasable.premadeArmor] = itemPriceBase["armor"][armorPurchasable.premadeArmor] * nodeScaling
	itemPrices["armor"][armorPurchasable.newArmor] = itemPriceBase["armor"][armorPurchasable.newArmor] * nodeScaling
	itemPrices["armor"][armorPurchasable.reforge] = itemPriceBase["armor"][armorPurchasable.reforge] * nodeScaling
	
func _on_weapon_timeout() :
	return
	
