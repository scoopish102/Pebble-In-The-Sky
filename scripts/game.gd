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
	ui.fetchSelectedTile.connect(sendSelectedTile)
	initResources()
	startingResources()

func _process(_delta):
	cursor.update(ui.minimap)

func sendSelectedTile():
	var terrain = map.terrainMap[cursor.tile]
	var neighbors = map.getNeighborCount(cursor.tile)
	ui.setSelectedTile(neighbors, terrain)

func startingResources():
	Global.reserves[Global.RESOURCE.CONCRETE] = 32
	Global.reserves[Global.RESOURCE.STEEL] = 16
	Global.reserves[Global.RESOURCE.FOOD] = 16
	Global.reserves[Global.RESOURCE.OXYGEN] = 16
	Global.reserves[Global.RESOURCE.WATER] = 16
	Global.reserves[Global.RESOURCE.MONEY] = 64

func initResources():
	for resource in Global.RESOURCE.values():
		Global.reserves[resource] = 0
		Global.budgets[resource] = 0

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
		if not building in Global.buildingBudgets: continue
		var buildingBudget = Global.buildingBudgets[map.buildingMap[building]]
		for resource in buildingBudget:
			if not resource is int and resource == &"DEPOSIT":
				if map.terrainMap[building] in Global.depositToResource:
					budgetChange[Global.depositToResource[map.terrainMap[building]]] += buildingBudget[resource]
			else: budgetChange[resource] += buildingBudget[resource]
	for resource in Global.budgets:
		Global.budgets[resource] += budgetChange[resource]
	Event.update_confirmation.emit()

func updateReserves():
	for resource in Global.RESOURCE.values():
		Global.reserves[resource] += Global.budgets[resource]
	Event.update_confirmation.emit()
