extends Panel

signal actionTaken
var core : ActorPreset
var HP : float = 1
var dead : bool = false
var combatPosition : int = -1
var isEnemy : bool = false

func HPBar() :
	return $ResourceCard/VBoxContainer/HPBar
	
const damageNumberLoader = preload("res://Graphic Elements/damage_number.tscn")
const estimatedSize : Vector2 = Vector2(92,40)
func setHP(val) :
	if (!$ResourceCard/VBoxContainer/ActionProgressBar.paused && val < HP) :
		var damage = HP - val
		var screenSize : Vector2i = Engine.get_singleton("DisplayServer").screen_get_size()
		var X0 = clamp(global_position.x-estimatedSize.x-50, 0, screenSize.x-estimatedSize.x)
		var X1 = clamp(global_position.x+size.x+50,0,screenSize.x-estimatedSize.x)
		var Y0
		var Y1
		if (isEnemy) :
			Y0 = clamp(global_position.y-50,100,screenSize.y-estimatedSize.y)
			Y1 = global_position.y+size.y-estimatedSize.y
		else :
			Y0 = global_position.y+100
			Y1 = screenSize.y-estimatedSize.y
		var damageNumber = damageNumberLoader.instantiate()
		add_child(damageNumber)
		damageNumber.initialiseAndRun(damage, X0,X1,Y0,Y1)
	HP = val

#Add more sophisticated AI later
func _ready() :
	$TitleCard/Title.text = core.text
	$Graphic.texture = core.portrait
	setHP(core.MAXHP)
	var chosenAction = randi_range(0,core.actions.size()-1)
	takeAction(core.actions[chosenAction])
	var screenSize : Vector2i = Engine.get_singleton("DisplayServer").screen_get_size()
	isEnemy = global_position.y < screenSize.y/2
	if (!isEnemy) :
		if (await getPlayerSubclass() == Definitions.subclass.knight) :
			$ResourceCard/VBoxContainer/ActionProgressBar.modifyActionWarmup(0.75)
		elif (await getPlayerSubclass() == Definitions.subclass.whirl) :
			var weapon = await getweaponResource()
			if (weapon != null && weapon.equipmentGroups.weaponClass != EquipmentGroups.weaponClassEnum.ranged) :
				$ResourceCard/VBoxContainer/ActionProgressBar.modifyActionWarmup(0.84)
	
signal playerSubclassRequested
signal playerSubclassReceived
var waitingForPlayerSubclass : bool = false
var playerSubclass_comm = -1
func getPlayerSubclass() -> Definitions.subclass :
	if (playerSubclass_comm != -1) :
		return playerSubclass_comm as Definitions.subclass
	waitingForPlayerSubclass = true
	emit_signal("playerSubclassRequested", self)
	if (waitingForPlayerSubclass) :
		await playerSubclassReceived
	return playerSubclass_comm
func providePlayerSubclass(val) :
	playerSubclass_comm = val
	waitingForPlayerSubclass = false
	emit_signal("playerSubclassReceived")
	
signal weaponResourceRequested
signal weaponResourceReceived
var waitingForweaponResource : bool = false
var weaponResource_comm
func getweaponResource() -> Definitions.subclass :
	waitingForweaponResource = true
	emit_signal("weaponResourceRequested", self)
	if (waitingForweaponResource) :
		await weaponResourceReceived
	return weaponResource_comm
func provideweaponResource(val) :
	weaponResource_comm = val
	waitingForweaponResource = false
	emit_signal("weaponResourceReceived")
	
func _process(_delta) :
	if (checkDeath()) :
		return
	HPBar().setMaxHP(core.MAXHP)
	HPBar().setCurrentHP(HP)

func pause() :
	$ResourceCard/VBoxContainer/ActionProgressBar.paused = true
	
func resume() :
	$ResourceCard/VBoxContainer/ActionProgressBar.paused = false

func takeAction(action) :
	$ResourceCard/ActionLabel.text = action.text
	$ResourceCard/VBoxContainer/ActionProgressBar.setAction(action)
	$ResourceCard/VBoxContainer/ActionProgressBar.value = 0
	
func checkDeath() :
	if (dead || HP <= 0) :
		dead = true
		$ResourceCard/ActionLabel.text = "Dead"
		HPBar().setCurrentHP(0)
		$ResourceCard/VBoxContainer/ActionProgressBar.value = 0
		$ResourceCard/VBoxContainer/ActionProgressBar.paused = true
		$ResourceCard/VBoxContainer/ActionProgressBar.show_percentage = false
		return true
	return false

func _on_action_progress_bar_action_ready(action) -> void:
	if (checkDeath()) :
		return
	emit_signal("actionTaken", self, action)
	#add more sophisticated AI later
	takeAction(core.actions[0])
