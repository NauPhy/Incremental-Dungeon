extends Node

var environment : MyEnvironment = null
var enemyPool : Array = []
var enemyCounts : Array[int] = [0,0,0]

func reset(env : MyEnvironment, enemies : Array) :
	environment = env
	enemyPool = enemies
	filterEnemyPool_env()
	updateEnemyCounts()

func updateEnemyCounts() :
	enemyCounts = [0,0,0]
	for enemy in enemyPool :
		enemyCounts[enemy.enemyGroups.enemyQuality] += 1
	
func getEnemyPool() :
	return enemyPool.duplicate()
	
func filterEnemyPool_env() :
	var index = 0
	while (index < enemyPool.size()) :
		var preEnemy = enemyPool[index]
		var enemy = preEnemy.enemyGroups
		var remove = (environment.permittedFactions.find(enemy.faction) == -1)
		if (remove && (enemy.faction != EnemyGroups.factionEnum.misc)) :
			var pos = enemyPool.find(preEnemy)
			enemyPool.remove_at(pos)
		else :
			index += 1

#func filterEnemyPool_env() :
	#filterEnemyPool_env_envWhitelist() 
	#filterEnemyPool_env_envBlacklist()
	#filterEnemyPool_env_enemyWhitelist()
#
#func filterEnemyPool_env_envWhitelist() :
	#for preEnemy in enemyPool :
		#var enemy = preEnemy.enemyGroups
		#var remove : bool = false
		#if (environment.isHot && !enemy.isHot) :
			#remove = true
		#elif (environment.isCold && !enemy.isCold) :
			#remove = true
		#if (remove) :
			#enemyPool.remove_at(enemyPool.find(preEnemy))
#func filterEnemyPool_env_envBlacklist() :
	#for preEnemy in enemyPool :
		#var enemy = preEnemy.enemyGroups
		#var remove : bool = false
		#if (environment.isWet && enemy.isGreenskin) :
			#remove = true
		#elif (environment.isDesert && enemy.isMerfolk) :
			#remove = true
		#elif (environment.isRainforest && enemy.isUndead) :
			#remove = true
		#elif (environment.isMartial && enemy.isMindless) :
			#remove = true
		#elif (environment.isHighTech && enemy.isMindless) :
			#remove = true
		#if (remove) :
			#enemyPool.remove_at(enemyPool.find(preEnemy))
#func filterEnemyPool_env_enemyWhitelist() :
	#for preEnemy in enemyPool :
		#var enemy = preEnemy.enemyGroups
		#var remove : bool = false
		#if (enemy.isElemental && !environment.isMagical) :
			#remove = true
		#if (enemy.isFae && !environment.isMagical) :
			#remove = true
		#if (remove) :
			#enemyPool.remove_at(enemyPool.find(preEnemy))
func getEnemyOfType(type : EnemyGroups.enemyQualityEnum) :
	var roll = randi_range(0, enemyCounts[type]-1)
	var currentCount = 0
	for enemy in enemyPool :
		if (enemy.enemyGroups.enemyQuality == type) :
			if (currentCount == roll) :
				return enemy
			else :
				currentCount += 1
