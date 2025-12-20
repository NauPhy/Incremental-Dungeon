extends Node

const demonicDictionary = {
	"abomination" : preload("res://Resources/NewActor/demonic/abomination.tres"),
	"demon_elephant" : preload("res://Resources/NewActor/demonic/demon_elephant.tres"),
	"hairy_devil" : preload("res://Resources/NewActor/demonic/hairy_devil.tres"),
	"hell_beast" : preload("res://Resources/NewActor/demonic/hell_beast.tres"),
	"hell_hog" : preload("res://Resources/NewActor/demonic/hell_hog.tres"),
	"hell_hound" : preload("res://Resources/NewActor/demonic/hell_hound.tres"),
	"hellion" : preload("res://Resources/NewActor/demonic/hellion.tres"),
	"succubus" : preload("res://Resources/NewActor/demonic/succubus.tres"),
	"tormentor" : preload("res://Resources/NewActor/demonic/tormentor.tres")}


static func getdemonic(resourceName : String) :
	return demonicDictionary.get(resourceName)

const demonic_militaryDictionary = {
	"arch_fiend" : preload("res://Resources/NewActor/demonic_military/arch_fiend.tres"),
	"balrog" : preload("res://Resources/NewActor/demonic_military/balrog.tres"),
	"death_knight" : preload("res://Resources/NewActor/demonic_military/death_knight.tres"),
	"hell_knight" : preload("res://Resources/NewActor/demonic_military/hell_knight.tres"),
	"hell_sentinel" : preload("res://Resources/NewActor/demonic_military/hell_sentinel.tres"),
	"hell_wizard" : preload("res://Resources/NewActor/demonic_military/hell_wizard.tres"),
	"imp" : preload("res://Resources/NewActor/demonic_military/imp.tres"),
	"salamander_melee" : preload("res://Resources/NewActor/demonic_military/salamander_melee.tres"),
	"salamander_ranged" : preload("res://Resources/NewActor/demonic_military/salamander_ranged.tres"),
	"shadow_imp" : preload("res://Resources/NewActor/demonic_military/shadow_imp.tres")}


static func getdemonic_military(resourceName : String) :
	return demonic_militaryDictionary.get(resourceName)

const earthDictionary = {
	"Lindwurm" : preload("res://Resources/NewActor/earth/Lindwurm.tres"),
	"deathcap" : preload("res://Resources/NewActor/earth/deathcap.tres"),
	"dryad" : preload("res://Resources/NewActor/earth/dryad.tres"),
	"faun" : preload("res://Resources/NewActor/earth/faun.tres"),
	"forest_drake" : preload("res://Resources/NewActor/earth/forest_drake.tres"),
	"hill_giant" : preload("res://Resources/NewActor/earth/hill_giant.tres"),
	"satyr" : preload("res://Resources/NewActor/earth/satyr.tres"),
	"swamp_dragon" : preload("res://Resources/NewActor/earth/swamp_dragon.tres"),
	"swamp_worm" : preload("res://Resources/NewActor/earth/swamp_worm.tres"),
	"thorned_ambusher" : preload("res://Resources/NewActor/earth/thorned_ambusher.tres"),
	"treant" : preload("res://Resources/NewActor/earth/treant.tres")}


static func getearth(resourceName : String) :
	return earthDictionary.get(resourceName)

const fireDictionary = {
	"fire_bat" : preload("res://Resources/NewActor/fire/fire_bat.tres"),
	"fire_crab" : preload("res://Resources/NewActor/fire/fire_crab.tres"),
	"fire_dragon" : preload("res://Resources/NewActor/fire/fire_dragon.tres"),
	"fire_elemental" : preload("res://Resources/NewActor/fire/fire_elemental.tres"),
	"fire_giant" : preload("res://Resources/NewActor/fire/fire_giant.tres"),
	"lava_fish" : preload("res://Resources/NewActor/fire/lava_fish.tres"),
	"lava_snake" : preload("res://Resources/NewActor/fire/lava_snake.tres"),
	"lava_worm" : preload("res://Resources/NewActor/fire/lava_worm.tres"),
	"lesser_fire_elemental" : preload("res://Resources/NewActor/fire/lesser_fire_elemental.tres")}


static func getfire(resourceName : String) :
	return fireDictionary.get(resourceName)

const greenskinDictionary = {
	"gnoll" : preload("res://Resources/NewActor/greenskin/gnoll.tres"),
	"goblin_ranger" : preload("res://Resources/NewActor/greenskin/goblin_ranger.tres"),
	"goblin_skirmisher" : preload("res://Resources/NewActor/greenskin/goblin_skirmisher.tres"),
	"juggernaut" : preload("res://Resources/NewActor/greenskin/juggernaut.tres"),
	"orc_knight" : preload("res://Resources/NewActor/greenskin/orc_knight.tres"),
	"orc_new" : preload("res://Resources/NewActor/greenskin/orc_new.tres"),
	"orc_sorcerer" : preload("res://Resources/NewActor/greenskin/orc_sorcerer.tres"),
	"orc_warlord" : preload("res://Resources/NewActor/greenskin/orc_warlord.tres"),
	"polyphemus" : preload("res://Resources/NewActor/greenskin/polyphemus.tres")}


static func getgreenskin(resourceName : String) :
	return greenskinDictionary.get(resourceName)

const iceDictionary = {
	"frost wraith" : preload("res://Resources/NewActor/ice/frost wraith.tres"),
	"ice_beast" : preload("res://Resources/NewActor/ice/ice_beast.tres"),
	"ice_devil" : preload("res://Resources/NewActor/ice/ice_devil.tres"),
	"ice_dragon" : preload("res://Resources/NewActor/ice/ice_dragon.tres"),
	"ice_elemental" : preload("res://Resources/NewActor/ice/ice_elemental.tres"),
	"ice_giant" : preload("res://Resources/NewActor/ice/ice_giant.tres"),
	"ice_hydra" : preload("res://Resources/NewActor/ice/ice_hydra.tres"),
	"ice_slime" : preload("res://Resources/NewActor/ice/ice_slime.tres"),
	"ice_troll" : preload("res://Resources/NewActor/ice/ice_troll.tres"),
	"polar_bear" : preload("res://Resources/NewActor/ice/polar_bear.tres")}


static func getice(resourceName : String) :
	return iceDictionary.get(resourceName)

const merfolkDictionary = {
	"champion_of_poesideon" : preload("res://Resources/NewActor/merfolk/champion_of_poesideon.tres"),
	"ilsuiw" : preload("res://Resources/NewActor/merfolk/ilsuiw.tres"),
	"merfolk_fighter" : preload("res://Resources/NewActor/merfolk/merfolk_fighter.tres"),
	"merfolk_grunt" : preload("res://Resources/NewActor/merfolk/merfolk_grunt.tres"),
	"merfolk_impaler" : preload("res://Resources/NewActor/merfolk/merfolk_impaler.tres"),
	"merfolk_javalineer" : preload("res://Resources/NewActor/merfolk/merfolk_javalineer.tres"),
	"merfolk_mage" : preload("res://Resources/NewActor/merfolk/merfolk_mage.tres"),
	"siren" : preload("res://Resources/NewActor/merfolk/siren.tres")}


static func getmerfolk(resourceName : String) :
	return merfolkDictionary.get(resourceName)

const miscDictionary = {
	"caustic_shrike" : preload("res://Resources/NewActor/misc/caustic_shrike.tres"),
	"gold_dragon" : preload("res://Resources/NewActor/misc/gold_dragon.tres"),
	"iron_dragon" : preload("res://Resources/NewActor/misc/iron_dragon.tres"),
	"iron_golem" : preload("res://Resources/NewActor/misc/iron_golem.tres"),
	"iron_troll" : preload("res://Resources/NewActor/misc/iron_troll.tres"),
	"ironbrand" : preload("res://Resources/NewActor/misc/ironbrand.tres"),
	"shadow_dragon" : preload("res://Resources/NewActor/misc/shadow_dragon.tres"),
	"titan" : preload("res://Resources/NewActor/misc/titan.tres"),
	"troll" : preload("res://Resources/NewActor/misc/troll.tres")}


static func getmisc(resourceName : String) :
	return miscDictionary.get(resourceName)

const undeadDictionary = {
	"bone_dragon" : preload("res://Resources/NewActor/undead/bone_dragon.tres"),
	"death" : preload("res://Resources/NewActor/undead/death.tres"),
	"jiangshi_assassin" : preload("res://Resources/NewActor/undead/jiangshi_assassin.tres"),
	"lich" : preload("res://Resources/NewActor/undead/lich.tres"),
	"mummy_fighter" : preload("res://Resources/NewActor/undead/mummy_fighter.tres"),
	"mummy_ranger" : preload("res://Resources/NewActor/undead/mummy_ranger.tres"),
	"necromancer" : preload("res://Resources/NewActor/undead/necromancer.tres"),
	"rotten_amaglamation" : preload("res://Resources/NewActor/undead/rotten_amaglamation.tres"),
	"skeleton" : preload("res://Resources/NewActor/undead/skeleton.tres"),
	"vampire" : preload("res://Resources/NewActor/undead/vampire.tres")}


static func getundead(resourceName : String) :
	return undeadDictionary.get(resourceName)

const waterDictionary = {
	"black_mamba" : preload("res://Resources/NewActor/water/black_mamba.tres"),
	"electric_eel" : preload("res://Resources/NewActor/water/electric_eel.tres"),
	"jellyfish" : preload("res://Resources/NewActor/water/jellyfish.tres"),
	"kraken" : preload("res://Resources/NewActor/water/kraken.tres"),
	"nymph" : preload("res://Resources/NewActor/water/nymph.tres"),
	"shark" : preload("res://Resources/NewActor/water/shark.tres"),
	"water_dragon" : preload("res://Resources/NewActor/water/water_dragon.tres"),
	"water_elemental" : preload("res://Resources/NewActor/water/water_elemental.tres"),
	"water_troll" : preload("res://Resources/NewActor/water/water_troll.tres")}


static func getwater(resourceName : String) :
	return waterDictionary.get(resourceName)

static func getNewActor(resourceName : String) :
	if (demonicDictionary.has(resourceName)) :
		return demonicDictionary[resourceName]
	if (demonic_militaryDictionary.has(resourceName)) :
		return demonic_militaryDictionary[resourceName]
	if (earthDictionary.has(resourceName)) :
		return earthDictionary[resourceName]
	if (fireDictionary.has(resourceName)) :
		return fireDictionary[resourceName]
	if (greenskinDictionary.has(resourceName)) :
		return greenskinDictionary[resourceName]
	if (iceDictionary.has(resourceName)) :
		return iceDictionary[resourceName]
	if (merfolkDictionary.has(resourceName)) :
		return merfolkDictionary[resourceName]
	if (miscDictionary.has(resourceName)) :
		return miscDictionary[resourceName]
	if (undeadDictionary.has(resourceName)) :
		return undeadDictionary[resourceName]
	if (waterDictionary.has(resourceName)) :
		return waterDictionary[resourceName]
	return null

static func getDictionary(type : String) :
	if type == "demonic" : 
		return demonicDictionary
	if type == "demonic_military" : 
		return demonic_militaryDictionary
	if type == "earth" : 
		return earthDictionary
	if type == "fire" : 
		return fireDictionary
	if type == "greenskin" : 
		return greenskinDictionary
	if type == "ice" : 
		return iceDictionary
	if type == "merfolk" : 
		return merfolkDictionary
	if type == "misc" : 
		return miscDictionary
	if type == "undead" : 
		return undeadDictionary
	if type == "water" : 
		return waterDictionary
static func getAllNewActor() -> Array :
	var retVal : Array = []
	retVal.append_array(demonicDictionary.values())
	retVal.append_array(demonic_militaryDictionary.values())
	retVal.append_array(earthDictionary.values())
	retVal.append_array(fireDictionary.values())
	retVal.append_array(greenskinDictionary.values())
	retVal.append_array(iceDictionary.values())
	retVal.append_array(merfolkDictionary.values())
	retVal.append_array(miscDictionary.values())
	retVal.append_array(undeadDictionary.values())
	retVal.append_array(waterDictionary.values())
	return retVal
