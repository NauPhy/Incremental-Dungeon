extends Node

var environment : MyEnvironment = null
var itemPool : Array = []

var workingPool : Array = []

func reset(env : MyEnvironment, items : Array) :
	environment = env
	itemPool = items
	filterItemPool_env()
	
func getItemPoolForEnemy(newEnemy : ActorPreset) :
	workingPool = itemPool
	filterWorkingPool_enemy(newEnemy)
	return workingPool.duplicate()

func filterItemPool_env() :
	for preItem in itemPool :
		var remove : bool = false
		var item = preItem.equipmentGroups
		remove = remove || (!item.isEligible)
		remove = remove || (item.isFire && !environment.firePermitted)
		remove = remove || (item.isIce && !environment.icePermitted)
		remove = remove || (item.isEarth && !environment.earthPermitted)
		remove = remove || (item.isWater && !environment.waterPermitted)
		if (remove) :
			itemPool.remove_at(itemPool.find(preItem))
			
func filterWorkingPool_enemy(preEnemy : ActorPreset) :
	workingPool = itemPool
	var enemy = preEnemy.enemyGroups
	for preItem in workingPool :
		var remove : bool = false
		var item = preItem.equipmentGroups
		if (preItem is Armor) :
			remove = remove || (enemy.droppedArmorClasses.find(item.armorClass) == -1)
		if (preItem is Weapon) :
			remove = remove || (enemy.droppedWeaponClasses.find(item.weaponClass) == -1)
		remove = remove || (enemy.droppedTechnologyClasses.find(item.technology) == -1)
		if (remove) :
			workingPool.remove_at(itemPool.find(preItem))
			
#func filterItemPool_env_itemWhitelists() :
	#for preItem in itemPool :
		#var item = preItem.equipmentGroups
		#var remove : bool = false
		#if (item.isFire && !environment.isHot) :
			#remove = true
		#elif (item.isWater && !environment.isWet) :
			#remove = true
		#elif (item.isIce && !environment.isCold) :
			#remove = true
		#elif (item.isEarth && !environment.isDesert && !environment.isRainforest) :
			#remove = true
		#elif (item.isMagical && !environment.isMagical) :
			#remove = true
		#if (remove) :
			#itemPool.remove_at(itemPool.find(preItem))
	
#func filterItemPool_enemy() :
	#filterItemPool_enemy_enemyWhitelists()
#
#func filterItemPool_enemy_enemyWhitelists() :
	#for preItem in workingPool :
		#var item = preItem.equipmentGroups
		#var remove : bool = false
		#if (preItem is Armor && enemy.droppedArmorClasses.find(item.armorClass) == -1) :
			#remove = true
		#elif (preItem is Weapon && enemy.droppedWeaponClasses.find(item.weaponClass) == -1) :
			#remove = true
		#elif (enemy.droppedTechnologyClasses.find(item.technology) == -1) :
			#remove = true
		#if (remove) :
			#workingPool.remove_at(workingPool.find(preItem))
