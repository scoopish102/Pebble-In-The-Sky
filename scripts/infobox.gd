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
	if building in Global.buildingIndustry:
		body.text += ("[font_size=32][color=000099ff]" + str(Global.buildingIndustry[building]) + "[/color][/font_size][img]" +
				Global.resIcons[Global.RESOURCE.INDUSTRY] + "[/img]\nupon construction.\n")
		body.text += ("[font_size=32][color=000099ff]" + str(Global.buildingIndustry[building]/2) + "[/color][/font_size][img]" +
				Global.resIcons[Global.RESOURCE.INDUSTRY] + "[/img]\nper adjacent building with this same bonus.\n")
	if building in Global.buildingInfluence:
		body.text += ("[font_size=32][color=000099ff]" + str(Global.buildingInfluence[building]) + "[/color][/font_size][img]" +
				Global.resIcons[Global.RESOURCE.INFLUENCE] + "[/img]\nupon construction.\n")
	if building in Global.specialAdjacencyText:
		body.text += Global.specialAdjacencyText[building] + "\n"
	body.text += ("[font_size=32][color=000099ff]" + str(Global.buildingScores[building]) + "[/color][/font_size][img]" +
			Global.resIcons[Global.RESOURCE.SCORE] + "[/img]\nupon construction.\n")
	body.text += "\n"
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
		var cob = checkOtherBudgets()
		if len(cob) > 0: 
			body.text += "\n[color=ffff00ff]Warning: Insufficient" 
			var cobcount = 0
			for res in cob:
				body.text += " " + camelConversion(str(Global.RESOURCE.keys()[res]))
				cobcount += 1
				if cobcount == len(cob): continue
				elif cobcount == len(cob)-1: body.text += " and"
				else: body.text += ","
			body.text += ". Will start disabled.[/color]"
	body.text += "[/font_size]"

func camelConversion(input: String) -> String:
	var words: PackedStringArray = input.to_lower().split("_")
	var camel_case: String = ""
	for i in range(0, words.size()):
		camel_case += words[i].capitalize()
	return camel_case

func checkOtherBudgets():
	var missingResources = []
	if not building in Global.buildingBudgets: return missingResources
	var budget = Global.buildingBudgets[building]
	for resource in budget:
		if not resource is Global.RESOURCE: continue
		if resource == Global.RESOURCE.ENERGY or resource == Global.RESOURCE.LABOR: continue
		if Global.reserves[resource] + (Global.budgets[resource] + budget[resource]) < 0: 
			missingResources.append(resource)
	return missingResources

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
			if (Global.reserves[res] + Global.budgets[res] + Global.buildingBudgets[building][res] < 0):
				text += "[color=#ff0000ff]" #red
			elif Global.budgets[res] + Global.buildingBudgets[building][res] < 0:
				text += "[color=#ffff00ff]" #yeller
			else:
				text += "[color=#00ff00ff]" #green
			text += str(Global.buildingBudgets[building][res])
			text += "[/color]"
			text += "[img]" + Global.resIcons[res] + "[/img]"
			#print(Global.buildingCosts[building][res])
		if i >= len(Global.buildingBudgets[building])-1: text += "\n"
		elif i % 2 == 1: text += "\n"
		else: text += ", "
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
		text += "[img]" + Global.resIcons[res] + "[/img]"
		if i >= len(Global.buildingCosts[building])-1: text += "\n"
		elif i % 2 == 1: text += "\n"
		else: text += ", "
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
