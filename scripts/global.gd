extends Node

var tileSize = Vector2i(128, 64)
var mapSize = Vector2i(50, 50)
var height = 8
var seaLevel = 0

var selectedTile = Vector2i(0, 0)
var selected = false

var reserves = {}
var budgets = {}

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
	"Common Metals" : [RESOURCE.IRON, RESOURCE.COPPER, RESOURCE.ZINC],
	"Rare Metals" : [RESOURCE.GOLD, RESOURCE.URANIUM, RESOURCE.LITHIUM],
	"Minerals" : [RESOURCE.ICE, RESOURCE.SILICATE, RESOURCE.CARBON, RESOURCE.PHOSPHORUS],
	"Materials" : [RESOURCE.STEEL, RESOURCE.BRASS, RESOURCE.CONCRETE, RESOURCE.PLASTIC],
	"Liquids and Gasses" : [RESOURCE.WATER, RESOURCE.OXYGEN, RESOURCE.HYDROGEN, RESOURCE.NITROGEN],
	"Products" : [RESOURCE.FERTILIZER, RESOURCE.FOOD, RESOURCE.ELECTRONICS, RESOURCE.CIVGOODS]
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
	FACTORY,
	EMPTY
}

var buildingBudgets = {
	BUILDING.CENTER : {RESOURCE.LABOR : 3, RESOURCE.MONEY : 3, RESOURCE.ENERGY : 3, RESOURCE.FOOD : 2, RESOURCE.CONCRETE : 2, RESOURCE.STEEL : 2, RESOURCE.WATER : 2, RESOURCE.OXYGEN : 2},
	BUILDING.CITY : {RESOURCE.LABOR : 3, RESOURCE.ENERGY : -1, RESOURCE.FOOD : -1},
	BUILDING.FACTORY : {RESOURCE.LABOR : -1, RESOURCE.ENERGY : -2}
}

var buildingCosts = {
	BUILDING.CITY : {RESOURCE.MONEY : 8, RESOURCE.CONCRETE : 16, RESOURCE.STEEL : 4},
	BUILDING.FACTORY : {RESOURCE.MONEY : 4, RESOURCE.CONCRETE : 8, RESOURCE.STEEL : 4}
}

var description = {
	BUILDING.CENTER : "The administrative heart of the colony.",
	BUILDING.CITY : "A sprawling district of high-rising residences.",
	BUILDING.FACTORY : "A factory that mass produces valuable commodities.",
	BUILDING.EMPTY : "There's no building here."
}
