extends HBoxContainer

var myEnemy : ActorPreset = null
func setEnemy(enemy : ActorPreset) :
	myEnemy = enemy
	$Name.text = " " + myEnemy.getName() + " "

var killCount = 0
func incrementKilled() :
	EnemyDatabase.incrementKills(myEnemy.getResourceName())
	
func getEnemy() :
	return myEnemy

const bigLoader = preload("res://Screens/GameScreen/Tabs/Combat/Map/Map_Runtime/enemy_entry_big_runtime.tscn")
func createBigEntry() :
	var bigEntry = bigLoader.instantiate()
	add_child(bigEntry)
	if (!bigEntry.myReady) :
		await bigEntry.myReadySignal
	bigEntry.initialise(self)
