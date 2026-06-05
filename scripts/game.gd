extends Node

class_name Game

#This script is a game manager. This means this script handles the compiling of resources,
#the creation and handling of in-game events, and much more.

@export var map : Map
@export var camera : Camera2D
@export var ui : Control
@export var cursor : Cursor

func _ready():
	Event.update_resources.connect(updateBudgets)
	Event.next_turn.connect(nextTurn)
	Event.demolish_building.connect(demolishAtCursor)
	Event.trade_order.connect(tradeOrder)
	Event.cancel_trade.connect(cancelTrade)
	ui.fetchSelectedTile.connect(sendSelectedTile)

func tradeOrder(resource, quantity):
	Global.trades[resource] += quantity
	Event.update_resources.emit()

func cancelTrade(resource):
	Global.trades[resource] = 0
	Event.update_resources.emit()

func demolishAtCursor():
	map.demolish(cursor.tile)

func _process(_delta):
	cursor.update(ui.minimap)

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
	Global.turn += 1
	updateBudgets()
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
		for resource in buildingBudget:
			if not resource is int and resource == &"DEPOSIT":
				if map.terrainMap[building] in Global.depositToResource:
					budgetChange[Global.depositToResource[map.terrainMap[building]]] += buildingBudget[resource]
			else: budgetChange[resource] += buildingBudget[resource]
	Global.reserves[Global.RESOURCE.TRADE] = Global.budgets[Global.RESOURCE.TRADE]
	for resource in Global.trades:
		budgetChange[resource] += Global.trades[resource]
		budgetChange[Global.RESOURCE.MONEY] -= Global.trades[resource]*Global.resourcePrices[resource]
		budgetChange[Global.RESOURCE.TRADE] -= abs(Global.trades[resource])
		budgetChange[Global.RESOURCE.WEALTH] += abs(Global.trades[resource]) * 200
		#if resource == Global.RESOURCE.GOLD: print(budgetChange[Global.RESOURCE.MONEY])
	budgetChange[Global.RESOURCE.WEALTH] += int(budgetChange[Global.RESOURCE.MONEY] * 10) + Global.reserves[Global.RESOURCE.MONEY] * 10
	for resource in Global.budgets:
		#if resource == Global.RESOURCE.TRADE: print(Global.budgets[Global.RESOURCE.TRADE])
		Global.budgets[resource] += budgetChange[resource]
	if fmod(Global.budgets[Global.RESOURCE.MONEY], 1) < 0.1: Global.budgets[Global.RESOURCE.MONEY] = int(Global.budgets[Global.RESOURCE.MONEY])
	Event.update_confirmation.emit()

func updateReserves():
	for resource in Global.RESOURCE.values():
		if resource in [Global.RESOURCE.TRADE]: continue
		Global.reserves[resource] += Global.budgets[resource]
	Global.score += Global.budgets[Global.RESOURCE.WEALTH] / 10
	Global.score += Global.budgets[Global.RESOURCE.INDUSTRY] / 10
	Global.score += Global.budgets[Global.RESOURCE.INFLUENCE] / 10
	Event.update_confirmation.emit()
