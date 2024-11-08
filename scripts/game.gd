extends Node

class_name Game

#This script is a game manager. This means this script handles the compiling of resources,
#the creation and handling of in-game events, and much more.

@export var map = Map
@export var camera = Camera2D
@export var ui = Control

func _ready():
	Event.update_resources.connect(updateBudgets)
	initResources()
	startingResources()

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

func updateBudgets():
	resetBudgets()
	var budgetChange = Global.budgets.duplicate()
	for building in map.buildingMap:
		var buildingBudget = Global.buildingBudgets[map.buildingMap[building]]
		for resource in buildingBudget:
			budgetChange[resource] += buildingBudget[resource]
	for resource in Global.budgets:
		Global.budgets[resource] += budgetChange[resource]
