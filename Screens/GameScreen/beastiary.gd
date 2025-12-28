extends "res://Graphic Elements/popups/my_popup_button.gd"

const bigEntryLoader = preload("res://Screens/GameScreen/Tabs/Combat/Map/enemy_entry_big.tscn")
const bigEntryLoaderNew = preload("res://Screens/GameScreen/Tabs/Combat/Map/Map_Runtime/enemy_entry_big_runtime.tscn")

var enemyDict : Dictionary = {}

func _ready() :
	var enemyList : Array = EnemyDatabase.getEnemyList()
	for enemy in enemyList :
		var newEntry = getContainer().get_node("Sample").duplicate()
		getContainer().add_child(newEntry)
		newEntry.visible = true
		if (EnemyDatabase.getKillCount(enemy) == 0) :
			newEntry.setText("Undiscovered")
			newEntry.set_disabled(true)
		else :
			newEntry.setText(EnemyDatabase.getEnemy(enemy).getName())
			enemyDict[newEntry.getText()] = enemy
		newEntry.connect("myPressed", _on_my_pressed)
		
func getContainer() :
	return  $Panel/CenterContainer/Window/VBoxContainer/ScrollContainer/VBoxContainer
	
func _on_my_pressed(emitter) :
	var enemy : ActorPreset = EnemyDatabase.getEnemy(enemyDict[emitter.getText()])
	var bigEntry
	if (enemy.enemyGroups != null && enemy.enemyGroups.isEligible) :
		bigEntry = bigEntryLoaderNew.instantiate()
	else :
		bigEntry = bigEntryLoader.instantiate()
	add_child(bigEntry)
	bigEntry.nestedPopupInit(self)
	bigEntry.setEnemy(enemy)
