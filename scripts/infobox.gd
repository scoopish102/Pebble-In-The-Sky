class_name Infobox extends NinePatchRect

@export var label : Label
@export var body : RichTextLabel

var building
var terrain
var neighbors

func updateSize():
	set_deferred("size.y", label.size.y + 32)

func updateText():
	label.set_text(Global.buildingNames[building])
	var cost = compileCost()
	var budget = compileBudget()
	body.set_text(cost + budget)
	body.text += "[font_size=16]\n"
	body.text += Global.description[building] + "\n"
	if not Global.selected: body.text += "\nSelect a tile to construct."
	else:
		if not checkTerrain(): body.text += "\nCannot construct this building on this type of terrain."
		if not checkPrice(): body.text += "\nInsufficient reserves to construct this building."
		if neighbors < 1: 
			if neighbors == -1: body.text += "\nThere is already a building here."
			else: body.text += "\nMust be built adjacent to another building."
	body.text += "[/font_size]"

func compileBudget():
	if not building in Global.buildingBudgets: return "No upkeep or production.\n"
	var text = "Budget: \n"
	var i = 0
	for res in Global.buildingBudgets[building].keys():
		if res is StringName and res == &"DEPOSIT":
			text += "[color=#3b3b3bff]" #gray
			text += str(Global.buildingBudgets[building][res])
			text += "[/color]"
			text += " Tile Deposit"
		else:
			if Global.budgets[res] + Global.buildingBudgets[building][res] >= 0:
				text += "[color=#00ff00ff]" #green
			else:
				text += "[color=#ff0000ff]" #red
			text += str(Global.buildingBudgets[building][res])
			text += "[/color]"
			text += " [img]" + Global.resIcons[res] + "[/img]"
			#print(Global.buildingCosts[building][res])
		if i >= len(Global.buildingBudgets[building])-1: text += "\n"
		elif i % 2 == 1: text += "\n"
		else: text += " , "
		i += 1
	return text

func compileCost():
	if not building in Global.buildingCosts: return "Cannot be built.\n"
	var text = "Costs: \n"
	var i = 0
	for res in Global.buildingCosts[building]:
		if Global.reserves[res] >= Global.buildingCosts[building][res]:
			text += "[color=#00ff00ff]"
		else:
			text += "[color=#ff0000ff]"
		text += str(Global.buildingCosts[building][res])
		text += "[/color]"
		text += " [img]" + Global.resIcons[res] + "[/img]"
		if i >= len(Global.buildingCosts[building])-1: text += "\n"
		elif i % 2 == 1: text += "\n"
		else: text += " , "
		i += 1
		#print(Global.buildingCosts[building][res])
	return text

func checkTerrain():
	var bannedTerrain = Global.buildingBannedTerrains[building]
	if not terrain in bannedTerrain:
		return true
	else: return false

func checkPrice():
	var cost = Global.buildingCosts[building]
	for resource in cost.keys():
		if not Global.reserves[resource] - cost[resource] >= 0: 
			return false
	return true
