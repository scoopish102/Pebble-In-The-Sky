extends HBoxContainer

class_name YNA

@export var yes : SidebarOption
@export var no : SidebarOption

var option : SidebarOption.TYPE
var building = false
var priceWorks = false
var budgetWorks = false
var energyWorks = false
var laborWorks = false
var terrainWorks = false
var neighbors = 0
var startedProcess = false

signal confirm(confirmed : bool, option : SidebarOption.TYPE, building, startActivated : bool)

func _ready():
	yes.disable()
	await get_tree().create_timer(0.01).timeout
	yes.type = SidebarOption.TYPE.YES
	no.type = SidebarOption.TYPE.NO
	startedProcess = true

func _process(_delta):
	if not startedProcess: return
	if option == SidebarOption.TYPE.ACTIVATE:
		if (not Global.selected or (building is bool or (not laborWorks) or (not energyWorks) or (not budgetWorks) or
				building == Global.BUILDING.EMPTY or building == Global.BUILDING.CENTER)):
			if not yes.disabled: yes.disable()
		else: if yes.disabled: yes.enable()
		return
	if option == SidebarOption.TYPE.DEMOLISH:
		if (not Global.selected or (building is bool or (not laborWorks) or (not energyWorks) or
				building == Global.BUILDING.EMPTY or building == Global.BUILDING.CENTER)):
			if not yes.disabled: yes.disable()
		else: if yes.disabled: yes.enable()
		return
	if option == SidebarOption.TYPE.NEXT_TURN: 
		if yes.disabled: yes.enable()
		return
	if not (building is bool or building == Global.BUILDING.EMPTY) and not Global.selected:
		if not yes.disabled: yes.disable()
	elif ((building is bool or building == Global.BUILDING.EMPTY) or (not priceWorks) or (not terrainWorks) or (neighbors < 1)):
		if not yes.disabled: yes.disable()
	else:
		if yes.disabled: yes.enable()

func checkTerrain(_building : Global.BUILDING, _terrain : Global.TERRAIN):
	var bannedTerrain = Global.buildingBannedTerrains[_building]
	if not _terrain in bannedTerrain:
		return true
	else: return false

func checkOtherBudgets(_building : Global.BUILDING, reverse=false):
	if not _building in Global.buildingBudgets: return true
	var budget = Global.buildingBudgets[_building]
	var rev = (int(reverse) * 2 - 1) * -1
	for resource in budget:
		if not resource is Global.RESOURCE: continue
		if resource == Global.RESOURCE.ENERGY or resource == Global.RESOURCE.LABOR: continue
		if Global.reserves[resource] + (budget[resource]*rev) < 0: return false
	return true

func checkEnergy(_building : Global.BUILDING, reverse=false):
	if not _building in Global.buildingBudgets: return true
	var budget = Global.buildingBudgets[_building]
	var rev = (int(reverse) * 2 - 1) * -1
	if Global.RESOURCE.ENERGY in budget:
		if Global.budgets[Global.RESOURCE.ENERGY] + (budget[Global.RESOURCE.ENERGY]*rev) < 0: return false
		else: return true
	else: return true

func checkLabor(_building : Global.BUILDING, reverse=false):
	if not _building in Global.buildingBudgets: return true
	var budget = Global.buildingBudgets[_building]
	var rev = (int(reverse) * 2 - 1) * -1
	if Global.RESOURCE.LABOR in budget:
		if Global.budgets[Global.RESOURCE.LABOR] + (budget[Global.RESOURCE.LABOR]*rev) < 0: return false
		else: return true
	else: return true

func checkPrice(_building : Global.BUILDING):
	var cost = Global.buildingCosts[_building]
	for resource in cost.keys():
		if not Global.reserves[resource] - cost[resource] >= 0: 
			return false
	return true

func _on_yes():
	#print("yes")
	var startActivation = laborWorks and energyWorks
	confirm.emit(true, option, building, startActivation)
	queue_free()

func _on_no():
	#print("no")
	confirm.emit(false, option, building, false)
	queue_free()
