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
	retVal["myArmor"] = []
	for armor in myArmor :
		if (armor == null) :
			retVal["myArmor"].append("null")
		else :
			retVal["myArmor"].append(armor.getItemName())
	retVal["armorScaling"] = armorScaling
	retVal["myWeapons"] = []
	for weapon in myWeapons :
		if (weapon == null) :
			retVal["myWeapons"].append("null")
		else :
			retVal["myWeapons"].append(weapon.getItemName())
	retVal["weaponScaling"] = weaponScaling
	return retVal

func beforeLoad(newGame) :
	resetSaveSpecificVariants()
	setupDescriptions()
	setupTimers()
	if (newGame) :
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
	weaponScaling = loadDict["weaponScaling"]
	armorScaling = loadDict["armorScaling"]
	for weapon in loadDict["myWeapons"] :
		if (weapon == "null") :
			myWeapons.append(null)
		else :
			myWeapons.append(EquipmentDatabase.getEquipment(weapon).getAdjustedCopy(weaponScaling))
	for armor in loadDict["myArmor"] :
		if (armor == "null") :
			myArmor.append(null)
		else :
			myArmor.append(EquipmentDatabase.getEquipment(armor).getAdjustedCopy(armorScaling))
		
###################################################################################
## General

func resetSaveSpecificVariants() :
	armorUnlocked = false
	weaponUnlocked = false
	waitingOnEquipmentScaling = false
	waitingOnCurrencyScaling = false
	awaitingConfirmation = false
	waitingForCurrencyAmount = false
	waitingForRandomItem = false
	itemPrices = itemPriceBase.duplicate()
	unlockedRoutines = []
	if (armorTimer != null) :
		armorTimer.queue_free()
		armorTimer = null
	if (weaponTimer != null) :
		weaponTimer.queue_free()
		weaponTimer = null
	myArmor = []
	myWeapons = []
	armorScaling = 0
	weaponScaling = 0
	routineDescriptionDictionary = {}
	
signal removeCurrencyRequested
const requestPurchase_currencyNames = ["gold_coin", "ore"]
func purchaseItem(type : String, item : int, purchase : Purchasable) -> bool:
	var currency : Currency
	if (type == "routine") :
		currency = EquipmentDatabase.getEquipment(requestPurchase_currencyNames[0])
	elif (type == "armor" || type == "weapon") :
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
	elif (type == "weapon") :
		givePurchaseBenefit_weapon(item, purchase)
	elif (type == "soul") :
		givePurchaseBenefitSoul(item, purchase)
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
	elif (type == "weapon") :
		return getNextItemPrice_weapon(item)
	elif (type == "soul") :
		return getNextItemPrice_soul(item)
	else :
		return -1

func getNextItemPrice_routine(item) -> int :
	const standardScale = pow(2,0.125)
	var currentVal = itemPrices["routine"][item]
	if (item == routinePurchasable.speed) :
		return currentVal * standardScale
	elif (item == routinePurchasable.effect) :
		return currentVal * standardScale
	elif (item == routinePurchasable.mixed) :
		return currentVal * 10
	## It's 25x more expensive (5000) at the end of floor 5
	elif (item == routinePurchasable.randomRoutine) :
		return currentVal * 1.5838
	elif (item == routinePurchasable.upgradeRoutine) :
		return currentVal * standardScale
	else :
		return -1
		
func getNextItemPrice_armor(item) -> int :
	var currentVal = itemPrices["armor"][item]
	if (item == armorPurchasable.premadeArmor) :
		## One time purchase
		return currentVal
	elif (item == armorPurchasable.newArmor) :
		## Arbitrary
		return currentVal * 1.2
	elif (item == armorPurchasable.reforge) :
		return currentVal * 1.5
	elif (item == armorPurchasable.statUpgrade_phys || item == armorPurchasable.statUpgrade_mag) :
		## Intended to purchase 7-8 times throughout the game. The 9th time will cost 20 minutes of grinding.
		return currentVal * 2.484
	else :
		return -1
func getNextItemPrice_weapon(item) -> int :
	var currentVal = itemPrices["weapon"][item]
	if (item == weaponPurchasable.premadeWeapon) :
		## One time purchase
		return currentVal
	elif (item == weaponPurchasable.newWeapon) :
		## Arbitrary
		return currentVal * 1.2
	elif (item == weaponPurchasable.reforge) :
		return currentVal * 1.5
	elif (item == weaponPurchasable.statUpgrade_DR) :
		## Intended to purchase 7-8 times throughout the game
		return currentVal * 2.484
	else :
		return -1
		
func getNextItemPrice_soul(item) -> int :
	var currentVal = itemPrices["soul"][item]
	if ((soulPurchasable.fighterSubclass_1 as int) <= (item as int) && (item as int) <= (soulPurchasable.mageSubclass_2 as int)) :
		return currentVal
	elif (item == soulPurchasable.respec) :
		return currentVal
	## Sould be able to use it 12 times before the final boss.
	elif (item == soulPurchasable.inventorySpace) :
		return currentVal * 1.59
	else :
		return -1
		
##################################################################################
## Communication
signal equipmentScalingRequested
signal equipmentScalingReceived
var waitingOnEquipmentScaling : bool = false
var equipmentScaling_comm : float = 0
func getEquipmentScaling() :
	waitingOnEquipmentScaling = true
	emit_signal("equipmentScalingRequested")
	if (waitingOnEquipmentScaling) :
		await equipmentScalingReceived
	return equipmentScaling_comm
func provideEquipmentScaling(val) :
	equipmentScaling_comm = val
	waitingOnEquipmentScaling = false
	emit_signal("equipmentScalingReceived")
	
signal currencyScalingRequested
signal currencyScalingReceived
var waitingOnCurrencyScaling : bool = false
var currencyScaling_comm : float = 0
func getCurrencyScaling(type) :
	waitingOnCurrencyScaling = true
	emit_signal("currencyScalingRequested", type)
	if (waitingOnCurrencyScaling) :
		await currencyScalingReceived
	return currencyScaling_comm
func provideCurrencyScaling(val) :
	currencyScaling_comm = val
	waitingOnCurrencyScaling = false
	emit_signal("currencyScalingReceived")

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
	var type = shopNames.find_key(emitter.getName())
	var index
	if (type == "routine") :
		index = routinePurchasableDictionary.find_key(item)
	elif (type == "armor") :
		index = armorPurchasableDictionary.find_key(item)
	elif (type == "weapon") :
		index = weaponPurchasableDictionary.find_key(item)
	else :
		return
	if (await purchaseItem(type, index, purchase)) :
		emitter.setCurrencyAmount(await getCurrencyAmount(myCurrency))
		if (purchase.equipment_optional != null) :
			emitter.onEquipmentSold()
			onEquipmentSold(type, purchase)
		else :
			emitter.refreshPrice(item, itemPrices[type][index])
			
func onEquipmentSold(type, purchase : Purchasable) :
	if (type == "armor") :
		for index in range(0, myArmor.size()) :
			if (myArmor[index] != null && myArmor[index].getItemName() == purchase.equipment_optional.getItemName()) :
				myArmor[index] = null
				break
	elif (type == "weapon") :
		for index in range(0, myWeapons.size()) :
			if (myWeapons[index] != null && myWeapons[index].getItemName() == purchase.equipment_optional.getItemName()) :
				myWeapons[index] = null
				break
			
func onEquippedItem(type, reforges) :
	var currencyScaling = await getCurrencyScaling("armor")
	if (type == "armor") :
		currencyScaling /= pow(2,5.0/4.0)
		itemPrices["armor"][armorPurchasable.reforge] = itemPriceBase["armor"][armorPurchasable.reforge] * currencyScaling * pow(1.5,reforges)
	elif (type == "weapon") :
		currencyScaling /= pow(2,5.0/4.0)
		itemPrices["weapon"][weaponPurchasable.reforge] = itemPriceBase["weapon"][weaponPurchasable.reforge] * currencyScaling * pow(1.5,reforges)
	else :
		return
	
func onUnequippedItem(type) :
	if (type == "armor") :
		itemPrices["armor"][armorPurchasable.reforge] = 0
	elif (type == "weapon") :
		itemPrices["weapon"][weaponPurchasable.reforge] = 0
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
const armorPurchasableDictionary = {
	armorPurchasable.premadeArmor : "premade_int",
	armorPurchasable.newArmor : "Buy Random Armor",
	armorPurchasable.reforge : "Reforge",
	armorPurchasable.statUpgrade_phys : "Upgrade PHYSDEF",
	armorPurchasable.statUpgrade_mag : "Upgrade MAGDEF"
}
enum weaponPurchasable {
	premadeWeapon,
	newWeapon,
	reforge,
	statUpgrade_DR
}
const weaponPurchasableDictionary = {
	weaponPurchasable.premadeWeapon : "premade_int",
	weaponPurchasable.newWeapon : "Buy Random Weapon",
	weaponPurchasable.reforge : "Reforge",
	weaponPurchasable.statUpgrade_DR : "Upgrade DR"
}
var itemPriceBase : Dictionary = {
	"routine" : {
		routinePurchasable.speed : 40,
		routinePurchasable.effect : 51,
		routinePurchasable.mixed : 10000,
		routinePurchasable.randomRoutine : 200, 
		## 8 routines
		routinePurchasable.upgradeRoutine : 5000
	},
	## Currency is 1x ore
	## Expected currency/node at start is 48
	"armor" : {
		armorPurchasable.premadeArmor: 60,
		armorPurchasable.newArmor : 50,
		armorPurchasable.reforge : 40,
		armorPurchasable.statUpgrade_phys : 40,
		armorPurchasable.statUpgrade_mag : 40
	},
	"weapon" : {
		weaponPurchasable.premadeWeapon : 60,
		weaponPurchasable.newWeapon : 50,
		weaponPurchasable.reforge : 40,
		weaponPurchasable.statUpgrade_DR : 40
	},
	"soul" : {
		soulPurchasable.fighterSubclass_1 : 1,
		soulPurchasable.fighterSubclass_2 : 1,
		soulPurchasable.rogueSubclass_1 : 1,
		soulPurchasable.rogueSubclass_2 : 1,
		soulPurchasable.mageSubclass_1 : 1,
		soulPurchasable.mageSubclass_2 : 1,
		soulPurchasable.respec : -1,
		soulPurchasable.randomStat : 80,
		soulPurchasable.inventorySpace : 10
	}
}
enum soulPurchasable{
	fighterSubclass_1,
	fighterSubclass_2,
	rogueSubclass_1,
	rogueSubclass_2,
	mageSubclass_1,
	mageSubclass_2,
	inventorySpace,
	respec,
	randomStat,
}
const soulPurchasableDictionary = {
	soulPurchasable.fighterSubclass_1 : "Subclass: Barbarian",
	soulPurchasable.fighterSubclass_2 : "Subclass: Knight",
	soulPurchasable.rogueSubclass_1 : "Subclass: Munitions Expert",
	soulPurchasable.rogueSubclass_2 : "Subclass: Whirlwind",
	soulPurchasable.mageSubclass_1 : "Subclass: Enchanter",
	soulPurchasable.mageSubclass_2 : "Subclass: Soul Collector",
	soulPurchasable.inventorySpace : "Inventory Space",
	soulPurchasable.respec : "Reset Class",
	#soulPurchasable.magicFind : "Increase Magic Find",
	soulPurchasable.randomStat : "Stat Roulette"
}
func getEquipmentTime(type : Definitions.equipmentTypeEnum) -> float :
	if (type == Definitions.equipmentTypeEnum.armor) :
		return armorTimer.time_left
	elif (type == Definitions.equipmentTypeEnum.weapon) :
		return weaponTimer.time_left
	else :
		return -1
		
func getReforgePrice(type : Definitions.equipmentTypeEnum) -> int :
	if (type == Definitions.equipmentTypeEnum.armor) :
		return itemPrices["armor"][armorPurchasable.reforge]
	elif (type == Definitions.equipmentTypeEnum.weapon) :
		return itemPrices["weapon"][weaponPurchasable.reforge]
	else :
		return 0
	
func _on_equipment_shop_launched(type : Definitions.equipmentTypeEnum) :
	if (type == Definitions.equipmentTypeEnum.armor) :
		if (!armorUnlocked) :
			armorUnlocked = true
			_on_armor_timeout()
			armorTimer.start()
	elif (type == Definitions.equipmentTypeEnum.weapon) :
		if (!weaponUnlocked) :
			weaponUnlocked = true
			_on_weapon_timeout()
			weaponTimer.start()
	else :
		return
		
var itemPrices : Dictionary = {}
func resetItemPrices() :
	for key in itemPriceBase.keys() :
		itemPrices[key] = itemPriceBase[key]
const shopNames = {
	"routine" : "Training Instructor",
	"armor" : "Armory",
	"weapon" : "Weaponsmith",
	"soul" : "Soul Trader"
}
func createShop(shopType) -> ShopDetails :
	if (shopType == "routine") :
		return createRoutineShop()
	elif (shopType == "armor") :
		return await createArmorShop()
	elif (shopType == "weapon") :
		return await createWeaponShop()
	elif (shopType == "soul") :
		return await createSoulShop()
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
	if (!armorUnlocked) :
		_on_equipment_shop_launched(Definitions.equipmentTypeEnum.armor)
	var retVal = ShopDetails.new()
	retVal.shopName = shopNames["armor"]
	retVal.shopCurrency = EquipmentDatabase.getEquipment("ore")
	retVal.shopCurrencyTexture = SceneLoader.createEquipmentScene("ore").getTextureCopy()
	var column1 : ShopColumn = ShopColumn.new()
	column1.columnName = "Armor for Sale"
	column1.purchasables = []
	for index in range(0,myArmor.size()) :
		var newItem : Purchasable = Purchasable.new()
		if (myArmor[index] == null) :
			continue
		newItem.equipment_optional = myArmor[index]
		newItem.purchasableName = armorPurchasableDictionary[armorPurchasable.premadeArmor]
		newItem.description = ""
		newItem.purchasablePrice = itemPrices["armor"][armorPurchasable.premadeArmor] * (1 + 0.1 * (newItem.equipment_optional.equipmentGroups.quality as int))
		column1.purchasables.append(newItem)
		
	var column2 : ShopColumn = ShopColumn.new()
	column2.columnName = "Forge New Armor"
	column2.purchasables = []
	var col2Item : Purchasable = Purchasable.new()
	col2Item.equipment_optional = null
	col2Item.purchasableName = armorPurchasableDictionary[armorPurchasable.newArmor]
	col2Item.description = "Get a random armor! Price increases each purchase, but is reset on shop refresh. Elemental equipment has a 0.5x drop rate penalty."
	col2Item.purchasablePrice = itemPrices["armor"][armorPurchasable.newArmor]
	column2.purchasables.append(col2Item)
	
	var column3 : ShopColumn = ShopColumn.new()
	column3.columnName = "Reforge Armor"
	column3.purchasables = []
	var col3Item : Purchasable = Purchasable.new()
	col3Item.equipment_optional = null
	col3Item.purchasableName = armorPurchasableDictionary[armorPurchasable.reforge]
	col3Item.description = "Upgrade the stats of your currently equipped Armor to be as if dropped by your strongest defeated enemy! Price increases per-item with every use."
	col3Item.purchasablePrice = itemPrices["armor"][armorPurchasable.reforge]
	column3.purchasables.append(col3Item)
	
	var column4 : ShopColumn = ShopColumn.new()
	column4.columnName = "Stat Upgrades"
	column4.purchasables = []
	var col4Phys : Purchasable = Purchasable.new()
	col4Phys.equipment_optional = null
	col4Phys.purchasableName = armorPurchasableDictionary[armorPurchasable.statUpgrade_phys]
	col4Phys.description = "Permanently increase your PHYSDEF Standard Multiplier by +0.05"
	col4Phys.purchasablePrice = itemPrices["armor"][armorPurchasable.statUpgrade_phys]
	column4.purchasables.append(col4Phys)
	var col4Mag : Purchasable = Purchasable.new()
	col4Mag.equipment_optional = null
	col4Mag.purchasableName = armorPurchasableDictionary[armorPurchasable.statUpgrade_mag]
	col4Mag.description = "Permanently increase your MAGDEF Standard Multiplier by +0.05"
	col4Mag.purchasablePrice = itemPrices["armor"][armorPurchasable.statUpgrade_mag]
	column4.purchasables.append(col4Mag)
	
	var columnArr : Array[ShopColumn] = [column1, column2, column3, column4]
	retVal.shopContents = columnArr
	return retVal
	
func createWeaponShop():
	if (!weaponUnlocked) :
		_on_equipment_shop_launched(Definitions.equipmentTypeEnum.weapon)
	var retVal = ShopDetails.new()
	retVal.shopName = shopNames["weapon"]
	retVal.shopCurrency = EquipmentDatabase.getEquipment("ore")
	retVal.shopCurrencyTexture = SceneLoader.createEquipmentScene("ore").getTextureCopy()
	var column1 : ShopColumn = ShopColumn.new()
	column1.columnName = "Weapons for Sale"
	column1.purchasables = []
	for index in range(0,myWeapons.size()) :
		var newItem : Purchasable = Purchasable.new()
		if (myWeapons[index] == null) :
			continue
		newItem.equipment_optional = myWeapons[index]
		newItem.purchasableName = weaponPurchasableDictionary[weaponPurchasable.premadeWeapon]
		newItem.description = ""
		newItem.purchasablePrice = itemPrices["weapon"][weaponPurchasable.premadeWeapon] * (1 + 0.1 * (newItem.equipment_optional.equipmentGroups.quality as int))
		column1.purchasables.append(newItem)
		
	var column2 : ShopColumn = ShopColumn.new()
	column2.columnName = "Forge New Weapon"
	column2.purchasables = []
	var col2Item : Purchasable = Purchasable.new()
	col2Item.equipment_optional = null
	col2Item.purchasableName = weaponPurchasableDictionary[weaponPurchasable.newWeapon]
	col2Item.description = "Get a random weapon! Price increases each purchase, but is reset on shop refresh. Elemental equipment has a 0.5x drop rate penalty."
	col2Item.purchasablePrice = itemPrices["weapon"][weaponPurchasable.newWeapon]
	column2.purchasables.append(col2Item)
	
	var column3 : ShopColumn = ShopColumn.new()
	column3.columnName = "Reforge Weapon"
	column3.purchasables = []
	var col3Item : Purchasable = Purchasable.new()
	col3Item.equipment_optional = null
	col3Item.purchasableName = weaponPurchasableDictionary[weaponPurchasable.reforge]
	col3Item.description = "Upgrade the stats of your currently equipped Weapon to be as if dropped by your strongest defeated enemy! Price increases per-item with every use."
	col3Item.purchasablePrice = itemPrices["weapon"][weaponPurchasable.reforge]
	column3.purchasables.append(col3Item)
	
	var column4 : ShopColumn = ShopColumn.new()
	column4.columnName = "Stat Upgrades"
	column4.purchasables = []
	var col4Phys : Purchasable = Purchasable.new()
	col4Phys.equipment_optional = null
	col4Phys.purchasableName = weaponPurchasableDictionary[weaponPurchasable.statUpgrade_DR]
	col4Phys.description = "Permanently increase your DR Standard Multiplier by +0.05"
	col4Phys.purchasablePrice = itemPrices["weapon"][weaponPurchasable.statUpgrade_DR]
	column4.purchasables.append(col4Phys)
	
	var columnArr : Array[ShopColumn] = [column1, column2, column3, column4]
	retVal.shopContents = columnArr
	return retVal

func createSoulShop() :
	var retVal = ShopDetails.new()
	retVal.shopName = shopNames["soul"]
	retVal.shopCurrency = EquipmentDatabase.getEquipment("soul")
	retVal.shopCurrencyTexture = SceneLoader.createEquipmentScene("soul").getTextureCopy()
	
	var column1 : ShopColumn = ShopColumn.new()
	column1.columnName = "Unlock Your Potential"
	column1.purchasables = []
	for index in range(soulPurchasable.fighterSubclass_1 as int, (soulPurchasable.mageSubclass_2 as int)+1):
		var newItem = Purchasable.new()
		newItem.equipment_optional = null
		newItem.purchasableName = soulPurchasableDictionary[index]
		newItem.description = Definitions.subclassDescriptions[index as Definitions.subclass]
		newItem.purchasablePrice = 1
		column1.purchasables.append(newItem)
	var respecItem = Purchasable.new()
	respecItem.equipment_optional = null
	respecItem.purchasableName = soulPurchasableDictionary[soulPurchasable.respec]
	respecItem.description = "Remove your subclass and choose a new class! [color=red]You will lose half of your [/color]Cumulative Routine Levels[color=red].[/color]"
	respecItem.purchasablePrice = -1
	column1.purchasables.append(respecItem)
	
	var column2 : ShopColumn = ShopColumn.new()
	column2.columnName = "Upgrade Your Soul [font_size=20](or your backpack)[/font_size]"
	column2.purchasables = []
	var spaceItem = Purchasable.new()
	spaceItem.equipment_optional = null
	spaceItem.purchasableName = soulPurchasableDictionary[soulPurchasable.inventorySpace]
	spaceItem.description = "Get +1 inventory slot."
	spaceItem.purchasablePrice = itemPrices["soul"][soulPurchasable.inventorySpace]
	column2.purchasables.append(spaceItem)
	
	var rouletteItem = Purchasable.new()
	rouletteItem.equipment_optional = null
	rouletteItem.purchasableName = soulPurchasableDictionary[soulPurchasable.randomStat]
	rouletteItem.description = "Spend an outrageous sum to permanently increase a random stat! No refunds."
	rouletteItem.purchasablePrice = itemPrices["soul"][soulPurchasable.randomStat]
	column2.purchasables.append(spaceItem)
	
	var columnArr : Array[ShopColumn] = [column1, column2]
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
		value = [0.1, 11]
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
		awaitingConfirmation = true
		emit_signal("addToInventoryRequested", purchase.equipment_optional)
	elif (item == armorPurchasable.newArmor) :
		var newArmor = await createRandomArmor()
		awaitingConfirmation = true
		emit_signal("addToInventoryRequested", newArmor)
	elif (item == armorPurchasable.reforge) :
		##Inventory keeps track of what's dragged off
		awaitingConfirmation = true
		emit_signal("reforgeItemRequested", Definitions.equipmentTypeEnum.armor)
	elif (item == armorPurchasable.statUpgrade_phys || item == armorPurchasable.statUpgrade_mag) :
		var value : Array[float] = [0.05]
		var type = "stat"
		var statEnum : Array[int]
		if (item == armorPurchasable.statUpgrade_phys) :
			statEnum = [Definitions.baseStatEnum.PHYSDEF]
		elif (item == armorPurchasable.statUpgrade_mag) :
			statEnum = [Definitions.baseStatEnum.MAGDEF]
		else :
			return
		var isMultiplicative = false
		var source = "Armory Upgrade"
		var modType = "Postmultiplier"
		awaitingConfirmation = true
		emit_signal("addPermanentModifierRequested", value, type, statEnum, source, modType, isMultiplicative)
	else :
		return

func givePurchaseBenefit_weapon(item : weaponPurchasable, purchase : Purchasable) :
	if (item == weaponPurchasable.premadeWeapon) :
		awaitingConfirmation = true
		emit_signal("addToInventoryRequested", purchase.equipment_optional)
	elif (item == weaponPurchasable.newWeapon) :
		var newWeapon = await createRandomWeapon()
		awaitingConfirmation = true
		emit_signal("addToInventoryRequested", newWeapon)
	elif (item == weaponPurchasable.reforge) :
		##Inventory keeps track of what's dragged off
		awaitingConfirmation = true
		emit_signal("reforgeItemRequested", Definitions.equipmentTypeEnum.weapon)
	elif (item == weaponPurchasable.statUpgrade_DR) :
		var value : Array[float] = [0.05]
		var type = "stat"
		var statEnum : Array[int] = [Definitions.baseStatEnum.DR]
		var isMultiplicative = false
		var source = "Weaponsmith Upgrade"
		var modType = "Postmultiplier"
		awaitingConfirmation = true
		emit_signal("addPermanentModifierRequested", value, type, statEnum, source, modType, isMultiplicative)
	else :
		return

signal setSubclassRequested
signal respecRequested
func givePurchaseBenefitSoul(item : soulPurchasable, purchase : Purchasable) :
	if ((soulPurchasable.fighterSubclass_1 as int) <= (item as int) && (item as int) <= (soulPurchasable.mageSubclass_2 as int)) :
		awaitingConfirmation = true
		emit_signal("setSubclassRequested", item as Definitions.subclass)
	elif (item == soulPurchasable.respec) :
		awaitingConfirmation = true
		emit_signal("respecRequested")
	elif (item == soulPurchasable.randomStat) :
		var value : Array[float] = []
		var type
		var statEnum : Array[int] = []
		var source = soulPurchasableDictionary[item]
		var modType = "Postmultiplier"
		var isMultiplicative = false
		
		var attrCount = Definitions.attributeDictionary.keys().size()
		var statCount = Definitions.attributeDictionary.keys().size()
		var otherCount = Definitions.attributeDictionary.keys().size()
		var totalCount = attrCount + statCount + otherCount
		
		var allUpgradedRoll = randi_range(0,99)
		if (allUpgradedRoll == 0): 
			upgradeAllStats()
			return
		var typeRoll = randi_range(0,totalCount-1)
		if (typeRoll < attrCount-1) :
			type = "attribute"
			var roll = randi_range(0,attrCount-1)
			value.append(0.01)
			statEnum.append(roll)
		elif (typeRoll < attrCount + statCount-1) :
			type = "stat"
			var roll = randi_range(0,statCount-1)
			value.append(0.02)
			statEnum.append(roll)
		else :
			type = "otherStat"
			var roll = randi_range(0,otherCount-1)
			value.append(getOtherStatUpgrade(roll as Definitions.otherStatEnum, false))
			statEnum.append(roll)
		awaitingConfirmation = true
		emit_signal("addPermanentModifierRequested", value, type, statEnum, source, modType, isMultiplicative)
	else :
		return

func upgradeAllStats() :
	var value : Array[float] = []
	var type
	var statEnum : Array[int] = []
	var source = soulPurchasableDictionary[soulPurchasable.randomStat]
	var modType = "Postmultiplier"
	var isMultiplicative = false
	type = "attribute"
	for key in Definitions.attributeDictionary.keys() :
		value.append(0.005)
		statEnum.append(key)
	awaitingConfirmation = true
	emit_signal("addPermanentModifierRequested", value, type, statEnum, source, modType, isMultiplicative)
	if (awaitingConfirmation) :
		await confirmationReceived
	if (!confirmed) :
		return
	value = []
	statEnum = []
	type = "stat"
	for key in Definitions.baseStatDictionary.keys() :
		value.append(0.01)
		statEnum.append(key)
	awaitingConfirmation = true
	emit_signal("addPermanentModifierRequested", value, type, statEnum, source, modType, isMultiplicative)
	if (awaitingConfirmation) :
		await confirmationReceived
	if (!confirmed) :
		return
	value = []
	statEnum = []
	type = "otherStat"
	for key in Definitions.otherStatDictionary.keys() :
		value.append(getOtherStatUpgrade(key, true))
		statEnum.append(key)
	awaitingConfirmation = true
	emit_signal("addPermanentModifierRequested", value, type, statEnum, source, modType, isMultiplicative)
	
func getOtherStatUpgrade(key : Definitions.otherStatEnum, isAllStat : bool) :
	if (key == Definitions.otherStatEnum.magicConversion || key == Definitions.otherStatEnum.physicalConversion) :
		return 0
	elif (key == Definitions.otherStatEnum.routineSpeed || key == Definitions.otherStatEnum.routineEffect) :
		if (isAllStat) :
			return 0.01
		else :
			return 0.025
	elif (key == Definitions.otherStatEnum.magicDamageDealt || key == Definitions.otherStatEnum.physicalDamageDealt) :
		if (isAllStat) :
			return 0.005
		else :
			return 0.01
	elif (key == Definitions.otherStatEnum.physicalDamageTaken || key == Definitions.otherStatEnum.magicDamageTaken) :
		if (isAllStat) :
			return -0.005
		else :
			return -0.01
	else :
		return 0.01

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
	
var myArmor : Array[Armor] = []
var armorScaling : float = 0
func _on_armor_timeout() :
	armorScaling = await getEquipmentScaling()
	var currencyScaling = await getCurrencyScaling("armor")
	currencyScaling /= pow(2,5.0/4.0)
	var var1 =  itemPriceBase["armor"][armorPurchasable.premadeArmor]
	var var2 =  itemPriceBase["armor"][armorPurchasable.newArmor]
	var var3 = itemPriceBase["armor"][armorPurchasable.reforge]
	itemPrices["armor"][armorPurchasable.premadeArmor] = var1 * currencyScaling
	itemPrices["armor"][armorPurchasable.newArmor] = var2 * currencyScaling
	itemPrices["armor"][armorPurchasable.reforge] = var3 * currencyScaling
	myArmor = []
	for index in range(0, 3) :
		myArmor.append(await createRandomArmor())

var myWeapons : Array[Weapon] = []
var weaponScaling : float = 0
func _on_weapon_timeout() :
	weaponScaling = await getEquipmentScaling()
	var currencyScaling = await getCurrencyScaling("weapon")
	currencyScaling /= pow(2,5.0/4.0)
	var var1 =  itemPriceBase["weapon"][weaponPurchasable.premadeWeapon]
	var var2 =  itemPriceBase["weapon"][weaponPurchasable.newWeapon]
	var var3 = itemPriceBase["weapon"][weaponPurchasable.reforge]
	itemPrices["weapon"][weaponPurchasable.premadeWeapon] = var1 * currencyScaling
	itemPrices["weapon"][weaponPurchasable.newWeapon] = var2 * currencyScaling
	itemPrices["weapon"][weaponPurchasable.reforge] = var3 * currencyScaling
	myWeapons = []
	for index in range(0, 3) :
		myWeapons.append(await createRandomWeapon())
	
