extends "res://Graphic Elements/Buttons/super_button.gd"
var core : Purchasable = null

var myReady : bool = false
signal myReadySignal
func _ready() :
	super()
	myReady = true
	emit_signal("myReadySignal")

func setCurrency(val : Texture2D) :
	$HBoxContainer/HBoxContainer2/CurrencySprite.setTexture(val)
func setPrice(val) :
	core.purchasablePrice = val
	$HBoxContainer/HBoxContainer2/Price.text = " " + str(Helpers.engineeringRound(val, 3)) + " "

	
func setFromDetails(val : Purchasable) :
	core = val
	if ((val.equipment_optional) != null) :
		$HBoxContainer/HBoxContainer/PurchaseableName.text = " " + val.equipment_optional.getName() + " "
	else :
		$HBoxContainer/HBoxContainer/PurchaseableName.text = " " + val.purchasableName + " "
	$HBoxContainer/HBoxContainer2/Price.text = " " + Helpers.engineeringRound(val.purchasablePrice, 3) + " "
	if (val.equipment_optional != null) :
		self.toggle = true

func getName() :
	return core.purchasableName
func getPrice() :
	return core.purchasablePrice
func getEquipment() :
	return core.equipment_optional
func getPurchasable() :
	return core
