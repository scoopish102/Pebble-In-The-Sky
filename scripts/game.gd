extends Node

class_name Game

#This script is a game manager. This means this script handles the compiling of resources,
#the creation and handling of in-game events, and much more.

@export var map : Map
@export var camera : Camera2D
@export var ui : Control
@export var cursor : Cursor
var loaded = false

func _ready():
	loaded = false
	Event.update_resources.connect(updateBudgets)
	Event.next_turn.connect(nextTurn)
	Event.demolish_building.connect(demolishAtCursor)
	Event.trade_order.connect(tradeOrder)
	Event.cancel_trade.connect(cancelTrade)
	ui.fetchSelectedTile.connect(sendSelectedTile)
	Event.achieve.connect(achieve)

func achieve(achievement: Global.ACHIEVEMENTS): 
	if achievement in Global.achievementsRecord: return
	else: Global.achievementsRecord[achievement] = int(Global.turn)

func tradeOrder(resource, quantity):
	Global.trades[resource] += quantity
	Event.update_resources.emit()

func cancelTrade(resource):
	Global.trades[resource] = 0
	Event.update_resources.emit()

func demolishAtCursor():
	map.demolish(cursor.tile)

func _process(_delta):
	if loaded == true: cursor.update(ui.minimap)

func sendSelectedTile():
	if cursor.tile == Vector2i(-1, -1): return
	var terrain = map.terrainMap[cursor.tile]
	var neighbors = map.getNeighborCount(cursor.tile)
	var building = false
	if cursor.tile in map.buildingMap: building = map.buildingMap[cursor.tile]
	var activated = false
	if cursor.tile in map.activationMap: activated = map.activationMap[cursor.tile]
	ui.setSelectedTile(neighbors, terrain, building, activated)

func startingResources():
	Global.reserves[Global.RESOURCE.CONCRETE] = 64
	Global.reserves[Global.RESOURCE.STEEL] = 32
	Global.reserves[Global.RESOURCE.FOOD] = 4
	Global.reserves[Global.RESOURCE.OXYGEN] = 4
	Global.reserves[Global.RESOURCE.WATER] = 4
	Global.reserves[Global.RESOURCE.MONEY] = 64
	Global.reserves[Global.RESOURCE.TRADE] = 3

func initResources():
	for resource in Global.RESOURCE.values():
		Global.reserves[resource] = 0
		Global.budgets[resource] = 0
	for resource in Global.resourcePrices.keys():
		Global.trades[resource] = 0

func resetBudgets():
	for resource in Global.RESOURCE.values():
		Global.budgets[resource] = 0

func nextTurn():
	updateBudgets()
	checkForStatAchievements()
	Global.turn += 1
	updateReserves()

func updateBudgets():
	resetBudgets()
	var budgetChange = Global.budgets.duplicate()
	for building in map.buildingMap:
		#print(building)
		if not map.activationMap[building]: continue
		if map.buildingMap[building] in Global.buildingIndustry:
			budgetChange[Global.RESOURCE.INDUSTRY] += Global.buildingIndustry[map.buildingMap[building]]
			for adj in map.getNeighborTypes(building):
				if adj in Global.buildingIndustry: 
					budgetChange[Global.RESOURCE.INDUSTRY] += Global.buildingIndustry[map.buildingMap[building]]/2
		if map.buildingMap[building] in Global.buildingInfluence:
			budgetChange[Global.RESOURCE.INFLUENCE] += Global.buildingInfluence[map.buildingMap[building]]
		if map.buildingMap[building] in Global.specialAdjacency:
			var spec = Global.specialAdjacency[map.buildingMap[building]]
			for b in spec.keys():
				for n in map.getNeighborsOfType(building, b):
					for sr in spec[b]: budgetChange[sr] += spec[b][sr]
		if not map.buildingMap[building] in Global.buildingBudgets: continue
		var buildingBudget = Global.buildingBudgets[map.buildingMap[building]]
		for resource in buildingBudget.keys():
			if not resource is int and resource == &"DEPOSIT":
				if map.terrainMap[building] in Global.depositToResource:
					#print(map.buildingMap[building])
					budgetChange[Global.depositToResource[map.terrainMap[building]]] += buildingBudget[resource]
			else: budgetChange[resource] += buildingBudget[resource]
	Global.reserves[Global.RESOURCE.TRADE] = Global.budgets[Global.RESOURCE.TRADE]
	for resource in Global.trades:
		budgetChange[resource] += Global.trades[resource]
		budgetChange[Global.RESOURCE.MONEY] -= Global.trades[resource]*Global.resourcePrices[resource]
		budgetChange[Global.RESOURCE.TRADE] -= abs(Global.trades[resource])
		budgetChange[Global.RESOURCE.WEALTH] += abs(Global.trades[resource]) * 500
		#if resource == Global.RESOURCE.GOLD: print(budgetChange[Global.RESOURCE.MONEY])
	budgetChange[Global.RESOURCE.WEALTH] += int(budgetChange[Global.RESOURCE.MONEY] * 10) + Global.reserves[Global.RESOURCE.MONEY] * 10
	for resource in Global.budgets:
		#if resource == Global.RESOURCE.TRADE: print(Global.budgets[Global.RESOURCE.TRADE])
		Global.budgets[resource] += budgetChange[resource]
	if fmod(Global.budgets[Global.RESOURCE.MONEY], 1) < 0.1: Global.budgets[Global.RESOURCE.MONEY] = int(Global.budgets[Global.RESOURCE.MONEY])
	Event.update_confirmation.emit()

func checkForStatAchievements():
	if Global.budgets[Global.RESOURCE.WEALTH] >= 1000: achieve(Global.ACHIEVEMENTS.wealth1k)
	if Global.budgets[Global.RESOURCE.WEALTH] >= 2000: achieve(Global.ACHIEVEMENTS.wealth2k)
	if Global.budgets[Global.RESOURCE.WEALTH] >= 3000: achieve(Global.ACHIEVEMENTS.wealth3k)
	if Global.budgets[Global.RESOURCE.WEALTH] >= 4000: achieve(Global.ACHIEVEMENTS.wealth4k)
	if Global.budgets[Global.RESOURCE.WEALTH] >= 5000: achieve(Global.ACHIEVEMENTS.wealth5k)
	if Global.budgets[Global.RESOURCE.WEALTH] >= 6000: achieve(Global.ACHIEVEMENTS.wealth6k)
	if Global.budgets[Global.RESOURCE.WEALTH] >= 7000: achieve(Global.ACHIEVEMENTS.wealth7k)
	if Global.budgets[Global.RESOURCE.WEALTH] >= 8000: achieve(Global.ACHIEVEMENTS.wealth8k)
	if Global.budgets[Global.RESOURCE.WEALTH] >= 9000: achieve(Global.ACHIEVEMENTS.wealth9k)
	if Global.budgets[Global.RESOURCE.WEALTH] >= 10000: achieve(Global.ACHIEVEMENTS.wealth10k)
	if Global.budgets[Global.RESOURCE.WEALTH] >= 15000: achieve(Global.ACHIEVEMENTS.wealth15k)
	if Global.budgets[Global.RESOURCE.WEALTH] >= 20000: achieve(Global.ACHIEVEMENTS.wealth20k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 1000: achieve(Global.ACHIEVEMENTS.ind1k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 2000: achieve(Global.ACHIEVEMENTS.ind2k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 3000: achieve(Global.ACHIEVEMENTS.ind3k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 4000: achieve(Global.ACHIEVEMENTS.ind4k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 5000: achieve(Global.ACHIEVEMENTS.ind5k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 6000: achieve(Global.ACHIEVEMENTS.ind6k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 7000: achieve(Global.ACHIEVEMENTS.ind7k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 8000: achieve(Global.ACHIEVEMENTS.ind8k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 9000: achieve(Global.ACHIEVEMENTS.ind9k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 10000: achieve(Global.ACHIEVEMENTS.ind10k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 15000: achieve(Global.ACHIEVEMENTS.ind15k)
	if Global.budgets[Global.RESOURCE.INDUSTRY] >= 20000: achieve(Global.ACHIEVEMENTS.ind20k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 1000: achieve(Global.ACHIEVEMENTS.inf1k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 2000: achieve(Global.ACHIEVEMENTS.inf2k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 3000: achieve(Global.ACHIEVEMENTS.inf3k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 4000: achieve(Global.ACHIEVEMENTS.inf4k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 5000: achieve(Global.ACHIEVEMENTS.inf5k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 6000: achieve(Global.ACHIEVEMENTS.inf6k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 7000: achieve(Global.ACHIEVEMENTS.inf7k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 8000: achieve(Global.ACHIEVEMENTS.inf8k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 9000: achieve(Global.ACHIEVEMENTS.inf9k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 10000: achieve(Global.ACHIEVEMENTS.inf10k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 15000: achieve(Global.ACHIEVEMENTS.inf15k)
	if Global.budgets[Global.RESOURCE.INFLUENCE] >= 20000: achieve(Global.ACHIEVEMENTS.inf20k)
	if Global.score >= 10000: achieve(Global.ACHIEVEMENTS.score10k)
	if Global.score >= 20000: achieve(Global.ACHIEVEMENTS.score20k)
	if Global.score >= 30000: achieve(Global.ACHIEVEMENTS.score30k)
	if Global.score >= 40000: achieve(Global.ACHIEVEMENTS.score40k)
	if Global.score >= 50000: achieve(Global.ACHIEVEMENTS.score50k)
	if Global.score >= 60000: achieve(Global.ACHIEVEMENTS.score60k)
	if Global.score >= 70000: achieve(Global.ACHIEVEMENTS.score70k)
	if Global.score >= 80000: achieve(Global.ACHIEVEMENTS.score80k)
	if Global.score >= 90000: achieve(Global.ACHIEVEMENTS.score90k)
	if Global.score >= 100000: achieve(Global.ACHIEVEMENTS.score100k)
	if Global.buildingCount > 10: achieve(Global.ACHIEVEMENTS.build10)
	if Global.buildingCount > 20: achieve(Global.ACHIEVEMENTS.build20)
	if Global.buildingCount > 30: achieve(Global.ACHIEVEMENTS.build30)
	if Global.buildingCount > 40: achieve(Global.ACHIEVEMENTS.build40)
	if Global.buildingCount > 50: achieve(Global.ACHIEVEMENTS.build50)
	if Global.buildingCount > 60: achieve(Global.ACHIEVEMENTS.build60)
	if Global.buildingCount > 70: achieve(Global.ACHIEVEMENTS.build70)
	if Global.buildingCount > 80: achieve(Global.ACHIEVEMENTS.build80)
	if Global.buildingCount > 90: achieve(Global.ACHIEVEMENTS.build90)
	if Global.buildingCount > 100: achieve(Global.ACHIEVEMENTS.build100)
	if Global.buildingCount > Global.mapSize.x*Global.mapSize.y*0.8: achieve(Global.ACHIEVEMENTS.ecumenopolis)
	if Global.cityCount > 5: achieve(Global.ACHIEVEMENTS.pop5)
	if Global.cityCount > 10: achieve(Global.ACHIEVEMENTS.pop10)
	if Global.cityCount > 15: achieve(Global.ACHIEVEMENTS.pop15)
	if Global.cityCount > 20: achieve(Global.ACHIEVEMENTS.pop20)
	if Global.cityCount > 25: achieve(Global.ACHIEVEMENTS.pop25)
	if Global.cityCount > 30: achieve(Global.ACHIEVEMENTS.pop30)
	if Global.cityCount > 35: achieve(Global.ACHIEVEMENTS.pop35)
	if Global.cityCount > 40: achieve(Global.ACHIEVEMENTS.pop40)
	if Global.cityCount > 45: achieve(Global.ACHIEVEMENTS.pop45)
	if Global.cityCount > 50: achieve(Global.ACHIEVEMENTS.pop50)
	if Global.mineCount > 5: achieve(Global.ACHIEVEMENTS.mine5)
	if Global.mineCount > 10: achieve(Global.ACHIEVEMENTS.mine10)
	if Global.mineCount > 20: achieve(Global.ACHIEVEMENTS.mine20)
	if Global.mineCount > 50: achieve(Global.ACHIEVEMENTS.mine50)

func updateReserves():
	for resource in Global.RESOURCE.values():
		if resource in [Global.RESOURCE.TRADE]: continue
		Global.reserves[resource] += Global.budgets[resource]
	Global.score += Global.budgets[Global.RESOURCE.WEALTH] / 100
	Global.score += Global.budgets[Global.RESOURCE.INDUSTRY] / 100
	Global.score += Global.budgets[Global.RESOURCE.INFLUENCE] / 100
	Event.update_confirmation.emit()
