extends Button

enum myVisibilityEnum {invisible, halfVisible, fullVisible}
var currentVisibility : myVisibilityEnum = myVisibilityEnum.invisible

var myName : String = ""
func setName(val) :
	myName = val
	text = " " + val + " "
func getName() :
	return myName
	
func setVisibility(val : myVisibilityEnum) :
	currentVisibility = val
	if (val == myVisibilityEnum.invisible) :
		visible = false
	elif (val == myVisibilityEnum.halfVisible) :
		set_disabled(true)
		visible = true
		text = ""
	elif (val == myVisibilityEnum.fullVisible) :
		set_disabled(false)
		visible = true
		text = " " + myName + " "
func getVisibility() :
	return currentVisibility
	
signal shopRequested
var shopType : String = ""
func setShopType(val) :
	shopType = val
func getShopType() :
	return shopType
func _on_pressed() -> void:
	emit_signal("shopRequested", Shopping.createShop(shopType))
