extends VBoxContainer

func setDesc(val) :
	$PanelContainer/EncyclopediaTextLabel.setText(val)

var myReady : bool = false
signal myReadySignal
func _ready() :
	if (!$PurchasableScene.myReady) :
		await $PurchasableScene.myReadySignal
	myReady = true
	emit_signal("myReadySignal")

signal wasSelected
signal wasDeselected
func _on_purchasable_scene_was_deselected() -> void:
	emit_signal("wasDeselected")
func _on_purchasable_scene_was_selected() -> void:
	emit_signal("wasSelected")
	
func setCurrency(val : Texture2D) :
	$PurchasableScene.setCurrency(val)
func setPrice(val : int) :
	$PurchasableScene.setPrice(val)
#func setName(val : String) :
	#$PurchasableScene.setName(val)
func setFromDetails(val : Purchasable) :
	setDesc(val.description)
	$PurchasableScene.setFromDetails(val)
func getName() :
	return $PurchasableScene.getName()
func getPrice() :
	return $PurchasableScene.getPrice()
func getEquipment() :
	return $PurchasableScene.getEquipment()
func deselect() :
	$PurchasableScene.deselect()
func select() :
	$PurchasableScene.select()
func getCore() :
	return $PurchasableScene.core
