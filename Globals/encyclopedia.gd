extends Node
func _ready() :
	addFormulasToDescriptions()
	addAlternativeKeywordsToDescriptions()
	
enum tutorialName {
	tutorial,
	tutorialFloor1,
	tutorialFloor2,
	tutorialFloor3,
	trainingTab,
	tutorialFloor4,
	equipment,
	tutorialFloorEnd,
	dropIntro,
	manticoreKill
}
const tutorialTitles : Dictionary = {
	tutorialName.tutorial : "A Tutorial About Tutorials",
	tutorialName.tutorialFloor1 : "Combat Map 1",
	tutorialName.tutorialFloor2 : "Combat Map 2",
	tutorialName.tutorialFloor3 : "Combat Map 3",
	tutorialName.trainingTab : "Training Tab",
	tutorialName.tutorialFloor4 : "Forks in the Road",
	tutorialName.equipment : "Equipment",
	tutorialName.tutorialFloorEnd : "Floor Exit",
	tutorialName.dropIntro : "Drops Introduction",
	tutorialName.manticoreKill : "Manticore Defeated"
}
const tutorialDesc : Dictionary = {
	tutorialName.tutorial : "Tutorial popups can be disabled in the in-game options (F1) menu. There you will also find a list of all encountered tutorials, even if they were suppressed. Remember that tutorials may show up even in the late game!",
	tutorialName.tutorialFloor1 : "Welcome to the Combat Map. Here you can click to select a room to enter next. At the start of each map, only the entrance will be available to explore.",
	#fight rats
	tutorialName.tutorialFloor2 : "Nice! Not every room has a combat encounter, but most will. Try entering the newly discovered room next.",
	#die to hobgoblin
	tutorialName.tutorialFloor3 : "That guy is tough! Oh well, you didn't think this would be easy. Click the training tab to begin increasing your strength.\n\n[i]The Training tab has been unlocked[/i]",
	#click on tab
	tutorialName.trainingTab : "Here you can choose a Routine to increase your Attributes over time. Each Routine improves different Attributes at different rates, and the best Routine will depend on your build.\n\nWhile they may seem slow at first, Routines can be sped up later on. Choose a routine and level it up until you can defeat the Hobgoblin! Remember that combat takes a snapshot of your stats when it starts, so increasing your Attributes won't help until the start of the next combat.",
	#kill hobgoblin
	tutorialName.tutorialFloor4 : "The primary goal of this game is to progress deeper into the dungeon. [b]North[/b] always leads deeper, but your adversaries will get very strong, very fast! You will need to explore side passages to stand a chance against them.",
	#First time rewards screen comes up (presumably before goblins)
	tutorialName.equipment : "You just found some equipment! Up until now you've been unarmed and unarmored. You can add the item to your inventory from the loot screen and equip it in the Equipment Tab. Try equipping it and see how it changes your Combat Stats.\n\n[i]The Equipment tab has been unlocked[/i]",
	#End of first floor
	tutorialName.tutorialFloorEnd : "Congratulations, you've beaten the tutorial floor. The dungeon from here on out will be a bit slower and more challenging.\n\nRemember to explore the side paths and farm drops from weaker monsters. If you feel progress is too slow, get a cup of coffee or pull up a YouTube video. This is not meant to be a terribly active game.\n\nAlternatively, you could spend some time scrutinising your build to try and squeeze a bit more performance out of it!",
	tutorialName.dropIntro : "Most enemies have a chance to drop items on death. After completing a room for the first time, enemies and hints about their drops will be added to the beastiary found in the in-game options (F1) menu.\n\nEnemies will also be listed on the room itself. You can access an enemy's beastiary entry by CTRL-clicking its name in the room's enemy list, but only if you've defeated it at least once.",
	tutorialName.manticoreKill : "Congratulations on defeating the Manticore! Unfortunately this is the end of content in the current version. I hope you enjoyed the game, and I'd be happy to hear any feedback you have!"
}
const tutorialPointers : Dictionary = {
}
const tutorialPointerPos : Dictionary = {
}
const oneOffTutorials : Array = [
	tutorialName.tutorial,
	tutorialName.tutorialFloor1,
	tutorialName.tutorialFloor2,
	tutorialName.tutorialFloor3,
	tutorialName.tutorialFloor4,
	tutorialName.equipment,
	tutorialName.tutorialFloorEnd,
	tutorialName.dropIntro,
	tutorialName.manticoreKill
]

## I tried my damndest, but I could not figure out an elegant way to do this. Oh well, it's decent. All formulas in the game that are exposed to the player are in
## this dictionary. Both the strings for the formulas and the calculations are done via getFormula(). It is the responsibility of getFormula()'s caller to know
## what the valid arguments are for the function it's calling, which is the part I hate the most.
## So for example you can call a formula in this dictionary that uses parameters associated with multiple types of enums. No problem, but the caller needs to know
## what order the variables are expected in, and cannot rely on enum order. If it really bothers me I suppose I could use a temporary dictionary as a parameter to
## eliminate all ambiguity.
enum formulaAction {
	getString_full,
	getString_array,
	getString_partial,
	getCalculation_full,
	getCalculation_array,
	getCalculation_partial
}
var formulas : Dictionary = {
	"AR" : {
		"between" : "",
		formulaAction.getString_array : func(_args) : return ["0.6`*SKI"],
		formulaAction.getString_partial : func(_args) : 
			return "0.6`*SKI",
		formulaAction.getCalculation_array : func(args) : #args = attributes
			var retVal : Array[float] = []
			retVal.append(0.6*args[Definitions.attributeEnum.SKI])
			return retVal,
		formulaAction.getCalculation_partial : func(args) : #args = attributes
			return 0.6*args[Definitions.attributeEnum.SKI]},
	"DR" : {
		"between" : " + ",
		formulaAction.getString_array : func(_args) : return ["DEX Scaling`*DEX", "INT Scaling`*INT", "STR Scaling`*STR"],
		formulaAction.getString_partial : func(args) :
			if (args == Definitions.attributeEnum.DEX) :
				return "DEX Scaling`*DEX"
			elif (args == Definitions.attributeEnum.INT) :
				return "INT Scaling`*INT"
			elif (args == Definitions.attributeEnum.STR) :
				return "STR Scaling`*STR"
			else :
				return "",
		formulaAction.getCalculation_array : func(args) : #args[0]-args[N-1] = scalings, args[N]-args[2N-1] = attr
			var retVal : Array[float] = []
			for key in Definitions.attributeDictionary.keys() :
				if (key == Definitions.attributeEnum.STR || key == Definitions.attributeEnum.DEX || key == Definitions.attributeEnum.INT) :
					retVal.append(args[key]*args[Definitions.attributeDictionary.keys().size()+key])
			return retVal,
		formulaAction.getCalculation_partial : func(args) : return args[0]*args[1]}, #args[0] = scaling, args[1] = attr
	"MAXHP" : {
		"between" : "",
		formulaAction.getString_array : func(_args) : return ["10`*DUR"],
		formulaAction.getString_partial : func(_args) : return "10`*DUR",
		formulaAction.getCalculation_array : func(args) : return [10*args],
		formulaAction.getCalculation_partial : func(args) : return 10*args},
	"PHYSDEF" : {
		"between" : " + ",
		formulaAction.getString_array : func(_args) : return ["0.15`*DEX", "0.6`*DUR", "0.3`*STR", "0.6`*SKI"],
		formulaAction.getString_partial : func(args) :
			if (args == Definitions.attributeEnum.DEX) :
				return "0.15`*DEX"
			elif (args == Definitions.attributeEnum.DUR) :
				return "0.6`*DUR"
			elif (args == Definitions.attributeEnum.STR) :
				return "0.3`*STR"
			elif (args == Definitions.attributeEnum.SKI) :
				return "0.6`*SKI"
			else :
				return "",
		formulaAction.getCalculation_array : func(args) : return [0.15*args[Definitions.attributeEnum.DEX], 0.6*args[Definitions.attributeEnum.DUR], 0.3*args[Definitions.attributeEnum.STR], 0.6*args[Definitions.attributeEnum.SKI]],
		formulaAction.getCalculation_partial : func(args) : #[type : Definitions.attributeEnum, val : float]
			if (args[0] == Definitions.attributeEnum.DEX) :
				return 0.15*args[1]
			elif (args[0] == Definitions.attributeEnum.DUR) :
				return 0.6*args[1]
			elif (args[0] == Definitions.attributeEnum.STR) :
				return 0.3*args[1]
			elif (args[0] == Definitions.attributeEnum.SKI) :
				return 0.6*args[1]
			else :
				return 0},
	"MAGDEF" : {
		"between" : " + ",
		formulaAction.getString_array : func(_args) : return ["0.15`*DEX", "0.6`*DUR", "0.3`*INT", "0.6`*SKI"],
		formulaAction.getString_partial : func(args) :
			if (args == Definitions.attributeEnum.DEX) :
				return "0.15`*DEX"
			elif (args == Definitions.attributeEnum.DUR) :
				return "0.6`*DUR"
			elif (args == Definitions.attributeEnum.INT) :
				return "0.3`*INT"
			elif (args == Definitions.attributeEnum.SKI) :
				return "0.6`*SKI"
			else :
				return "",
		formulaAction.getCalculation_array : func(args) : return [0.15*args[Definitions.attributeEnum.DEX], 0.6*args[Definitions.attributeEnum.DUR], 0.3*args[Definitions.attributeEnum.INT], 0.6*args[Definitions.attributeEnum.SKI]],
		formulaAction.getCalculation_partial : func(args) : #[type : Definitions.attributeEnum, val : float]
			if (args[0] == Definitions.attributeEnum.DEX) :
				return 0.15*args[1]
			elif (args[0] == Definitions.attributeEnum.DUR) :
				return 0.6*args[1]
			elif (args[0] == Definitions.attributeEnum.INT) :
				return 0.3*args[1]
			elif (args[0] == Definitions.attributeEnum.SKI) :
				return 0.6*args[1]
			else :
				return 0},
	"Damage Value" : {
		"between" : "",
		formulaAction.getString_array : func(_args) : return ["source power * source's DR * (source's AR/defender's PHYSDEF or MAGDEF)"],
		formulaAction.getString_partial : func(_args) : return "source power * source's DR * (source's AR/defender's PHYSDEF or MAGDEF)",
		formulaAction.getCalculation_array : func(args) : #args[0] = power, args[1] = DR, args[2] = AR, args[3] = DEF
			return [args[0]*args[1]*args[2]/args[3]],
		formulaAction.getCalculation_partial : func (args) :
			return args[0]*args[1]*args[2]/args[3]}
}
func getFormula(formulaKey : String, action : formulaAction, args) :
	if (action == formulaAction.getString_full) :
		var retVal : String = ""
		var arr = formulas[formulaKey][formulaAction.getString_array].call(args)
		for item in arr :
			retVal += item
			if (item != arr.back()) :
				retVal += formulas[formulaKey]["between"]
		return retVal
	elif (action == formulaAction.getCalculation_full) :
		var retVal : float = 0
		var arr = formulas[formulaKey][formulaAction.getCalculation_array].call(args)
		for item in arr :
			retVal += item
		return retVal
	else :
		return formulas[formulaKey][action].call(args)
## Because I've chosen to use enum keys 
	
const keywords : Array[String] = [
	"Action Power",
	"Always Discard",
	"Always Take",
	"Attack Rating",
	"Attribute",
	"Base",
	"Class",
	"Combat Reward Behaviour",
	"Combat Stat",
	"Currency",
	"Damage Rating",
	"Damage Value",
	"Dexterity",
	"Durability",
	"Final",
	"Intelligence",
	"Max HP",
	"Magic Defense",
	"Number",
	"Physical Defense",
	"Prebonus",
	"Premultiplier",
	"Postbonus",
	"Postmultiplier",
	"Routine",
	"Scaling",
	"Strength",
	"Weapon",
	
	"Physical Damage Dealt",
	"Magic Damage Dealt",
	"Physical Conversion",
	"Magic Conversion",
	"Physical Damage Taken",
	"Magic Damage Taken",
	
	"Tag",
	"Equipment tag",
	"Enemy tag",
	
	"Signature",
	"Boss",
	"Veteran",
	
	"Perennial",
	"Natural",
	"Crude",
	"Advanced",
	"Superior",
	"Dragon's Hoard",
	
	"Melee",
	"Ranged",
	
	"Anti-Magic",
	"Balanced",
	"Anti-Physical",
	
	"Magical",
	"Resistant",
	"Hardened",
	"Ironclad",
	
	"Unequipped",
	"Poorly Equipped",
	"Well Equipped",
	"Elite",
	
	"Vanguard",
	"Backline",
	
	"Element",
	"Fire",
	"Earth",
	"Water",
	"Ice",
	
	"Faction",
	"Demonic Civilian",
	"Demonic Military",
	"Naturekin",
	"Flamekin",
	"Greenskin",
	"Frostkin",
	"Merfolk",
	"Wanderkin",
	"Undead",
	"Nautikin",
	
	"Biome"
	]
const keyword_alternates : Dictionary = {
	"Dexterity" : "DEX",
	"Durability" : "DUR",
	"Intelligence" : "INT",
	"Skill" : "SKI",
	"Strength" : "STR",
	"Max HP" : "MAXHP",
	"Attack Rating" : "AR",
	"Damage Rating" : "DR",
	"Physical Defense" : "PHYSDEF",
	"Magic Defense" : "MAGDEF",
	"Physical Damage Dealt" : "PDD",
	"Physical Damage Taken" : "PDT",
	"Magic Damage Dealt" : "MDD",
	"Magic Damage Taken" : "MDT",
	"Miku Miku Dance" : "MMD",
}

var descriptions : Dictionary = {
	"Class" : "The Player's Class determines their starting Attributes, Attribute Premultipliers, and unarmed Weapon Scaling.",
	
	"Currency" : "Currency items do not take up inventory space and only exist to be exchanged at shops.", 
		
	"Attribute" : "Attributes are a measure of the player's basic ability, and are shown in the Player Panel (left).\n\nAttributes are used to calculate their Combat Stats, which are vital for combat. The 5 Attributes are Dexterity, Durability, Intelligence, Skill, and Strength.",
	
	"Dexterity" : "Dexterity is an Attribute measuring the Player's agility, finnesse, and wit.\n\tWhen a suitable weapon is equipped, Dexterity provides a Prebonus to DR of <DR CONTRIBUTION>.\n\tDexterity provides a Prebonus to Physical Defense and Magic Defense of <PHYSDEF CONTRIBUTION> to reflect the Player's skill at dodging.",
	
	"Durability" : "Durability is an Attribute measuring the Player's health and resistance to damage.\n\tDurability provides a Prebonus to HP of <MAXHP FORMULA>.\n\tDurability provides a Prebonus to Physical Defense and Magic Defense of <PHYSDEF CONTRIBUTION> to reflect the Player's tenacity and grit.",
	
	"Intelligence" : "Intelligence is an Attribute measuring the Player's quick thinking, learning capacity, and accumulated knowledge, and psionic power.\n\tWhen a suitable weapon is equipped, Intelligence provides a Prebonus to DR of <DR CONTRIBUTION>.\n\tIntelligence provides a Prebonus to Magic Defense of <MAGDEF CONTRIBUTION> to reflect the fortitude of the Player's psyche.",
	
	"Skill" : "Skill is an Attribute measuring the Player's practice and innate ability in the art of combat.\n\tSkill provides a Prebonus to AR of <AR CONTRIBUTION>.\n\tSkill provides a prebonus to Physical Defense and Magic Defense of <PHYSDEF CONTRIBUTION> to reflect the player's ability to anticipate their opponents' attacks and execute defensive maneuvers",
	
	"Strength" : "Strength is an Attribute measuring the Player's raw physical power.\n\tWhen a suitable weapon is equipped, Strength provides a Prebonus to DR of <DR CONTRIBUTION>.\n\tStrength provides a Prebonus to Physical Defense of <PHYSDEF CONTRIBUTION> to reflect the Player's physical health and the hardness of their body.",
	
	"Combat Stat" : "Combat Statistics measure a combatant's prowess in certain elements of combat, and are shown in the Player Panel (left).\n\nWhile enemies typically have preset Combat Stats, the Player's stats can be improved in a variety of ways. Combat Stats can also be modified during combat by certain effects. The Combat Stats are Max HP, Attack Rating, Damage Rating, Physical Defense, and Magic Defense.",
	
	"Max HP" : "Max HP is a Combat Statistic. A combatant always starts with HP = Max HP. When their HP hits 0 due to Damage, they die\n\tBase Max HP = <MAXHP FORMULA>",
	
	"Physical Defense" : "A combatant's Physical Defense is a Combat Stat that reduces the Damage Value of incoming damaging physical effects\n\tBase PHYSDEF = <PHYSDEF FORMULA>.",
	
	"Magic Defense" : "A combatant's Magic Defense is a Combat Stat that reduces the Damage Value of incoming damaging magic effects\n\tBase MAGDEF = <MAGDEF FORMULA>.",
	
	"Weapon" : "The Player's Weapon determines their AR Scaling, what their basic attack Action is, and provides a Postbonus to their Attack Rating.",
	
	"Number" : "Every number in this game is either a Prebonus, Postbonus, Premultiplier, Postmultiplier, Base value, or Final value. Prebonuses and Premultipliers are used to calculate Base values, and Base values, Postbonuses and Postmultipliers are used to calculate Final values.\n\nAll values are Final values unless otherwise specified. So in other words, you don't need to worry about the distinction unless you want to know how something is calculated!",
	
	"Base" : "A Base value is a Number that is calculated using Prebonuses and Premultipliers, and is used to calculate the Final value.\nBase = (sum of Prebonuses) * (product of Premultipliers).",
	
	"Final" : "A Final value is a Number that is calculated using a Base value, Postbonuses, and Postmultipliers.\nFinal = Base * (sum of Postmultipliers) + sum of Postbonuses. Unless otherwise specified, all Numbers are Final values.",
	
	"Prebonus" : "A Prebonus is an additive Number that is used to calculate a Base value.\nBase value = (sum of Prebonuses) * (product of Premultipliers).",
	
	"Premultiplier" : "A Premultiplier is a multiplicative Number that is used to calculate a Base value.\nBase value = (sum of Prebonuses) * (product of Premultipliers).",
	
	"Postbonus" : "A Postbonus is an additive Number that is used to calculate a Final value.\nFinal value = Base * (1 + sum of Postmultipliers) + (sum of Postbonuses).",
	
	"Postmultiplier" : "A Postmultiplier is a multiplicative Number that is used to calculate a Final value.\nFinal value = Base * (sum of Postmultipliers) + (sum of Postbonuses).",
	
	"Attack Rating" : "A combatant's Attack Rating is a Combat Stat measuring their accuracy and ability to circumvent their opponent's defenses.\nThe Damage Value of a damaging effect is proportional to the source's Attack Rating.\n\tBase AR = <AR FORMULA>.",
	
	"Damage Rating" : "A combatant's Damage Rating is a Combat Stat measuring the power of their weapon and how well they can use it. The Damage Value of an effect is proportional to the source's Damage Rating.\n\tBase DR = <DR FORMULA>.",
	
	"Damage Value" : "The damage dealt to a combatant by an attack or other effect.\n\tBase Damage Value = <DAMAGE VALUE FORMULA>.\n\tIf the damaging effect is an attack, the source power is the Action Power of the attack.",
	
	"Action Power" : "The fundamental strength of a combat action, independent of the power of the weapon or its user. Typically used to calculate damage dealt or healing provided. ",

	"Routine" : "Routines can be used to increase Attributes over time. Each Routine improves Attributes at different rates, and more Routines can be acquired from sources such as Quests. To view and use Routines, see the \"Training\" tab.",
	
	"Combat Reward Behaviour" : "Wait\n\nAlways Take\n\nAlways Discard",
	
	"Wait" : "This item must be manually taken or discarded from combat rewards.\nThis setting can be changed later per-item in the in-game options (F1).",
	
	"Always Take" : "Always take this item from combat rewards.\nThis setting can be changed later per-item in the in-game options (F1).\n\nBehaviour when inventory is full depends on \"Inventory Behaviour\" in the in-game options (F1)",
	
	"Always Discard" : "Always discard this item from combat rewards.\nThis setting can be changed later per-item in the in-game options (F1).",
	
	"Inventory Behaviour" : "Determines whether \"Always Take\" will wait or discard when the inventory is full.",
	
	"Scaling" : "Weapons provide a Prebonus to DR based on the Player's Attributes and their Weapon's Scaling for those respective Attributes. Scaling ranges between E and S, with S being the highest. Hover over the letter in game to see the decimal scaling value.",
	
	################################################################
	## Tags
	"Tag" : "Tags determine what equipment an enemy can drop. Both equipment and enemies have Tags, and either can disqualify an item from dropping. See Equipment tags and Enemy tags.",
	"Equipment tag" : "The 5 technology Equipment tags are Perennial, Natural, Crude, Advanced, and Superior.\n\nThe 2 offensive (Weapon) Equipment tags are Melee and Ranged.\n\nThe 3 defensive (Armor) Equipment tags are Anti-Magic, Balanced, and Anti-Physical.\n\nItems may also have the standalone Signature Tag.",
	"Enemy tag" : "The 4 technology Enemy tags are Unequipped, Poorly Equipped, Well Equipped, and Elite.\n\nThe 2 offensive (Weapon) Enemy tags are Vanguard and Backline.\n\nThe 4 defensive (Armor) Enemy tags are Magical, Resistant, Hardened, and Ironclad.\n\nEnemies may also have the standalone Boss or Veteran Tags.",

	"Perennial" : "This equipment can only be dropped by enemies with the Unequipped, Poorly Equipped, Well Equipped, or Elite Tags.",
	"Natural" : "This equipment can only be dropped by enemies with the Unequipped or Poorly Equipped Tags.",
	"Crude" : "This equipment can only be dropped by enemies with the Poorly Equipped Tag.",
	"Advanced" : "This equipment can only be dropped by enemies with the Well Equipped Tag.",
	"Superior" : "This equipment can only be dropped by enemies with the Well Equipped or Elite Tags.",
	
	"Unequipped" : "This enemy can only drop equipment with the Perennial or Natural Tags.",
	"Poorly Equipped" : "This enemy can only drop equipment with the Perennial, Natural, or Crude Tags.",
	"Well Equipped" : "This enemy can only drop equipment with the Perennial, Advanced, or Superior Tags.",
	"Elite" : "This enemy can only drop equipment with the Perennial or Superior Tags.",
	"Dragon's Hoard" : "Dragons can drop anything! Ignore all equipment Tags! The Biome still applies though (let's be reasonable here)",
	
	"Melee" : "This Weapon cannot be dropped by enemies with the Backline Tag.",
	"Ranged" : "This Weapon cannot be dropped by enemies with the Vanguard Tag.",
	
	"Vanguard" : "This enemy cannot drop Weapons with the Ranged Tag.",
	"Backline" : "This enemy cannot drop Weapons with the Melee Tag.",
	
	"Anti-Magic" : "This Armor provides high Magic Defense and can only drop from enemies with the Magical or Resistant tags.",
	"Balanced" : "This Armor provides balanced Magic Defense and Physical Defense and can only drop from enemies with the Resistant or Hardened tags.",
	"Anti-Physical" : "This Armor provides high Physical Defense and can only drop from enemies with the Hardened or Ironclad tags.",
	
	"Magical" : "This enemy has high Magic Defense and can only drop Armor with the Anti-Magic Tag.",
	"Resistant" : "This enemy has fairly high Magic Defense and can only drop Armor with the Anti-Magic or Balanced Tags.",
	"Hardened" : "This enemy has fairly high Physical Defense and can only drop Armor with the Anti-Physical or Balanced Tags.",
	"Ironclad" : "This enemy has high Physical Defense and can only drop Armor with the Anti-Physical Tag.",
	
	"Element" : "Some equipment has a particular Element. Elemental equipment can only be dropped in certain biomes (displayed on the top right corner of the Combat Map), but can provide powerful synergies:\n\nWhen the Element of your Weapon and Accessory match, you gain a x1.25 premultiplier to DR.\n\nWhen the Element of your Armor and Accessory match, you gain a x1.25 premultiplier to PHYSDEF and MAGDEF.\n\nThe 4 Elements are Fire, Water, Earth, and Ice.",
	"Fire" : "Fire is the Element of destruction.",
	"Ice" : "Ice is the Element of unchange.",
	"Water" : "Water is the Element of change.",
	"Earth" : "Earth is the Element of creation.",
	
	"Signature" : "This equipment is a Boss' signature drop!",
	"Boss" : "This enemy is the boss of its floor. It drops 42% more items on average and has a powerful signature drop!",
	"Veteran" : "This enemy is pretty strong, but drops 27% more items on average.",
	
	"Faction" : "Each enemy belongs to a single Faction. A given biome will only contain enemies of permitted factions, displayed on the top right corner of the Combat Map. The 10 Factions are: Flamekin, Frostkin, Naturekin, Nautikin, Demonic Civilian, Demonic Military, Greenskin, Merfolk, Undead, and Wanderkin.",
	"Demonic Civilian" : "The Demonic Civilian Faction includes Demons too weak, dumb, or unruly to be drafted into the Demonic Military.",
	"Demonic Military" : "The Demonic Military Faction consists of cannon fodder, elite shock troops, commanders, war machines, and the Demon King.",
	"Naturekin" : "The Naturekin Faction includes magical beings aligned with earth.",
	"Flamekin" : "The Flamekin Faction includes magical beings aligned with fire.",
	"Frostkin" : "The Frostkin Faction includes magical beings aligned with ice.",
	"Nautikin" : "The Nautikin Faction includes magical beings aligned with water.",
	"Greenskin" : "The Greenskin Faction includes monstrous surface dwelling humanoids, such as orcs and goblins.",
	"Wanderkin" : "The Wanderkin Faction includes hermits, travelers, and malfunctioning automotons that go where they please and have allegiance to no one but themselves.",
	"Undead" : "The Undead Faction includes those that practice necromancy and their creations.",
	"Merfolk" : "The Merfolk Faction are a proud and powerful race, unbothered by the affairs of surface or underworld dwellers.",
	
	"Biome" : "Each floor is generated with a specific Biome. The Biome determines what Elements are eligible to drop and what Factions are eligible to appear. The Biome and its effects can be seen in the top right of the Combat Map.",
	##################################################################
	"Physical Damage Dealt" : "Physical Damage Dealt/PDD, applies before Physical Conversion.",
	"Magic Damage Dealt" : "Magic Damage Dealt/MDD, applies before Magic Conversion.",
	"Physical Damage Taken" : "Physical Damage Taken, aka PDT",
	"Magic Damage Taken" : "Magic Damage Taken, aka MDT",
	"Physical Conversion" : "Applies a portion of physical damage to the enemy's MAGDEF instead of their PHYSDEF.",
	"Magic Conversion" : "Applies a portion of magic damage to the enemy's PHYSDEF instead of their MAGDEF.",
	"Miku Miku Dance" : "henlo"
}
#func getEncyclopediaEntries() -> Dictionary :
	#var tempDict : Dictionary = {}
	#for key in keywords :
		#if (keyword_alternates.get(key) != null) :
			#tempDict[keyword_alternates[key]] = descriptions[key]
		#else :
			#tempDict[key] = descriptions[key]
	#return tempDict
func addAlternativeKeywordsToDescriptions() :
	for key in keyword_alternates.keys() :
		if (keyword_alternates[key] is Array) :
			for val in keyword_alternates[key] :
				descriptions[val] = descriptions[key]
		else :
			descriptions[keyword_alternates[key]] = descriptions[key]
func addFormulasToDescriptions() :
	for key in Definitions.attributeDictionary.keys() :
		var ARContribution = getFormula("AR", formulaAction.getString_partial, key)
		descriptions[Definitions.attributeDictionary[key]] = descriptions[Definitions.attributeDictionary[key]].replace("<AR CONTRIBUTION>", ARContribution)
		var DRContribution = getFormula("DR", formulaAction.getString_partial, key)
		descriptions[Definitions.attributeDictionary[key]] = descriptions[Definitions.attributeDictionary[key]].replace("<DR CONTRIBUTION>", DRContribution)
		var PHYSDEFContribution = getFormula("PHYSDEF", formulaAction.getString_partial, key)
		descriptions[Definitions.attributeDictionary[key]] = descriptions[Definitions.attributeDictionary[key]].replace("<PHYSDEF CONTRIBUTION>", PHYSDEFContribution)
		var MAGDEFContribution = getFormula("MAGDEF", formulaAction.getString_partial, key)
		descriptions[Definitions.attributeDictionary[key]] = descriptions[Definitions.attributeDictionary[key]].replace("<MAGDEF CONTRIBUTION>", MAGDEFContribution)
	for key in descriptions.keys() :
		descriptions[key] = descriptions[key].replace("<MAXHP FORMULA>", getFormula("MAXHP", formulaAction.getString_full, null))
		descriptions[key] = descriptions[key].replace("<AR FORMULA>", getFormula("AR", formulaAction.getString_full, null))
		descriptions[key] = descriptions[key].replace("<DR FORMULA>", getFormula("DR", formulaAction.getString_full, null))
		descriptions[key] = descriptions[key].replace("<DAMAGE VALUE FORMULA>", getFormula("Damage Value", formulaAction.getString_full,null))
		descriptions[key] = descriptions[key].replace("<PHYSDEF FORMULA>", getFormula("PHYSDEF", formulaAction.getString_full, null))
		descriptions[key] = descriptions[key].replace("<MAGDEF FORMULA>", getFormula("MAGDEF", formulaAction.getString_full, null))
