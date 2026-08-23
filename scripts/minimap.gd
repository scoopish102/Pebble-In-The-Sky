class_name Minimap extends Control #really inspector, code is similar but name has changed

@export var label : RichTextLabel
@export var turnLabel : RichTextLabel
@export var minimapTile : Tile
@export var content : Container
@export var actions : VBoxContainer
@export var activateButton : Button
@export var checkButton : Button
@export var demolishButton : Button
@export var showbuildingButton : Button
@export var shadeunselectedButton : Button
var openned = true

func _ready():
	Event.tileSelected.connect(showActions)
	Event.tileDeselected.connect(hideActions)
	for subtile in minimapTile.subtiles:
		subtile.terrain.stop()
		subtile.building.stop()

#

func copyFrom(tile: Tile):
	var subtileInfo = []
	for subtile in tile.subtiles:
		subtileInfo.append(subtile.getCopyInfo())
	for sid in range(len(minimapTile.subtiles)):
		minimapTile.subtiles[sid].copyFrom(subtileInfo[sid])
	minimapTile.overall.animation = tile.overall.animation
	minimapTile.overall.frame = tile.overall.frame
	updateText(tile.tile, tile.terrain, tile.building, tile.subtiles[0].building.use_parent_material, tile.altitude)

func updateText(tile, terrain, building, active, altitude):
	var ttext = (Global.TERRAIN.find_key(terrain))
	ttext = ttext.replace(" ", "_").capitalize() 
	var btext = ""
	if building is bool or building == Global.BUILDING.EMPTY: btext = "\n" + Global.terrainDescriptions[terrain]
	else: 
		if not active: btext = "[color=ffff00ff]Disabled[/color] "
		btext += (Global.buildingNames[building])
		btext += "\n\n" + Global.description[building]
	#btext = btext.replace(" ", "_").capitalize() 
	label.set_text("[font_size=16]\nX: " + str(tile.x) + ", Y: " + str(tile.y) + "\nAltitude " + str(altitude) + "\n" + ttext + "\n" + btext + "[/font_size]")

func showActions(tile, terrain, building, activation, _altitude): 
	if not building: return
	actions.visible = true
	activateButton.tooltip_text = ""
	demolishButton.tooltip_text = ""
	activateButton.disabled = false
	demolishButton.disabled = false
	var energyWorks = checkEnergy(building, activation)
	var laborWorks = checkLabor(building, activation)
	var budgetWorks
	if building != Global.BUILDING.ROAD and not Global.buildingBudgets[building] is bool:
		if &"DEPOSIT" in Global.buildingBudgets[building].keys(): 
			#print(Global.buildingBudgets[building].keys())
			var depositType 
			if terrain in Global.depositToResource: 
				depositType = Global.depositToResource[terrain]
				budgetWorks = checkOtherBudgets(building, activation, depositType)
		else: budgetWorks = checkOtherBudgets(building, activation)
	else: budgetWorks = true
	if not building is bool and building != Global.BUILDING.EMPTY:
		if building == Global.BUILDING.CENTER: 
			activateButton.tooltip_text = "Cannot deactivate Colony Center."
			activateButton.disabled = true
			demolishButton.tooltip_text = "Cannot demolish Colony Center."
			demolishButton.disabled = true
			activateButton.text = "Deactivate Building"
		elif building == Global.BUILDING.ROAD: 
			activateButton.tooltip_text = "This building has no production or upkeep to deactivate."
			activateButton.disabled = true
			activateButton.text = "Deactivate Building"
		else: 
			if activation: 
				if not energyWorks: 
					activateButton.tooltip_text += "[color=990000ff]This building provides Energy that is currently in use.[/color]\n"
					demolishButton.tooltip_text = "[color=990000ff]This building provides Energy that is currently in use.[/color]\n"
					activateButton.disabled = true
					demolishButton.disabled = true
				if not laborWorks: 
					activateButton.tooltip_text += "[color=990000ff]This building provides Labor that is currently in use.[/color]\n"
					demolishButton.tooltip_text = "[color=990000ff]This building provides Labor that is currently in use.[/color]\n"
					activateButton.disabled = true
					demolishButton.disabled = true
				if not budgetWorks: 
					activateButton.tooltip_text += ("[color=990000ff]This building provides resources currently in use."+
							" Without it, you would fall into debt.[/color]\n")
					demolishButton.tooltip_text = ("[color=990000ff]This building provides resources currently in use."+
							" Without it, you would fall into debt.[/color]\n")
					activateButton.disabled = true
					demolishButton.disabled = true
				activateButton.text = "Deactivate Building"
				activateButton.tooltip_text += ("Dectivate " + Global.buildingNames[building] + " at " + str(tile) + ".")
			else:
				if not energyWorks: 
					activateButton.tooltip_text += "[color=990000ff]There is insufficient Energy to power this building.[/color]\n"
					activateButton.disabled = true
				if not laborWorks: 
					activateButton.tooltip_text += "[color=990000ff]There is insufficient Labor to power this building.[/color]\n"
					activateButton.disabled = true
				if not budgetWorks: 
					activateButton.tooltip_text +=  ("[color=990000ff]This building consumes resources that the colony does no have."+
							" You cannot activate it without falling into debt.[/color]\n")
					activateButton.disabled = true
				activateButton.text = "Activate Building"
				activateButton.tooltip_text += ("Activate " + Global.buildingNames[building] + " at " + str(tile) + ".")
	else: 
		activateButton.tooltip_text = ("[color=990000ff]There is no building at " + str(tile)+"[/color]")
		demolishButton.tooltip_text = ("[color=990000ff]There is no building at " + str(tile)+"[/color]")
		activateButton.disabled = true
		demolishButton.disabled = true

func hideActions(): actions.visible = false

func checkOtherBudgets(_building : Global.BUILDING, reverse=false, depositType=false):
	if not _building in Global.buildingBudgets: return true
	var budget = Global.buildingBudgets[_building]
	var rev = (int(reverse) * 2 - 1) * -1
	for resource in budget:
		if not resource is Global.RESOURCE: 
			if depositType is bool: continue
			if Global.reserves[depositType] + Global.budgets[depositType] + budget[&"DEPOSIT"]*rev < 0: 
				return false
			else: continue
		if resource == Global.RESOURCE.ENERGY or resource == Global.RESOURCE.LABOR: continue
		if Global.reserves[resource] + Global.budgets[resource] + budget[resource]*rev < 0: return false
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

func _on_minimize_toggled(toggled_on):
	content.visible = not toggled_on

func _on_minimap_toggled(toggled_on):
	if toggled_on: open()
	else: close()

var tween : Tween

func open(): 
	openned = true
	#var screenSize = get_viewport_rect().size
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", 0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func close(): 
	openned = false
	#var screenSize = get_viewport_rect().size
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", -380, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
