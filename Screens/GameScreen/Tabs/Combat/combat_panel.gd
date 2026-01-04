extends Panel

signal victory
signal defeat
signal retreat

const GODPUNCHloader = preload("res://Resources/OldAction/Attacks/godpunch.tres")
var autoMode : bool = false

signal playerModifierDictionaryRequested
signal playerModifierDictionaryReceived
var waitingForPlayerModifierDictionary : bool = false
var playerModPacket_comm : Dictionary = {}
func getPlayerModifierDictionary() -> Dictionary :
	waitingForPlayerModifierDictionary = true
	emit_signal("playerModifierDictionaryRequested", self)
	if (waitingForPlayerModifierDictionary) :
		await playerModifierDictionaryReceived
	return playerModPacket_comm
func providePlayerModifierDictionary(val : Dictionary, demonRing) :
	playerModPacket_comm = val
	hasDemonRingEquipped = demonRing
	waitingForPlayerModifierDictionary = false
	emit_signal("playerModifierDictionaryReceived")

var currentPlayerMods : Dictionary = {}
var hasDemonRingEquipped : bool = false
func resetCombat(friendlyCores : Array[ActorPreset], enemyCores : Array[ActorPreset]) :
	currentPlayerMods = await getPlayerModifierDictionary()
	cleanup()
	var actorLoader = preload("Actors/combat_actor.tscn")
	for friend in friendlyCores :
		if (friend == friendlyCores[0] && Definitions.GODMODE) :
			friend.actions = [GODPUNCHloader]
		var newActor = actorLoader.instantiate()
		newActor.core = friend
		newActor.HP = newActor.core.MAXHP
		$FriendlyParty.add_child(newActor)
		newActor.connect("actionTaken", _on_friend_action_taken)
		newActor.size_flags_horizontal = 0
		newActor.size_flags_vertical = Control.SIZE_SHRINK_END
	for enemy in enemyCores :
		var newActor = actorLoader.instantiate()
		newActor.core = enemy
		newActor.HP = newActor.core.MAXHP
		$EnemyParty.add_child(newActor)
		newActor.connect("actionTaken", _on_enemy_action_taken)
		newActor.size_flags_horizontal = 0
		newActor.size_flags_vertical = 0
	initPartyPositions($FriendlyParty.get_children())
	initPartyPositions($EnemyParty.get_children())
	resumeCombat()
	
func restartCombat() :
	var friendlyCores : Array[ActorPreset] = []
	for child in $FriendlyParty.get_children() :
		friendlyCores.append(child.core)
	var enemyCores : Array[ActorPreset] = []
	for child in $EnemyParty.get_children() :
		enemyCores.append(child.core)
	resetCombat(friendlyCores, enemyCores)
	
func initPartyPositions(party : Array) :
	if (party.size() == 1) :
		party[0].combatPosition = 2
	elif (party.size() == 2 || party.size() == 3) :
		party[0].combatPosition = 1
		party[1].combatPosition = 2
		if (party.size() == 3) :
			party[2].combatPosition = 3
	elif (party.size() == 4 || party.size() == 5) :
		for index in range(4) :
			party[index].combatPosition = 	index
		if (party.size() == 5) :
			party[4].combatPosition = 4 
	
func cleanup() :
	for child in $FriendlyParty.get_children() :
		child.visible = false
		child.free()
	for child in $EnemyParty.get_children() :
		child.visible = false
		child.free()
	
enum combatStatus {running, victory, defeat}		
func _process(_delta: float) -> void:
	if (paused) :
			return
	var status = getStatus()
	if (status == combatStatus.running) :
		doCombatStep()
		return
	elif (status == combatStatus.victory) :
		pauseCombat()
		for enemy in $EnemyParty.get_children() :
			EnemyDatabase.incrementKills(enemy.core.getResourceName())
		emit_signal("victory",autoMode)
	elif (status == combatStatus.defeat) :
		pauseCombat()
		emit_signal("defeat")
		
func _on_my_button_pressed() -> void:
	pauseCombat()
	emit_signal("retreat")

#Damage over time etc.
func doCombatStep() :
	pass
		
func getStatus() :
	var victoryBool : bool = true
	for child in $EnemyParty.get_children() :
		if (!child.dead) :
			victoryBool = false
	if (victoryBool) : return combatStatus.victory
	var defeatBool : bool = true
	for child in $FriendlyParty.get_children() :
		if (!child.dead) :
			defeatBool = false
	if (defeatBool) : return combatStatus.defeat
	return combatStatus.running
#######################
var paused : bool = true
func pauseCombat() :
	paused = true
	for child in $EnemyParty.get_children() :
		child.pause()
	for child in $FriendlyParty.get_children() :
		child.pause()
		
func resumeCombat() :
	paused = false
	for child in $EnemyParty.get_children() :
		child.resume()
	for child in $FriendlyParty.get_children() :
		child.resume()
########################
func _on_friend_action_taken(emitter, action : Action) :
	var target = getTarget(emitter, $EnemyParty.get_children(), action)
	executeAction(emitter, action, target)
	
func _on_enemy_action_taken(emitter, action : Action) :
	var target = getTarget(emitter, $FriendlyParty.get_children(), action)
	executeAction(emitter, action, target)

func getTarget(emitter, otherParty, action) :
	if (action.mode == Action.targetingMode.RAND) :
		return getRandomTarget(otherParty)
	elif (action.mode == Action.targetingMode.LOW) :
		return getLowestTarget(otherParty)
	elif (action.mode == Action.targetingMode.STANDARD && action is AttackAction) :
		return getStandardTarget(emitter, otherParty)
	else :
		return -1
		
func getRandomTarget(otherParty) :
	var validTargets : Array
	for unit in otherParty :
		if (!unit.dead) :
			validTargets.append(unit)
	if (validTargets.size() == 0) :
		return -1
	var randIndex = randi()%validTargets.size()
	return validTargets[randIndex]

func getLowestTarget(otherParty) :
	var lowestHP = otherParty[0].core.MAXHP
	var lowestTarget
	for unit in otherParty :
		if (unit.HP <= lowestHP && unit.HP > 0) :
			lowestHP = unit.HP
			lowestTarget = unit
	return lowestTarget

func getStandardTarget(emitter, otherParty) :
	var myPos = emitter.combatPosition
	var target
	for index in range(5) :
		target = searchPartyAlive(otherParty, myPos+index)
		if (target != null) :
			return target
		target = searchPartyAlive(otherParty, myPos-index)
		if (target != null) :
			return target
	return null

func searchPartyAlive(party, pos:int) :
	for unit in party :
		if (unit.combatPosition == pos && !unit.dead) :
			return unit
	return null

func executeAction(emitter, action, target) :
	## Not that it'll matter in Release, but the third term is to force me to playtest this obscure item effect if I forget.
	if (action is AttackAction && Definitions.GODMODE && !(hasDemonRingEquipped && emitter.core.enemyGroups.faction == EnemyGroups.factionEnum.demonic_military)) :
		if (target == $FriendlyParty.get_child(0)) :
			return
		if (emitter == $FriendlyParty.get_child(0)) :
			target.setHP(0)
			return
			
	var AR = emitter.core.AR
	var DR = emitter.core.DR
	var physicalDefense = target.core.PHYSDEF
	var magicDefense = target.core.MAGDEF
	
	var magicDR : float
	var physicalDR : float
	if (target == $FriendlyParty.get_child(0)) :
		if (action.type == AttackAction.damageType.PHYS) :
			physicalDR = DR
			magicDR = 0
		elif (action.type == AttackAction.damageType.MAG) :
			physicalDR = 0
			magicDR = DR
		else :
			return
	else :
		if (action.type == AttackAction.damageType.MAG) :
			magicDR = DR*(1-currentPlayerMods["otherStat"][Definitions.otherStatEnum.magicConversion])
			physicalDR = DR*(currentPlayerMods["otherStat"][Definitions.otherStatEnum.magicConversion])
		elif (action.type == AttackAction.damageType.PHYS) :
			magicDR = DR*(currentPlayerMods["otherStat"][Definitions.otherStatEnum.physicalConversion])
			physicalDR = DR*(1-currentPlayerMods["otherStat"][Definitions.otherStatEnum.physicalConversion])
		else :
			return

	var physicalArgs : Array = [action.power, physicalDR, AR, physicalDefense]
	var physicalDamage = Encyclopedia.getFormula("Damage Value", Encyclopedia.formulaAction.getCalculation_full, physicalArgs)
	if (target != $FriendlyParty.get_child(0)) :
		physicalDamage *= currentPlayerMods["otherStat"][Definitions.otherStatEnum.physicalDamageDealt]
	else :
		var PDT =  currentPlayerMods["otherStat"][Definitions.otherStatEnum.physicalDamageTaken]
		if (hasDemonRingEquipped && emitter.core.enemyGroups.faction == EnemyGroups.factionEnum.demonic_military) :
			PDT -= 0.25
		physicalDamage *= PDT
		
	var magicArgs : Array = [action.power, magicDR, AR, magicDefense]
	var magicDamage = Encyclopedia.getFormula("Damage Value", Encyclopedia.formulaAction.getCalculation_full, magicArgs)
	if (target != $FriendlyParty.get_child(0)) :
		magicDamage *= currentPlayerMods["otherStat"][Definitions.otherStatEnum.magicDamageDealt]
	else :
		var MDT = currentPlayerMods["otherStat"][Definitions.otherStatEnum.magicDamageTaken]
		if (hasDemonRingEquipped && emitter.core.enemyGroups.faction == EnemyGroups.factionEnum.demonic_military) :
			MDT -= 0.25
		magicDamage *= MDT
		
	var damage = magicDamage + physicalDamage
	if (damage > target.HP) :
		target.setHP(0)
	else :
		target.setHP(target.HP-damage)

func _on_check_box_toggled(toggled_on: bool) -> void:
	autoMode = toggled_on
	
var myReady
func _ready() :
	myReady = true

func getSaveDictionary() -> Dictionary :
	var tempDict : Dictionary = {}
	tempDict["autoMode"] = autoMode
	return tempDict
func beforeLoad(_newGame : bool) :
	pass
func onLoad(loadDict : Dictionary) :
	autoMode = loadDict["autoMode"]
	if (autoMode) :
		$PanelContainer/HBoxContainer/CheckBox.set_pressed_no_signal(true)
