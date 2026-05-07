extends Node

var tileSize = Vector2i(128, 64)
var mapSize = Vector2i(48, 24)
var height = 8
var seaLevel = 0

var selectedTile = Vector2i(0, 0)
var selected = false

var reserves = {} #amount of a resource stored up
var budgets = {} #amount of a resource produced/spent each turn
var trades = {} #balance of a resource beinging bought/sold

var turn = 0

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
	RESOURCE.CARBON: 0.5,
	RESOURCE.PHOSPHORUS: 2,
	RESOURCE.STEEL: 2,
	RESOURCE.BRASS: 2,
	RESOURCE.CONCRETE: 1,
	RESOURCE.PLASTIC: 2,
	RESOURCE.WATER: 1,
	RESOURCE.OXYGEN: 1,
	RESOURCE.HYDROGEN: 1,
	RESOURCE.NITROGEN: 1,
	RESOURCE.FERTILIZER: 2,
	RESOURCE.FOOD: 2,
	RESOURCE.ELECTRONICS: 3,
	RESOURCE.CIVGOODS: 5
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
	RESOURCE.WEALTH: "The strength of the colony's economy.",
	RESOURCE.INDUSTRY: "The industrial complexity of the colony.",
	RESOURCE.INFLUENCE: "The colony's diplomatic and cultural strength.",
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
	"Basic" : [RESOURCE.MONEY, RESOURCE.ENERGY, RESOURCE.LABOR],
	"Common Metals" : [RESOURCE.IRON, RESOURCE.COPPER, RESOURCE.ZINC, RESOURCE.ALUMINUM], 
	"Rare Metals" : [RESOURCE.GOLD, RESOURCE.URANIUM, RESOURCE.LITHIUM],
	"Minerals" : [RESOURCE.ICE, RESOURCE.SILICATE, RESOURCE.CARBON, RESOURCE.PHOSPHORUS],
	"Materials" : [RESOURCE.STEEL, RESOURCE.BRASS, RESOURCE.CONCRETE, RESOURCE.PLASTIC],
	"Liquids and Gasses" : [RESOURCE.WATER, RESOURCE.OXYGEN, RESOURCE.HYDROGEN, RESOURCE.NITROGEN],
	"Products" : [RESOURCE.FERTILIZER, RESOURCE.FOOD, RESOURCE.ELECTRONICS, RESOURCE.CIVGOODS],
	"Statistics" : [RESOURCE.TRADE, RESOURCE.WEALTH, RESOURCE.INDUSTRY, RESOURCE.INFLUENCE, RESOURCE.SCORE]
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
	CENTER,
	CITY,
	ROAD,
	SOLAR_FARM,
	NUCLEAR_PLANT,
	FUSION_PLANT,
	MINE,
	QUARRY,
	ICE_MINE,
	STEEL_MILL,
	CONCRETE_PLANT,
	REGOLITH_PROCESSOR,
	WATER_EXTRACTOR,
	ELECTROLYZER,
	EMPTY
}

var buildingNames = {
	BUILDING.CENTER : &"Colony Center",
	BUILDING.CITY : &"City",
	BUILDING.ROAD : &"Road",
	BUILDING.SOLAR_FARM : &"Solar Farm",
	BUILDING.NUCLEAR_PLANT : &"Nuclear Plant",
	BUILDING.FUSION_PLANT : &"Fusion Plant",
	BUILDING.MINE : &"Mine",
	BUILDING.QUARRY : &"Quarry",
	BUILDING.ICE_MINE : &"Ice Mine",
	BUILDING.STEEL_MILL : &"Steel Mill",
	BUILDING.CONCRETE_PLANT : &"Concrete Plant",
	BUILDING.REGOLITH_PROCESSOR : &"Regolith Processor",
	BUILDING.WATER_EXTRACTOR : &"Water Extractors",
	BUILDING.ELECTROLYZER : &"Electrolyzer Plant",
	BUILDING.EMPTY : &"No Building"
}

var buildingBudgets = {
	BUILDING.CENTER : {RESOURCE.LABOR : 3, RESOURCE.MONEY : 3, RESOURCE.ENERGY : 3, RESOURCE.FOOD : 2, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 2, RESOURCE.WATER : 2, RESOURCE.OXYGEN : 2, &"DEPOSIT" : 1},
	BUILDING.CITY : {RESOURCE.LABOR : 3, RESOURCE.ENERGY : -1, RESOURCE.FOOD : -1, RESOURCE.OXYGEN : -1, RESOURCE.WATER : -1},
	BUILDING.SOLAR_FARM : {RESOURCE.MONEY : -1, RESOURCE.ENERGY : 2},
	BUILDING.NUCLEAR_PLANT : {RESOURCE.LABOR : -1, RESOURCE.ENERGY : 4, RESOURCE.URANIUM : -1},
	BUILDING.FUSION_PLANT : {RESOURCE.LABOR : -1, RESOURCE.ENERGY : 8, RESOURCE.HYDROGEN : -4},
	BUILDING.MINE : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, &"DEPOSIT" : 2},
	BUILDING.ICE_MINE : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.ICE : 2},
	BUILDING.QUARRY : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.SILICATE : 2},
	BUILDING.STEEL_MILL : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.IRON : -4, RESOURCE.CARBON: -2, RESOURCE.STEEL : 4},
	BUILDING.CONCRETE_PLANT : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.SILICATE : -4, RESOURCE.STEEL: -1, RESOURCE.CONCRETE : 6},
	BUILDING.REGOLITH_PROCESSOR : {RESOURCE.ENERGY : -2, RESOURCE.SILICATE : -2, RESOURCE.OXYGEN : 2, RESOURCE.HYDROGEN : 1},
	BUILDING.WATER_EXTRACTOR : {RESOURCE.ENERGY : -1, RESOURCE.ICE : -2, RESOURCE.WATER : 2},
	BUILDING.ELECTROLYZER : {RESOURCE.ENERGY : -2, RESOURCE.WATER : -2, RESOURCE.OXYGEN : 2, RESOURCE.HYDROGEN : 1} #H₂O splits into 2H and O, but by volume oxygen is the larger output
}

var buildingCosts = {
	BUILDING.CITY : {RESOURCE.MONEY : 8, RESOURCE.CONCRETE : 8, RESOURCE.STEEL : 4},
	BUILDING.ROAD : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 2},
	BUILDING.SOLAR_FARM : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 4},
	BUILDING.NUCLEAR_PLANT : {RESOURCE.MONEY : 8, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 4},
	BUILDING.FUSION_PLANT : {RESOURCE.MONEY : 16, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 8},
	BUILDING.MINE : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 2},
	BUILDING.ICE_MINE : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 2},
	BUILDING.QUARRY : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 2},
	BUILDING.STEEL_MILL : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 4},
	BUILDING.CONCRETE_PLANT : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 4},
	BUILDING.REGOLITH_PROCESSOR : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 8},
	BUILDING.WATER_EXTRACTOR : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 4, RESOURCE.STEEL :4},
	BUILDING.ELECTROLYZER : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 8}
}

var buildingBannedTerrains = {
	BUILDING.CITY : [TERRAIN.SEA],
	BUILDING.ROAD : [TERRAIN.SEA],
	BUILDING.SOLAR_FARM : [TERRAIN.SEA],
	BUILDING.NUCLEAR_PLANT : [TERRAIN.SEA],
	BUILDING.FUSION_PLANT : [TERRAIN.SEA],
	BUILDING.MINE : [TERRAIN.PLAIN, TERRAIN.SEA],
	BUILDING.ICE_MINE : [TERRAIN.PLAIN, TERRAIN.SEA, TERRAIN.IRON, TERRAIN.COPPER, TERRAIN.ZINC, TERRAIN.GOLD, TERRAIN.URANIUM, TERRAIN.LITHIUM, TERRAIN.CARBON],
	BUILDING.QUARRY : [TERRAIN.SEA],
	BUILDING.STEEL_MILL : [TERRAIN.SEA],
	BUILDING.CONCRETE_PLANT : [TERRAIN.SEA],
	BUILDING.REGOLITH_PROCESSOR : [TERRAIN.SEA],
	BUILDING.WATER_EXTRACTOR : [TERRAIN.SEA],
	BUILDING.ELECTROLYZER : [TERRAIN.SEA]
}

var description = {
	BUILDING.CENTER : "The administrative heart of the colony.",
	BUILDING.CITY : "A sprawling district of high-rising residences.",
	BUILDING.ROAD : "Roads that extend the colony's reach into undeveloped terrain.",
	BUILDING.SOLAR_FARM : "A sprawling complex of solar panels that harvest solar energy.",
	BUILDING.NUCLEAR_PLANT : "A fission power plant that uses Uranium as fuel.",
	BUILDING.FUSION_PLANT : "A fusion power plant that uses Hydrogen as fuel.",
	BUILDING.MINE : "A mining complex that extracts materials from the tile below. Produces 2 resources of the tile it is placed upon.",
	BUILDING.ICE_MINE : "A mining complex specializing in Ice. Produces 2 Ice from Ice-based tiles.",
	BUILDING.QUARRY : "A mining complex that extracts silicate from the regolith.",
	BUILDING.STEEL_MILL : "A mill that produces Steel from Iron and Carbon.",
	BUILDING.CONCRETE_PLANT : "A plant that produces Concrete from Steel and Silicate.",
	BUILDING.REGOLITH_PROCESSOR : "Processors that electrolyze Silicate into Oxygen and Hydrogen.",
	BUILDING.WATER_EXTRACTOR : "A plant of furnace-extractors that melt Ice into liquid Water.",
	BUILDING.ELECTROLYZER : "A plant that electrolyzes Water into Oxygen and Hydrogen",
	BUILDING.EMPTY : "An empty tile."
}
