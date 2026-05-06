extends Node

var tileSize = Vector2i(128, 64)
var mapSize = Vector2i(25, 25)
var height = 8
var seaLevel = 0

var selectedTile = Vector2i(0, 0)
var selected = false

var reserves = {}
var budgets = {}

var turn = 0

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
	RESOURCE.CIVGOODS: &"res://resources/resIcons/civgoods.tres"
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
	FERTILIZER, FOOD, ELECTRONICS, CIVGOODS
}

var resourceCategoriesLR = [
	"Basic", "Common Metals", "Rare Metals",
	"Minerals", "Materials", "Liquids and Gasses",
	"Products"
]

var resourceCategories = {
	"Basic" : [RESOURCE.MONEY, RESOURCE.ENERGY, RESOURCE.LABOR],
	"Common Metals" : [RESOURCE.IRON, RESOURCE.COPPER, RESOURCE.ZINC], #reminder: add aluminum when implemented
	"Rare Metals" : [RESOURCE.GOLD, RESOURCE.URANIUM, RESOURCE.LITHIUM],
	"Minerals" : [RESOURCE.ICE, RESOURCE.SILICATE, RESOURCE.CARBON, RESOURCE.PHOSPHORUS],
	"Materials" : [RESOURCE.STEEL, RESOURCE.BRASS, RESOURCE.CONCRETE, RESOURCE.PLASTIC],
	"Liquids and Gasses" : [RESOURCE.WATER, RESOURCE.OXYGEN, RESOURCE.HYDROGEN, RESOURCE.NITROGEN],
	"Products" : [RESOURCE.FERTILIZER, RESOURCE.FOOD, RESOURCE.ELECTRONICS, RESOURCE.CIVGOODS]
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
	MINE,
	QUARRY,
	STEEL_MILL,
	CONCRETE_PLANT,
	REGOLITH_PROCESSOR,
	WATER_EXTRACTOR,
	EMPTY
}

var buildingNames = {
	BUILDING.CENTER : &"Colony Center",
	BUILDING.CITY : &"City",
	BUILDING.ROAD : &"Road",
	BUILDING.SOLAR_FARM : &"Solar Farm",
	BUILDING.NUCLEAR_PLANT : &"Nuclear Plant",
	BUILDING.MINE : &"Mine",
	BUILDING.QUARRY : &"Quarry",
	BUILDING.STEEL_MILL : &"Steel Mill",
	BUILDING.CONCRETE_PLANT : &"Concrete Plant",
	BUILDING.REGOLITH_PROCESSOR : &"Regolith Processor",
	BUILDING.WATER_EXTRACTOR : &"Water Extraction Plant",
	BUILDING.EMPTY : &"No Building"
}

var buildingBudgets = {
	BUILDING.CENTER : {RESOURCE.LABOR : 3, RESOURCE.MONEY : 3, RESOURCE.ENERGY : 3, RESOURCE.FOOD : 2, RESOURCE.CONCRETE : 2, RESOURCE.STEEL : 2, RESOURCE.WATER : 2, RESOURCE.OXYGEN : 2, &"DEPOSIT" : 1},
	BUILDING.CITY : {RESOURCE.LABOR : 3, RESOURCE.ENERGY : -1, RESOURCE.FOOD : -1, RESOURCE.OXYGEN : -1, RESOURCE.WATER : -1},
	BUILDING.SOLAR_FARM : {RESOURCE.MONEY : -3, RESOURCE.ENERGY : 2},
	BUILDING.NUCLEAR_PLANT : {RESOURCE.LABOR : -1, RESOURCE.ENERGY : 4, RESOURCE.URANIUM : -1},
	BUILDING.MINE : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, &"DEPOSIT" : 2},
	BUILDING.QUARRY : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.SILICATE : 2},
	BUILDING.STEEL_MILL : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.IRON : -4, RESOURCE.CARBON: -2, RESOURCE.STEEL : 4},
	BUILDING.CONCRETE_PLANT : {RESOURCE.MONEY : -1, RESOURCE.LABOR : -1, RESOURCE.ENERGY : -1, RESOURCE.SILICATE : -4, RESOURCE.STEEL: -1, RESOURCE.CONCRETE : 4},
	BUILDING.REGOLITH_PROCESSOR : {RESOURCE.ENERGY : -2, RESOURCE.SILICATE : -2, RESOURCE.OXYGEN : 2, RESOURCE.HYDROGEN : 1},
	BUILDING.WATER_EXTRACTOR : {RESOURCE.ENERGY : -2, RESOURCE.ICE : -2, RESOURCE.WATER : 2}
}

var buildingCosts = {
	BUILDING.CITY : {RESOURCE.MONEY : 8, RESOURCE.CONCRETE : 16, RESOURCE.STEEL : 4},
	BUILDING.ROAD : {RESOURCE.MONEY : 2, RESOURCE.CONCRETE : 2},
	BUILDING.SOLAR_FARM : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 8, RESOURCE.STEEL : 16},
	BUILDING.NUCLEAR_PLANT : {RESOURCE.MONEY : 8, RESOURCE.CONCRETE: 16, RESOURCE.STEEL : 8},
	BUILDING.MINE : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 8, RESOURCE.STEEL : 4},
	BUILDING.QUARRY : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 8, RESOURCE.STEEL : 4},
	BUILDING.STEEL_MILL : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 8, RESOURCE.STEEL : 4},
	BUILDING.CONCRETE_PLANT : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 8, RESOURCE.STEEL : 4},
	BUILDING.REGOLITH_PROCESSOR : {RESOURCE.MONEY : 8, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 8},
	BUILDING.WATER_EXTRACTOR : {RESOURCE.MONEY : 8, RESOURCE.CONCRETE : 4, RESOURCE.STEEL : 8}
}

var buildingBannedTerrains = {
	BUILDING.CITY : [TERRAIN.SEA],
	BUILDING.ROAD : [TERRAIN.SEA],
	BUILDING.SOLAR_FARM : [TERRAIN.SEA],
	BUILDING.NUCLEAR_PLANT : [TERRAIN.SEA],
	BUILDING.MINE : [TERRAIN.PLAIN, TERRAIN.SEA],
	BUILDING.QUARRY : [TERRAIN.SEA],
	BUILDING.STEEL_MILL : [TERRAIN.SEA],
	BUILDING.CONCRETE_PLANT : [TERRAIN.SEA],
	BUILDING.REGOLITH_PROCESSOR : [TERRAIN.SEA],
	BUILDING.WATER_EXTRACTOR : [TERRAIN.SEA]
}

var description = {
	BUILDING.CENTER : "The administrative heart of the colony.",
	BUILDING.CITY : "A sprawling district of high-rising residences.",
	BUILDING.ROAD : "Roads that extend the colony's reach into undeveloped terrain.",
	BUILDING.SOLAR_FARM : "A sprawling complex of solar panels that harvest solar energy.",
	BUILDING.NUCLEAR_PLANT : "A fission power plant that uses Uranium as fuel.",
	BUILDING.MINE : "A mining complex that extracts materials from the tile below.",
	BUILDING.QUARRY : "A mining complex that extracts silicate from the regolith.",
	BUILDING.STEEL_MILL : "A mill that produces Steel from Iron and Carbon.",
	BUILDING.CONCRETE_PLANT : "A plant that produces Concrete from Steel and Silicate.",
	BUILDING.REGOLITH_PROCESSOR : "Processors that electrolyze Silicate into Oxygen and Hydrogen.",
	BUILDING.WATER_EXTRACTOR : "A plant full of extractors that melt Ice into liquid Water.",
	BUILDING.EMPTY : "An empty tile."
}
