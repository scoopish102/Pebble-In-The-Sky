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
	body.text += "\n"
	if building in Global.buildingIndustry:
		body.text += ("[color=000099ff]" + str(Global.buildingIndustry[building]) + "[/color][img]" +
				Global.resIcons[Global.RESOURCE.INDUSTRY] + "[/img] Industry\n")
		body.text += ("[color=000099ff]" + str(Global.buildingIndustry[building]/2) + "[/color][img]" +
				Global.resIcons[Global.RESOURCE.INDUSTRY] + "[/img] per adjacent building with this same bonus.\n")
	if building in Global.buildingInfluence:
		body.text += ("[color=000099ff]" + str(Global.buildingInfluence[building]) + "[/color][img]" +
				Global.resIcons[Global.RESOURCE.INFLUENCE] + "[/img] Influence\n")
	if building in Global.specialAdjacencyText:
		body.text += Global.specialAdjacencyText[building] + "\n"
	body.text += ("[color=000099ff]" + str(Global.buildingScores[building]) + "[/color][img]" +
			Global.resIcons[Global.RESOURCE.SCORE] + "[/img] Score\n")
	body.text += "\n[font_size=16]"
	body.text += Global.description[building] + "\n"
	if not Global.selected: body.text += "\n[color=990000ff]Select a tile to construct.[/color]"
	else:
		if neighbors < 1: 
			if neighbors == -1: body.text += "\n[color=990000ff]There is already a building here.[/color]"
			else: body.text += "\n[color=990000ff]Must be built adjacent to another building.[/color]"
		if not checkTerrain(): body.text += "\n[color=990000ff]Cannot construct this building on this type of terrain.[/color]"
		if not checkPrice(): body.text += "\n[color=990000ff]Insufficient reserves to construct this building.[/color]"
		if not checkEnergy(): body.text += "\n[color=ffff00ff]Warning: Insufficient Energy. Will start disabled.[/color]"
		if not checkLabor(): body.text += "\n[color=ffff00ff]Warning: Insufficient Labor. Will start disabled.[/color]"
		if not checkOtherBudgets(): body.text += "\n[color=ffff00ff]Warning: Cannot meet budget. Will start disabled.[/color]"
	body.text += "[/font_size]"

func checkOtherBudgets():
	if not building in Global.buildingBudgets: return true
	var budget = Global.buildingBudgets[building]
	for resource in budget:
		if not resource is Global.RESOURCE: continue
		if resource == Global.RESOURCE.ENERGY or resource == Global.RESOURCE.LABOR: continue
		if Global.reserves[resource] + (budget[resource]) < 0: return false
	return true

func checkEnergy():
	if not building in Global.buildingBudgets: return true
	var budget = Global.buildingBudgets[building]
	if Global.RESOURCE.ENERGY in budget:
		if Global.budgets[Global.RESOURCE.ENERGY] + (budget[Global.RESOURCE.ENERGY]) < 0: return false
		else: return true
	else: return true

func checkLabor():
	if not building in Global.buildingBudgets: return true
	var budget = Global.buildingBudgets[building]
	if Global.RESOURCE.LABOR in budget:
		if Global.budgets[Global.RESOURCE.LABOR] + (budget[Global.RESOURCE.LABOR]) < 0: return false
		else: return true
	else: return true

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
