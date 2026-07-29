extends Node

var colonyName = "Pebble"
var otherNames = {}
var buildingCount = 0
var cityCount = 0
var mineCount = 0

var loadSlot = 0

var screenSize = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))

var tileSize = Vector2i(128, 64)
var mapSize = Vector2i(24, 24) #camera bounds bug out if you don't keep it a square...

var seaLevel = 0
var height = 8

var selectedTile = Vector2i(0, 0)
var selected = false

var reserves = {} #amount of a resource stored up
var budgets = {} #amount of a resource produced/spent each turn
var trades = {} #each trade order

var turn = 0
var gameLength = 60 #normally 60 is best

var score = 0

enum ACHIEVEMENTS {
	build10,build20,build30,build40,build50,build60,build70,build80,build90,build100,
	ecumenopolis, #build ~450 buildings, covering around 80% of Pebble's surface
	pop5,pop10,pop15,pop20,pop25,pop30,pop35,pop40,pop45,pop50,
	wealth1k,wealth2k,wealth3k,wealth4k,wealth5k,wealth6k,wealth7k,wealth8k,wealth9k,wealth10k,wealth15k,wealth20k,
	ind1k,ind2k,ind3k,ind4k,ind5k,ind6k,ind7k,ind8k,ind9k,ind10k,ind15k,ind20k,
	inf1k,inf2k,inf3k,inf4k,inf5k,inf6k,inf7k,inf8k,inf9k,inf10k,inf15k,inf20k,
	firststeel,firstconcrete,firstelectronics,firstcivilian,
	firstspaceport,firstfusion,firstfarm,
	mine5,mine10,mine20,mine50,
	score10k,score20k,score30k,score40k,score50k,score60k,score70k,score80k,score90k,score100k
}

var achievementNames = {
	ACHIEVEMENTS.build10:"Built its 10th building",ACHIEVEMENTS.build20:"Built its 20th building",
	ACHIEVEMENTS.build30:"Built its 30th building",ACHIEVEMENTS.build40:"Built its 40th building",
	ACHIEVEMENTS.build50:"Built its 50th building",ACHIEVEMENTS.build60:"Built its 60th building",
	ACHIEVEMENTS.build70:"Built its 70th building",ACHIEVEMENTS.build80:"Built its 80th building",
	ACHIEVEMENTS.build90:"Built its 90th building",ACHIEVEMENTS.build100:"Built its 100th building",
	ACHIEVEMENTS.ecumenopolis:"Built enough buildings to cover 80% of the planet's surface, turning the colony into an ecumenopolis.",
	ACHIEVEMENTS.pop5:"Built its 5th City",ACHIEVEMENTS.pop10:"Built its 10th City",ACHIEVEMENTS.pop15:"Built its 15th City",
	ACHIEVEMENTS.pop20:"Built its 20th City",ACHIEVEMENTS.pop25:"Built its 25th City",ACHIEVEMENTS.pop30:"Built its 30th City",
	ACHIEVEMENTS.pop35:"Built its 35th City",ACHIEVEMENTS.pop40:"Built its 40th City",ACHIEVEMENTS.pop45:"Built its 45th City",
	ACHIEVEMENTS.pop50:"Built its 50th City",
	ACHIEVEMENTS.wealth1k:"Reached [color=000099ff]1000 Wealth[/color]",ACHIEVEMENTS.wealth6k:"Reached [color=000099ff]6000 Wealth[/color]",
	ACHIEVEMENTS.wealth2k:"Reached [color=000099ff]2000 Wealth[/color]",ACHIEVEMENTS.wealth7k:"Reached [color=000099ff]7000 Wealth[/color]",
	ACHIEVEMENTS.wealth3k:"Reached [color=000099ff]3000 Wealth[/color]",ACHIEVEMENTS.wealth8k:"Reached [color=000099ff]8000 Wealth[/color]",
	ACHIEVEMENTS.wealth4k:"Reached [color=000099ff]4000 Wealth[/color]",ACHIEVEMENTS.wealth9k:"Reached [color=000099ff]9000 Wealth[/color]",
	ACHIEVEMENTS.wealth5k:"Reached [color=000099ff]5000 Wealth[/color]",ACHIEVEMENTS.wealth10k:"Reached [color=000099ff]10000 Wealth[/color]",
	ACHIEVEMENTS.wealth15k:"Reached [color=000099ff]15000 Wealth[/color]",ACHIEVEMENTS.wealth20k:"Reached [color=000099ff]20000 Wealth[/color]",
	ACHIEVEMENTS.ind1k:"Reached [color=000099ff]1000 Industry[/color]",ACHIEVEMENTS.ind7k:"Reached [color=000099ff]7000 Industry[/color]",
	ACHIEVEMENTS.ind2k:"Reached [color=000099ff]2000 Industry[/color]",ACHIEVEMENTS.ind8k:"Reached [color=000099ff]8000 Industry[/color]",
	ACHIEVEMENTS.ind3k:"Reached [color=000099ff]3000 Industry[/color]",ACHIEVEMENTS.ind9k:"Reached [color=000099ff]9000 Industry[/color]",
	ACHIEVEMENTS.ind4k:"Reached [color=000099ff]4000 Industry[/color]",ACHIEVEMENTS.ind10k:"Reached [color=000099ff]10000 Industry[/color]",
	ACHIEVEMENTS.ind5k:"Reached [color=000099ff]5000 Industry[/color]",ACHIEVEMENTS.ind15k:"Reached [color=000099ff]15000 Industry[/color]",
	ACHIEVEMENTS.ind6k:"Reached [color=000099ff]6000 Industry[/color]",ACHIEVEMENTS.ind20k:"Reached [color=000099ff]20000 Industry[/color]",
	ACHIEVEMENTS.inf1k:"Reached [color=000099ff]1000 Influence[/color]",ACHIEVEMENTS.inf7k:"Reached [color=000099ff]7000 Influence[/color]",
	ACHIEVEMENTS.inf2k:"Reached [color=000099ff]2000 Influence[/color]",ACHIEVEMENTS.inf8k:"Reached [color=000099ff]8000 Influence[/color]",
	ACHIEVEMENTS.inf3k:"Reached [color=000099ff]3000 Influence[/color]",ACHIEVEMENTS.inf9k:"Reached [color=000099ff]9000 Influence[/color]",
	ACHIEVEMENTS.inf4k:"Reached [color=000099ff]4000 Influence[/color]",ACHIEVEMENTS.inf10k:"Reached [color=000099ff]10000 Influence[/color]",
	ACHIEVEMENTS.inf5k:"Reached [color=000099ff]5000 Influence[/color]",ACHIEVEMENTS.inf15k:"Reached [color=000099ff]15000 Influence[/color]",
	ACHIEVEMENTS.inf6k:"Reached [color=000099ff]6000 Influence[/color]",ACHIEVEMENTS.inf20k:"Reached [color=000099ff]20000 Influence[/color]",
	ACHIEVEMENTS.mine5:"Built its 5th Mine",ACHIEVEMENTS.mine10:"Built its 10th Mine",
	ACHIEVEMENTS.mine20:"Built its 20th Mine",ACHIEVEMENTS.mine50:"Built its 50th Mine",
	ACHIEVEMENTS.firststeel:"Built its first Steel Factory",ACHIEVEMENTS.firstconcrete:"Built its first Concrete Factory",
	ACHIEVEMENTS.firstelectronics:"Built its first Electronics Factory",ACHIEVEMENTS.firstcivilian:"Built its first Civilian Factory",
	ACHIEVEMENTS.firstspaceport:"Built its first Spaceport",ACHIEVEMENTS.firstfusion:"Built its first Fusion Plant",
	ACHIEVEMENTS.firstfarm:"Built its first Farm",
	ACHIEVEMENTS.score10k:"Reached [color=000099ff]10000 Score[/color]",ACHIEVEMENTS.score60k:"Reached [color=000099ff]60000 Score[/color]",
	ACHIEVEMENTS.score20k:"Reached [color=000099ff]20000 Score[/color]",ACHIEVEMENTS.score70k:"Reached [color=000099ff]70000 Score[/color]",
	ACHIEVEMENTS.score30k:"Reached [color=000099ff]30000 Score[/color]",ACHIEVEMENTS.score80k:"Reached [color=000099ff]80000 Score[/color]",
	ACHIEVEMENTS.score40k:"Reached [color=000099ff]40000 Score[/color]",ACHIEVEMENTS.score90k:"Reached [color=000099ff]90000 Score[/color]",
	ACHIEVEMENTS.score50k:"Reached [color=000099ff]50000 Score[/color]",ACHIEVEMENTS.score100k:"Reached [color=000099ff]100000 Score[/color]",
}

var achievementsRecord = {}

func achievementsToCode():
	var code = ""
	if not achievementsRecord.is_empty():
		for achievement in achievementsRecord.keys():
			code += str(achievement) + "," + str(achievementsRecord[achievement]) + "|"
	return code

func loadAchievements(code: String):
	for index in (code.get_slice_count("|")):
		var slice = code.get_slice("|", index)
		var achievement = slice.get_slice(",", 0).to_int()
		var turnslice = slice.get_slice(",", 1)
		achievementsRecord[achievement] = turnslice

var resourcePrices = {
	RESOURCE.IRON: 1,
	RESOURCE.COPPER: 1,
	RESOURCE.ZINC: 1,
	RESOURCE.ALUMINUM: 1,
	RESOURCE.GOLD: 2,
	RESOURCE.URANIUM: 2,
	RESOURCE.LITHIUM: 2,
	RESOURCE.ICE: 0.5,
	RESOURCE.SILICATE: 0.5,
	RESOURCE.CARBON: 1,
	RESOURCE.PHOSPHORUS: 2,
	RESOURCE.STEEL: 2,
	RESOURCE.BRASS: 2,
	RESOURCE.CONCRETE: 1,
	RESOURCE.PLASTIC: 2,
	RESOURCE.WATER: 1,
	RESOURCE.OXYGEN: 1,
	RESOURCE.HYDROGEN: 2,
	RESOURCE.NITROGEN: 1,
	RESOURCE.FERTILIZER: 2,
	RESOURCE.FOOD: 2,
	RESOURCE.ELECTRONICS: 4,
	RESOURCE.CIVGOODS: 8
}

var resourceDescriptions = {
	RESOURCE.MONEY: "Currency and capital, useful for construction and trade.",
	RESOURCE.ENERGY: "Energy, useful for powering buildings.",
	RESOURCE.LABOR: "Labor, the colony's currently free workforce.",
	RESOURCE.IRON: "A common metal ore, essential for Steel production.",
	RESOURCE.COPPER: "A conductive metal ore used for wiring and Electronics.",
	RESOURCE.ZINC: "A soft metal ore used in alloys and galvanization.",
	RESOURCE.ALUMINUM: "A lightweight metal ore with wide industrial applications.",
	RESOURCE.GOLD: "A rare and valuable metal used in Electronics.",
	RESOURCE.URANIUM: "A radioactive ore used to fuel nuclear reactors.",
	RESOURCE.LITHIUM: "A reactive metal essential for battery production.",
	RESOURCE.ICE: "Frozen Water deposits mined from the surface.",
	RESOURCE.SILICATE: "Raw regolith mineral used in Concrete production.",
	RESOURCE.CARBON: "A raw, dark mineral used in Steel production.",
	RESOURCE.PHOSPHORUS: "A volatile element essential for Fertilizer production.",
	RESOURCE.STEEL: "A refined alloy of Iron and Carbon.",
	RESOURCE.BRASS: "A refined alloy of Copper and Zinc.",
	RESOURCE.CONCRETE: "A durable building material refined from Silicate and Steel.",
	RESOURCE.PLASTIC: "A versatile synthetic material used in manufacturing.",
	RESOURCE.WATER: "Liquid water extracted from melted Ice deposits.",
	RESOURCE.OXYGEN: "A breathable gas essential for colony survival.",
	RESOURCE.HYDROGEN: "A light combustible gas used as fuel for fusion reactors.",
	RESOURCE.NITROGEN: "An inert gas essential for Fertilizer production.",
	RESOURCE.FERTILIZER: "A nutrient-rich compound useful for Food production.",
	RESOURCE.FOOD: "Consumables grown and processed to sustain the population.",
	RESOURCE.ELECTRONICS: "Sophisticated components used in advanced manufacturing.",
	RESOURCE.CIVGOODS: "Profitable consumer goods for use or export.",
	RESOURCE.TRADE: "The quantity of available trade exports and imports.",
	RESOURCE.WEALTH: "The wealthiness of the colony's economy.",
	RESOURCE.INDUSTRY: "The industrial productivity of the colony.",
	RESOURCE.INFLUENCE: "The colony's political and cultural influence.",
	RESOURCE.SCORE: "The total score of this colony. \nYour goal is to maximize this!"
}

var resIcons = {
	RESOURCE.MONEY: &"res://resources/resIcons/money.tres",
	RESOURCE.ENERGY: &"res://resources/resIcons/energy.tres",
	RESOURCE.LABOR: &"res://resources/resIcons/labor.tres",
	RESOURCE.IRON: &"res://resources/resIcons/iron.tres",
	RESOURCE.COPPER: &"res://resources/resIcons/copper.tres",
	RESOURCE.ZINC: &"res://resources/resIcons/zinc.tres",
	RESOURCE.ALUMINUM: &"res://resources/resIcons/aluminum.tres",
	RESOURCE.GOLD: &"res://resources/resIcons/gold.tres",
	RESOURCE.URANIUM: &"res://resources/resIcons/uranium.tres",
	RESOURCE.LITHIUM: &"res://resources/resIcons/lithium.tres",
	RESOURCE.ICE: &"res://resources/resIcons/ice.tres",
	RESOURCE.SILICATE: &"res://resources/resIcons/silicate.tres",
	RESOURCE.CARBON: &"res://resources/resIcons/carbon.tres",
	RESOURCE.PHOSPHORUS: &"res://resources/resIcons/phosphorus.tres",
	RESOURCE.STEEL: &"res://resources/resIcons/steel.tres",
	RESOURCE.BRASS: &"res://resources/resIcons/brass.tres",
	RESOURCE.CONCRETE: &"res://resources/resIcons/concrete.tres",
	RESOURCE.PLASTIC: &"res://resources/resIcons/plastic.tres",
	RESOURCE.WATER: &"res://resources/resIcons/water.tres",
	RESOURCE.OXYGEN: &"res://resources/resIcons/oxygen.tres",
	RESOURCE.HYDROGEN: &"res://resources/resIcons/hydrogen.tres",
	RESOURCE.NITROGEN: &"res://resources/resIcons/nitrogen.tres",
	RESOURCE.FERTILIZER: &"res://resources/resIcons/fertilizer.tres",
	RESOURCE.FOOD: &"res://resources/resIcons/food.tres",
	RESOURCE.ELECTRONICS: &"res://resources/resIcons/electronics.tres",
	RESOURCE.CIVGOODS: &"res://resources/resIcons/civgoods.tres",
	RESOURCE.TRADE: &"res://resources/resIcons/trade.tres",
	RESOURCE.WEALTH: &"res://resources/resIcons/wealth.tres",
	RESOURCE.INDUSTRY: &"res://resources/resIcons/industry.tres",
	RESOURCE.INFLUENCE: &"res://resources/resIcons/influence.tres",
	RESOURCE.SCORE: &"res://resources/resIcons/score.tres"
}

enum RESOURCE {
	#Basic
	MONEY, ENERGY, LABOR,
	#Common Metals
	IRON, COPPER, ZINC, ALUMINUM, 
	#Rare Metals
	GOLD, URANIUM, LITHIUM,
	#Minerals
	ICE, SILICATE, CARBON, PHOSPHORUS,
	#Materials
	STEEL, BRASS, CONCRETE, PLASTIC,
	#Liquids and Gasses
	WATER, OXYGEN, HYDROGEN, NITROGEN,
	#Products
	FERTILIZER, FOOD, ELECTRONICS, CIVGOODS,
	#Stats
	TRADE, WEALTH, INDUSTRY, INFLUENCE, SCORE
}

var resourceCategoriesLR = [
	"Basic", "Common Metals", "Rare Metals",
	"Minerals", "Materials", "Liquids and Gasses",
	"Products", "Statistics"
]

var resourceCategories = {
	"Basic" : [RESOURCE.MONEY, RESOURCE.ENERGY, RESOURCE.LABOR, RESOURCE.TRADE],
	"Common Metals" : [RESOURCE.IRON, RESOURCE.COPPER, RESOURCE.ZINC, RESOURCE.ALUMINUM], 
	"Rare Metals" : [RESOURCE.GOLD, RESOURCE.URANIUM, RESOURCE.LITHIUM],
	"Minerals" : [RESOURCE.ICE, RESOURCE.SILICATE, RESOURCE.CARBON, RESOURCE.PHOSPHORUS],
	"Materials" : [RESOURCE.STEEL, RESOURCE.BRASS, RESOURCE.CONCRETE, RESOURCE.PLASTIC],
	"Liquids and Gasses" : [RESOURCE.WATER, RESOURCE.OXYGEN, RESOURCE.HYDROGEN, RESOURCE.NITROGEN],
	"Products" : [RESOURCE.FERTILIZER, RESOURCE.FOOD, RESOURCE.ELECTRONICS, RESOURCE.CIVGOODS],
	"Statistics" : [RESOURCE.WEALTH, RESOURCE.INDUSTRY, RESOURCE.INFLUENCE, RESOURCE.SCORE]
}

var depositToResource = {
	TERRAIN.IRON: RESOURCE.IRON, TERRAIN.COPPER: RESOURCE.COPPER, TERRAIN.ZINC: RESOURCE.ZINC, 
	TERRAIN.GOLD: RESOURCE.GOLD, TERRAIN.URANIUM: RESOURCE.URANIUM, TERRAIN.LITHIUM: RESOURCE.LITHIUM,
	TERRAIN.ICE: RESOURCE.ICE, TERRAIN.CARBON: RESOURCE.CARBON, TERRAIN.PHOSPHORUS: RESOURCE.PHOSPHORUS,
	TERRAIN.NITROGEN: RESOURCE.NITROGEN
}

enum TERRAIN {
	PLAIN,
	SEA,
	IRON,
	COPPER,
	ZINC,
	GOLD,
	URANIUM,
	LITHIUM,
	ICE,
	CARBON,
	PHOSPHORUS,
	NITROGEN
}

enum BUILDING {
	EMPTY,
	#Colony
	CENTER,
	CITY,
	ROAD,
	SPACEPORT,
	#Energy
	SOLAR_FARM,
	NUCLEAR_PLANT,
	FUSION_PLANT,
	#Harvest
	MINE,
	QUARRY,
	ICE_MINE,
	#Production
	STEEL_MILL,
	CONCRETE_PLANT,
	BRASS_MILL,
	PLASTIC_REFINERY,
	FERTILIZER_FACTORY,
	YEAST_VATS,
	FARM,
	WATER_EXTRACTOR,
	ELECTROLYZER,
	#Manufactory
	ELECTRONICS_FACTORY,
	CIVILIAN_FACTORY,
	#Special
	OUTPOST, #cap of 3
	WAREHOUSE, #cap of 3
	BANK, #cap of 3
	CAMPUS, #cap of 3
	MONUMENT, #cap of 3
	OBSERVATORY #cap of 3
}

var buildingNames = {
	BUILDING.CENTER : &"Colony Center",
	BUILDING.CITY : &"City",
	BUILDING.ROAD : &"Road",
	BUILDING.SPACEPORT : &"Spaceport",
	BUILDING.SOLAR_FARM : &"Solar Farm",
	BUILDING.NUCLEAR_PLANT : &"Nuclear Plant",
	BUILDING.FUSION_PLANT : &"Fusion Plant",
	BUILDING.MINE : &"Mine",
	BUILDING.QUARRY : &"Quarry",
	BUILDING.ICE_MINE : &"Ice Mine",
	BUILDING.STEEL_MILL : &"Steel Mill",
	BUILDING.CONCRETE_PLANT : &"Concrete Plant",
	BUILDING.BRASS_MILL : &"Brass Mill",
	BUILDING.PLASTIC_REFINERY : &"Plastic Refinery",
	BUILDING.FERTILIZER_FACTORY : &"Fertilizer Factory",
	BUILDING.YEAST_VATS : &"Yeast Vats",
	BUILDING.FARM : &"Farm",
	BUILDING.WATER_EXTRACTOR : &"Water Extractors",
	BUILDING.ELECTROLYZER : &"Electrolyzer Plant",
	BUILDING.ELECTRONICS_FACTORY : &"Electronics Factory",
	BUILDING.CIVILIAN_FACTORY : &"Civilian Factory",
	BUILDING.EMPTY : &"No Building"
}

var buildingScores = {
	BUILDING.CENTER : 1000,
	BUILDING.ROAD : 100,
	BUILDING.CITY : 500,
	BUILDING.SOLAR_FARM : 100,
	BUILDING.SPACEPORT : 500,
	BUILDING.NUCLEAR_PLANT : 250,
	BUILDING.FUSION_PLANT : 1500,
	BUILDING.MINE : 100,
	BUILDING.ICE_MINE : 100,
	BUILDING.QUARRY : 100,
	BUILDING.STEEL_MILL : 250,
	BUILDING.CONCRETE_PLANT : 500,
	BUILDING.BRASS_MILL : 250,
	BUILDING.PLASTIC_REFINERY : 250,
	BUILDING.FERTILIZER_FACTORY : 500,
	BUILDING.YEAST_VATS : 100,
	BUILDING.FARM : 1500,
	BUILDING.WATER_EXTRACTOR : 100,
	BUILDING.ELECTROLYZER : 250, #H₂O splits into 2H and O, but by volume oxygen is the larger output
	BUILDING.ELECTRONICS_FACTORY : 1500,
	BUILDING.CIVILIAN_FACTORY : 2000
}

var buildingBudgets = {
	BUILDING.CENTER : {RESOURCE.LABOR : 4, RESOURCE.MONEY : 4, RESOURCE.ENERGY : 4, RESOURCE.FOOD : 2, RESOURCE.CONCRETE : 4, 
			RESOURCE.STEEL : 2, RESOURCE.WATER : 2, &"DEPOSIT" : 1, RESOURCE.TRADE : 5},
	BUILDING.CITY : {RESOURCE.LABOR : 3, RESOURCE.ENERGY : -1, RESOURCE.FOOD : -1, RESOURCE.WATER : -1},
	BUILDING.SOLAR_FARM : {RESOURCE.MONEY : -1, RESOURCE.ENERGY : 2},
	BUILDING.SPACEPORT : {RESOURCE.ENERGY : -1, RESOURCE.LABOR : -1, RESOURCE.OXYGEN : -1, RESOURCE.HYDROGEN : -1, RESOURCE.TRADE : 4},
	BUILDING.NUCLEAR_PLANT : {RESOURCE.LABOR : -1, RESOURCE.ENERGY : 5, RESOURCE.URANIUM : -1},
	BUILDING.FUSION_PLANT : {RESOURCE.LABOR : -1, RESOURCE.ENERGY : 10, RESOURCE.HYDROGEN : -2},
	BUILDING.MINE : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, &"DEPOSIT" : 2},
	BUILDING.ICE_MINE : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.ICE : 2},
	BUILDING.QUARRY : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.SILICATE : 4},
	BUILDING.STEEL_MILL : {RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.IRON : -4, RESOURCE.CARBON: -1, RESOURCE.STEEL : 4},
	BUILDING.CONCRETE_PLANT : {RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.SILICATE : -4, RESOURCE.STEEL: -2, RESOURCE.CONCRETE : 6},
	BUILDING.BRASS_MILL : {RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.COPPER : -2, RESOURCE.ZINC : -1, RESOURCE.BRASS : 2},
	BUILDING.PLASTIC_REFINERY : {RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.CARBON : -2, RESOURCE.HYDROGEN : -1, RESOURCE.PLASTIC : 2},
	BUILDING.FERTILIZER_FACTORY : {RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.NITROGEN : -2, RESOURCE.PHOSPHORUS : -2, RESOURCE.FERTILIZER : 4},
	BUILDING.YEAST_VATS : {RESOURCE.ENERGY : -1, RESOURCE.WATER : -1, RESOURCE.FOOD : 2},
	BUILDING.FARM : {RESOURCE.LABOR : -1, RESOURCE.FERTILIZER : -1, RESOURCE.WATER : -1, RESOURCE.FOOD : 6},
	BUILDING.WATER_EXTRACTOR : {RESOURCE.ENERGY : -1, RESOURCE.ICE : -2, RESOURCE.WATER : 4},
	BUILDING.ELECTROLYZER : {RESOURCE.ENERGY : -1, RESOURCE.WATER : -1, RESOURCE.OXYGEN : 2, RESOURCE.HYDROGEN : 1}, #H₂O splits into 2H and O, but by volume oxygen is the larger output
	BUILDING.ELECTRONICS_FACTORY : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.BRASS : -2, RESOURCE.GOLD : -1, RESOURCE.LITHIUM : -1, RESOURCE.ELECTRONICS : 4},
	BUILDING.CIVILIAN_FACTORY : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.PLASTIC : -4, RESOURCE.ELECTRONICS : -2, RESOURCE.CIVGOODS : 4}
}

var buildingCosts = {
	BUILDING.CITY : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 6, RESOURCE.STEEL : 4},
	BUILDING.ROAD : {RESOURCE.CONCRETE : 2, RESOURCE.STEEL : 1},
	BUILDING.SPACEPORT : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 6, RESOURCE.STEEL : 4},
	BUILDING.SOLAR_FARM : {RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 4},
	BUILDING.NUCLEAR_PLANT : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 8, RESOURCE.STEEL : 4},
	BUILDING.FUSION_PLANT : {RESOURCE.MONEY : 8, RESOURCE.CONCRETE : 8, RESOURCE.STEEL : 4},
	BUILDING.MINE : {RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 2},
	BUILDING.ICE_MINE : {RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 2},
	BUILDING.QUARRY : {RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 2},
	BUILDING.STEEL_MILL : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 6, RESOURCE.STEEL : 2},
	BUILDING.CONCRETE_PLANT : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 6, RESOURCE.STEEL : 2},
	BUILDING.BRASS_MILL : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 6, RESOURCE.STEEL : 2},
	BUILDING.PLASTIC_REFINERY : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 6, RESOURCE.STEEL : 2},
	BUILDING.FERTILIZER_FACTORY : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 6, RESOURCE.STEEL : 2},
	BUILDING.YEAST_VATS : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 2},
	BUILDING.FARM : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 2},
	BUILDING.WATER_EXTRACTOR : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 4, RESOURCE.STEEL :4},
	BUILDING.ELECTROLYZER : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 4},
	BUILDING.ELECTRONICS_FACTORY : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 6, RESOURCE.STEEL : 4},
	BUILDING.CIVILIAN_FACTORY : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 6, RESOURCE.STEEL : 4}
}

var buildingBannedTerrains = {
	BUILDING.CITY : [TERRAIN.SEA],
	BUILDING.ROAD : [TERRAIN.SEA],
	BUILDING.SPACEPORT : [TERRAIN.SEA],
	BUILDING.SOLAR_FARM : [TERRAIN.SEA],
	BUILDING.NUCLEAR_PLANT : [TERRAIN.SEA],
	BUILDING.FUSION_PLANT : [TERRAIN.SEA],
	BUILDING.MINE : [TERRAIN.PLAIN, TERRAIN.SEA],
	BUILDING.ICE_MINE : [TERRAIN.PLAIN, TERRAIN.SEA, TERRAIN.IRON, TERRAIN.COPPER, TERRAIN.ZINC, TERRAIN.GOLD, TERRAIN.URANIUM, TERRAIN.LITHIUM, TERRAIN.CARBON],
	BUILDING.QUARRY : [TERRAIN.SEA],
	BUILDING.STEEL_MILL : [TERRAIN.SEA],
	BUILDING.CONCRETE_PLANT : [TERRAIN.SEA],
	BUILDING.BRASS_MILL : [TERRAIN.SEA],
	BUILDING.PLASTIC_REFINERY : [TERRAIN.SEA],
	BUILDING.FERTILIZER_FACTORY : [TERRAIN.SEA],
	BUILDING.YEAST_VATS : [TERRAIN.SEA],
	BUILDING.FARM : [TERRAIN.SEA],
	BUILDING.WATER_EXTRACTOR : [TERRAIN.SEA],
	BUILDING.ELECTROLYZER : [TERRAIN.SEA],
	BUILDING.ELECTRONICS_FACTORY : [TERRAIN.SEA],
	BUILDING.CIVILIAN_FACTORY : [TERRAIN.SEA]
}

var description = {
	BUILDING.CENTER : "The administrative heart of the colony.",
	BUILDING.CITY : "A sprawling district of high-rising residences.",
	BUILDING.ROAD : "Roads that extend the colony's reach into undeveloped terrain.",
	BUILDING.SPACEPORT : "A spaceport that connects the colony to wider trade networks.",
	BUILDING.SOLAR_FARM : "A sprawling complex of solar panels that harvest solar energy.",
	BUILDING.NUCLEAR_PLANT : "A fission power plant that uses Uranium as fuel.",
	BUILDING.FUSION_PLANT : "A fusion power plant that uses Hydrogen as fuel.",
	BUILDING.MINE : "A mining complex that extracts materials from the tile below. Produces 2 resources of the tile it is placed upon.",
	BUILDING.ICE_MINE : "A mining complex specializing in Ice. Produces 2 Ice from Ice-based tiles.",
	BUILDING.QUARRY : "A mining complex that extracts silicate from the regolith.",
	BUILDING.STEEL_MILL : "A mill that produces Steel from Iron and Carbon.",
	BUILDING.CONCRETE_PLANT : "A plant that produces Concrete from Steel and Silicate.",
	BUILDING.BRASS_MILL : "A mill that produces Brass from Copper and Zinc.",
	BUILDING.PLASTIC_REFINERY : "A refinery that produces Plastic from Carbon and Water.",
	BUILDING.FERTILIZER_FACTORY : "A factory that produces Fertilizer from Phosphorus and Nitrogen.",
	BUILDING.YEAST_VATS : "Vats of cultivated yeast cultures that provide a basic nutritional supplement.",
	BUILDING.FARM : "A pressurized greenhouse that cultivates crops in a controlled environment.",
	BUILDING.WATER_EXTRACTOR : "A plant of furnace-extractors that melt Ice into liquid Water.",
	BUILDING.ELECTROLYZER : "A plant that electrolyzes Water into Oxygen and Hydrogen",
	BUILDING.ELECTRONICS_FACTORY : "A factory that assembles Electronics from Brass, Lithium and Gold.",
	BUILDING.CIVILIAN_FACTORY : "A factory that assembles Civilian Goods from Plastic and Electronics.",
	BUILDING.EMPTY : "An empty tile."
}

var buildingInfluence = {
	BUILDING.CENTER : 500,
	BUILDING.CITY : 100,
	BUILDING.SPACEPORT : 500,
	BUILDING.CIVILIAN_FACTORY : 500
}

var specialAdjacencyText = {
	BUILDING.SOLAR_FARM : ("[font_size=32][color=#000099ff]50[/color][/font_size][img]"+resIcons[RESOURCE.INDUSTRY]+
	"[/img]\nper adjacent [color=#ffff00ff]Energy[/color] producing building."),
	BUILDING.NUCLEAR_PLANT : ("[font_size=32][color=#000099ff]100[/color][/font_size][img]"+resIcons[RESOURCE.INDUSTRY]+
	"[/img]\nper adjacent [color=#ffff00ff]Energy[/color] producing building."),
	BUILDING.FUSION_PLANT : ("[font_size=32][color=#000099ff]250[/color][/font_size][img]"+resIcons[RESOURCE.INDUSTRY]+
	"[/img]\nper adjacent [color=#ffff00ff]Energy[/color] producing building."),
	BUILDING.SPACEPORT : ("[font_size=32][color=#000099ff]100[/color][img]"+resIcons[RESOURCE.WEALTH]+
			"[/img], [color=#000099ff]100[/color][img]"+resIcons[RESOURCE.INFLUENCE]+"[/img][/font_size]\nper adjacent Spaceport"),
	BUILDING.CITY : ("[font_size=32][color=#000099ff]100[/color][/font_size][img]"+resIcons[RESOURCE.INFLUENCE]+"[/img]\nper adjacent City")
}

var specialAdjacency = {
	BUILDING.CITY : {BUILDING.CITY: {RESOURCE.INFLUENCE: 100}},
	BUILDING.SOLAR_FARM : {BUILDING.SOLAR_FARM: {RESOURCE.INDUSTRY: 50},
			BUILDING.NUCLEAR_PLANT: {RESOURCE.INDUSTRY: 50}, BUILDING.FUSION_PLANT: {RESOURCE.INDUSTRY: 50}},
	BUILDING.NUCLEAR_PLANT : {BUILDING.SOLAR_FARM: {RESOURCE.INDUSTRY: 100},
			BUILDING.NUCLEAR_PLANT: {RESOURCE.INDUSTRY: 100}, BUILDING.FUSION_PLANT: {RESOURCE.INDUSTRY: 100}},
	BUILDING.FUSION_PLANT : {BUILDING.SOLAR_FARM: {RESOURCE.INDUSTRY: 250},
			BUILDING.NUCLEAR_PLANT: {RESOURCE.INDUSTRY: 250}, BUILDING.FUSION_PLANT: {RESOURCE.INDUSTRY: 250}},
	BUILDING.SPACEPORT : {BUILDING.SPACEPORT: {RESOURCE.WEALTH: 100, RESOURCE.INFLUENCE: 100}}
}

var buildingIndustry = {
	#BUILDING.SOLAR_FARM : 50,
	#BUILDING.NUCLEAR_PLANT : 100,
	#BUILDING.FUSION_PLANT : 250,
	BUILDING.MINE : 50,
	BUILDING.QUARRY : 50,
	BUILDING.ICE_MINE : 50,
	BUILDING.STEEL_MILL : 100,
	BUILDING.CONCRETE_PLANT : 100,
	BUILDING.BRASS_MILL : 100,
	BUILDING.PLASTIC_REFINERY : 100,
	BUILDING.FERTILIZER_FACTORY : 100,
	#BUILDING.YEAST_VATS : 50,
	#BUILDING.FARM : 100,
	BUILDING.WATER_EXTRACTOR : 50,
	BUILDING.ELECTROLYZER : 100,
	BUILDING.ELECTRONICS_FACTORY : 250,
	BUILDING.CIVILIAN_FACTORY : 500
}
