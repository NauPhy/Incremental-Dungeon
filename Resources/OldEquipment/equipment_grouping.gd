extends Resource

class_name EquipmentGroups

@export var isEligible : bool = true
enum qualityEnum {common,uncommon,rare,epic,legendary}
const qualityDictionary = {
	qualityEnum.common : "Common",
	qualityEnum.uncommon : "Uncommon",
	qualityEnum.rare : "Rare",
	qualityEnum.epic : "Epic",
	qualityEnum.legendary : "Legendary"
}
static func getColouredQualityString(quality : qualityEnum, lightBackground : bool) :
	return colourText(quality, qualityDictionary[quality], lightBackground)
static func colourText(quality : qualityEnum, myText : String, lightBackground : bool) -> String :
	const colours = ["#202020", "57a968", "#4566c3", "#a149cc", "#d4941c"]
	const colours_alt = ["#e5e5e5", "4c945b", "4d70d1", "a149cc", "#efa71f"]
	var colourStr
	if (lightBackground) :
		colourStr = colours[quality]
	else :
		colourStr = colours_alt[quality]
	return "[color=" + colourStr + "]" + myText + "[/color]"
@export var quality : qualityEnum = qualityEnum.common
enum technologyEnum {natural,crude,advanced,superior}
##Natural is stuff made in nature (duh). On average you can expect natural equipment to be worse, but there are exceptions
##such as... well... any dragon body part really. 
## Crude is basically anything made without artificial magic or metallurgy, including leather armor, slings, dragonbone armor, etc.
## Advanced is early middle ages metallurgy and smaller metal weapons, like chainmail, shortswords, etc.
## Superior is anything made with artificial magic, including enchanted equipment (as opposed to equipment made from magic materials, which could be crude),
## as well as large, heavy equipment, top quality steel, and middle to late midievable age weapons. This includes arming swords, rapiers, full plate, greatswords, crossbows, etc.

##Usage : An animal cannot drop anything that isn't natural, an Orc can't drop superior but can drop advanced, a death knight will only drop superior, etc.
@export var technology : technologyEnum = technologyEnum.natural

enum weaponClassEnum {melee, ranged, na}
@export var weaponClass : weaponClassEnum = weaponClassEnum.na
enum armorClassEnum {light,medium,heavy,na}
@export var armorClass : armorClassEnum = armorClassEnum.na

## Environment whitelists: If an item has one of these properties it will not show up in the rewards unless
## in a specific environment
@export var isFire : bool = false
@export var isIce : bool = false
@export var isEarth : bool = false
@export var isWater : bool = false
