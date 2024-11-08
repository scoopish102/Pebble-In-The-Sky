extends HBoxContainer

class_name YNA

@export var yes : SidebarOption
@export var no : SidebarOption

var option : SidebarOption.TYPE
var building = false
var priceWorks = false

signal confirm(confirmed : bool, option : SidebarOption.TYPE, building)

func _process(_delta):
	if not building is bool and not Global.selected:
		if not yes.disabled: yes.disable()
	elif not building is bool and not priceWorks: #cost isn't aligned, add code later
		if not yes.disabled: yes.disable()
	else:
		if yes.disabled: yes.enable()

func checkPrice(_building : Global.BUILDING):
	var cost = Global.buildingCosts[_building]
	for resource in cost.keys():
		if not Global.reserves[resource] - cost[resource] >= 0: 
			return false
	return true

func _on_yes():
	confirm.emit(true, option, building)
	queue_free()

func _on_no():
	confirm.emit(false, option, building)
	queue_free()
