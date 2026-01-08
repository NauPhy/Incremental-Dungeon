extends VBoxContainer

func _ready() :
	for key in Definitions.otherStatDictionary.keys() :
		var newText = $SampleEntry.duplicate()
		if (Definitions.otherStatEnum.routineSpeed_0 <= key && key <= Definitions.otherStatEnum.routineSpeed_4) :
			$PanelContainer/OtherStatDisplay/VBoxContainer/VBoxContainer.add_child(newText)
		else :
			$PanelContainer/OtherStatDisplay.add_child(newText)
			newText.visible = true
		newText.get_node("Name").text = " " + Definitions.otherStatDictionary[key] + ": "

func initialise(OtherStatRefs : Array[NumberClass]) :
	for key in Definitions.otherStatDictionary.keys() :
		if (Definitions.otherStatEnum.routineSpeed_0 <= key && key <= Definitions.otherStatEnum.routineSpeed_4) :
			continue
		#var otherStat = $PanelContainer/OtherStatDisplay.get_child(key).get_node("Number")
		$PanelContainer/OtherStatDisplay.get_child(key).get_node("Number").setNumberReference(OtherStatRefs[key])

func _on_texture_button_pressed() -> void:
	$PanelContainer/OtherStatDisplay/VBoxContainer/VBoxContainer.visible = !$PanelContainer/OtherStatDisplay/VBoxContainer/VBoxContainer.visible
