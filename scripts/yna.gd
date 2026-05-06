extends HBoxContainer

class_name YNA

@export var yes : SidebarOption
@export var no : SidebarOption

var option : SidebarOption.TYPE
var building = false
var priceWorks = false
var terrainWorks = false
var neighbors = 0
var startedProcess = false

signal confirm(confirmed : bool, option : SidebarOption.TYPE, building)

func _ready():
	yes.disable()
	await get_tree().create_timer(0.01).timeout
	yes.type = SidebarOption.TYPE.YES
	no.type = SidebarOption.TYPE.NO
	startedProcess = true

func _process(_delta):
	if not startedProcess: return
	if option == SidebarOption.TYPE.NEXT_TURN: 
		if yes.disabled: yes.enable()
		return
	if not building is bool and not Global.selected:
		if not yes.disabled: yes.disable()
	elif building is bool or (not priceWorks) or (not terrainWorks) or (neighbors < 1): #cost isn't aligned, add code later
		if not yes.disabled: yes.disable()
	else:
		if yes.disabled: yes.enable()

func checkTerrain(_building : Global.BUILDING, _terrain : Global.TERRAIN):
	var bannedTerrain = Global.buildingBannedTerrains[_building]
	if not _terrain in bannedTerrain:
		return true
	else: return false

func checkPrice(_building : Global.BUILDING):
	var cost = Global.buildingCosts[_building]
	for resource in cost.keys():
		if not Global.reserves[resource] - cost[resource] >= 0: 
			return false
	return true

func _on_yes():
	#print("yes")
	confirm.emit(true, option, building)
	queue_free()

func _on_no():
	#print("no")
	confirm.emit(false, option, building)
	queue_free()
