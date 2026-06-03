extends Control

@export var sidebar : PanelContainer
@export var resourcebar : Control
@export var sidebarOptions : VBoxContainer
@export var resourcebarOptions : HBoxContainer
@export var resourceCategory : PanelContainer
@export var categoryName : Label
@export var minimap : Minimap

@export var resourceBlueprint : PackedScene
@export var optionBlueprint : PackedScene
@export var ynaBlueprint : PackedScene
@export var sLabelBlueprint : PackedScene
@export var infoBoxBlueprint : PackedScene
@export var tradeOptionBlueprint : PackedScene
@export var notificationBlueprint: PackedScene
@export var choiceNotificationBlueprint: PackedScene
@export var singleOptionNotificationBlueprint: PackedScene

var sidebarMenu : SidebarOption.TYPE
var categoryIndex = 0

func _ready():
	Event.option_pressed.connect(makeSidebar)
	Event.confirmation_required.connect(askConfirmation)
	Event.update_confirmation.connect(updateBuildingConfirmation)
	Event.update_demolish_confirmation.connect(updateDemolishConfirmation)
	Event.update_activate_confirmation.connect(updateActivateConfirmation)
	Event.next_turn_confirmation.connect(askConfirmationNextTurn)
	Event.demolish_confirmation.connect(askConfirmationDemolish)
	Event.activate_confirmation.connect(askConfirmationActivate)
	Event.trade_confirmation.connect(askConfirmationTrade)
	Event.trade_order.connect(tradeConfirmed)
	Event.direct_confirmation.connect(directToPostConfirmation)
	makeSidebar(SidebarOption.TYPE.MAIN)
	#updateResourcebar()

func resourceMenuForward():
	if categoryIndex >= len(Global.resourceCategoriesLR)-1:
		categoryIndex = 0
	else: categoryIndex += 1
	updateResourcebar()

func resourceMenuBackward():
	if categoryIndex <= 0:
		categoryIndex = len(Global.resourceCategoriesLR)-1
	else: categoryIndex -= 1
	updateResourcebar()

func updateResourcebar():
	categoryName.set_text(Global.resourceCategoriesLR[categoryIndex].replace(" ", "_").capitalize())
	resourceCategory.size.x = 0
	clearResourcebar()
	var categoryResources = Global.resourceCategories[Global.resourceCategoriesLR[categoryIndex]]
	for resource in categoryResources:
		createResource(resource)

func clearResourcebar():
	for option in resourcebarOptions.get_children():
		option.queue_free()

func createResource(resource : Global.RESOURCE):
	var option = resourceBlueprint.instantiate()
	option.resource = resource
	option.update()
	resourcebarOptions.add_child(option)

func backOption(option : SidebarOption.TYPE):
	var back = optionBlueprint.instantiate()
	back.init(option)
	back.label.set_text("BACK")
	sidebarOptions.add_child(back)

func createOption(type : SidebarOption.TYPE):
	var option = optionBlueprint.instantiate()
	option.init(type)
	sidebarOptions.add_child(option)
	return option

var selectedTerrain
var selectedNeighbors
var selectedBuilding
var selectedActivated
signal fetchSelectedTile()

func setSelectedTile(neighbors, terrain, building, activated):
	selectedNeighbors = neighbors
	selectedTerrain = terrain
	selectedBuilding = building
	selectedActivated = activated

func createActivateOption():
	var option = createOption(SidebarOption.TYPE.ACTIVATE)
	fetchSelectedTile.emit()
	option.activate = selectedActivated
	return option

func createBuildingOption(building : Global.BUILDING):
	var option = optionBlueprint.instantiate()
	option.building = building
	fetchSelectedTile.emit()
	option.terrain = selectedTerrain
	option.tile = selectedNeighbors
	option.init(SidebarOption.TYPE.BUILDING)
	sidebarOptions.add_child(option)

func createMarket():
	for resource in Global.trades:
		createTradeOption(resource)

func createTradeOption(resource : Global.RESOURCE): 
	var option = createOption(SidebarOption.TYPE.TRADE)
	option.resource = resource
	option.init(SidebarOption.TYPE.TRADE)

func clearSidebar():
	#print("cho")
	for option in sidebarOptions.get_children():
		option.queue_free()

func makeSidebar(option : SidebarOption.TYPE):
	clearSidebar()
	#print(option)
	match option:
		SidebarOption.TYPE.MAIN:
			createOption(SidebarOption.TYPE.BUILD)
			createOption(SidebarOption.TYPE.ACT)
			createOption(SidebarOption.TYPE.MARKET)
			createOption(SidebarOption.TYPE.NEXT_TURN)
			createOption(SidebarOption.TYPE.SAVE)
			createOption(SidebarOption.TYPE.EXIT)
		SidebarOption.TYPE.BUILD:
			createOption(SidebarOption.TYPE.COLONY)
			createOption(SidebarOption.TYPE.POWER)
			createOption(SidebarOption.TYPE.HARVEST)
			createOption(SidebarOption.TYPE.PRODUCTION)
			createOption(SidebarOption.TYPE.MANUFACTORY)
			backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.ACT:
			createOption(SidebarOption.TYPE.DEMOLISH)
			createActivateOption()
			backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.MARKET:
			createMarket()
			backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.SAVE:
			createOption(SidebarOption.TYPE.SLOT_1)
			createOption(SidebarOption.TYPE.SLOT_2)
			createOption(SidebarOption.TYPE.SLOT_3)
			backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.COLONY:
			createBuildingOption(Global.BUILDING.CITY)
			createBuildingOption(Global.BUILDING.ROAD)
			createBuildingOption(Global.BUILDING.SPACEPORT)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.POWER:
			createBuildingOption(Global.BUILDING.SOLAR_FARM)
			createBuildingOption(Global.BUILDING.NUCLEAR_PLANT)
			createBuildingOption(Global.BUILDING.FUSION_PLANT)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.HARVEST:
			createBuildingOption(Global.BUILDING.MINE)
			createBuildingOption(Global.BUILDING.QUARRY)
			createBuildingOption(Global.BUILDING.ICE_MINE)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.PRODUCTION:
			createBuildingOption(Global.BUILDING.STEEL_MILL)
			createBuildingOption(Global.BUILDING.CONCRETE_PLANT)
			createBuildingOption(Global.BUILDING.BRASS_MILL)
			createBuildingOption(Global.BUILDING.PLASTIC_REFINERY)
			createBuildingOption(Global.BUILDING.FERTILIZER_FACTORY)
			createBuildingOption(Global.BUILDING.YEAST_VATS)
			createBuildingOption(Global.BUILDING.FARM)
			createBuildingOption(Global.BUILDING.WATER_EXTRACTOR)
			createBuildingOption(Global.BUILDING.ELECTROLYZER)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.MANUFACTORY:
			createBuildingOption(Global.BUILDING.ELECTRONICS_FACTORY)
			createBuildingOption(Global.BUILDING.CIVILIAN_FACTORY)
			backOption(SidebarOption.TYPE.BUILD)
	sidebarMenu = option

func askConfirmationTrade(resource): 
	clearSidebar()
	#print("son")
	var option : TradeOption = tradeOptionBlueprint.instantiate()
	sidebarOptions.add_child(option)
	option.resource = resource
	option.init()
	backOption(SidebarOption.TYPE.MARKET)

func askConfirmationActivate(tile, building, activated):
	#print("doit")
	clearSidebar()
	var slabel : SidebarLabel = sLabelBlueprint.instantiate()
	#slabel.label.text = "Booooom"
	if not building is bool and building != Global.BUILDING.EMPTY:
		if activated: slabel.label.text = "Deactivate"
		else: slabel.label.text = "Activate"
		slabel.label.text += (" this " + Global.buildingNames[building] + " at " + str(tile) + "?")
	else: slabel.label.text = ("There is no building at " + str(tile))
	#print(slabel.label.text)
	slabel.updateSize()
	var yna : YNA = ynaBlueprint.instantiate()
	yna.option = SidebarOption.TYPE.ACTIVATE
	yna.building = building
	yna.energyWorks = yna.checkEnergy(yna.building, activated)
	yna.laborWorks = yna.checkLabor(yna.building, activated)
	sidebarOptions.add_child(slabel)
	sidebarOptions.add_child(yna)
	yna.confirm.connect(postConfirmation)

func askConfirmationDemolish(tile, building):
	#print("doit")
	clearSidebar()
	var slabel : SidebarLabel = sLabelBlueprint.instantiate()
	sidebarOptions.add_child(slabel)
	if not building is bool and building != Global.BUILDING.EMPTY:
		slabel.label.set_text("Demolish this " + Global.buildingNames[building] + " at " + str(tile) + "?")
	else: slabel.label.set_text("There is nothing to demolish at " + str(tile))
	slabel.updateSize()
	var yna : YNA = ynaBlueprint.instantiate()
	yna.option = SidebarOption.TYPE.DEMOLISH
	yna.building = building
	yna.energyWorks = yna.checkEnergy(yna.building, true)
	yna.laborWorks = yna.checkLabor(yna.building, true)
	sidebarOptions.add_child(yna)
	yna.confirm.connect(postConfirmation)

func askConfirmationNextTurn():
	clearSidebar()
	var slabel : SidebarLabel = sLabelBlueprint.instantiate()
	sidebarOptions.add_child(slabel)
	slabel.label.set_text("Advance to Next Turn?")
	slabel.updateSize()
	var yna : YNA = ynaBlueprint.instantiate()
	yna.option = SidebarOption.TYPE.NEXT_TURN
	sidebarOptions.add_child(yna)
	yna.confirm.connect(postConfirmation)

func askConfirmation(option : SidebarOption.TYPE, building, terrain):
	clearSidebar()
	#print(slabel.label.text)
	#infobox.updateSize()
	fetchSelectedTile.emit()
	var neighbors = selectedNeighbors
	var infobox : Infobox = infoBoxBlueprint.instantiate()
	sidebarOptions.add_child(infobox)
	var yna : YNA = ynaBlueprint.instantiate()
	yna.option = option
	if option == SidebarOption.TYPE.BUILDING:
		yna.building = building
		yna.priceWorks = yna.checkPrice(yna.building)
		yna.terrainWorks = yna.checkTerrain(yna.building, terrain)
		yna.energyWorks = yna.checkEnergy(yna.building)
		yna.laborWorks = yna.checkLabor(yna.building)
		yna.neighbors = neighbors
		infobox.building = building
		infobox.terrain = terrain
		infobox.neighbors = neighbors
		#infoBox.energyWorks = yna.energyWorks
		#infoBox.laborWorks = yna.laborWorks
		infobox.updateText()
	sidebarOptions.add_child(yna)
	yna.confirm.connect(postConfirmation)
	#print("confirm")

func updateActivateConfirmation(tile):
	#print("blu")
	var options = sidebarOptions.get_children()
	var yna = false
	var slabel = false
	for option in options:
		if option is YNA: 
			yna = option
			#print("facts")
		if option is SidebarLabel: slabel = option
	if not yna is bool and yna.option == SidebarOption.TYPE.ACTIVATE: 
		fetchSelectedTile.emit()
		#print("fool")
		yna.building = selectedBuilding
		yna.energyWorks = yna.checkEnergy(yna.building, selectedActivated)
		yna.laborWorks = yna.checkLabor(yna.building, selectedActivated)
		yna.budgetWorks = yna.checkOtherBudgets(yna.building, selectedActivated)
		if slabel is not bool:
			if not selectedBuilding is bool and selectedBuilding != Global.BUILDING.EMPTY:
				if selectedBuilding == Global.BUILDING.CENTER: 
					slabel.label.set_text("[color=990000ff]Cannot deactivate Colony Center[/color]")
				elif selectedBuilding == Global.BUILDING.ROAD: 
					slabel.label.set_text("[color=ffff00ff]Deactivating Roads does nothing.[/color]")
				else: 
					slabel.label.text = ""
					if selectedActivated: 
						if not yna.energyWorks: 
							slabel.label.text += "[color=990000ff]This building provides Energy that is currently in use.[/color]\n"
						if not yna.laborWorks: 
							slabel.label.text += "[color=990000ff]This building provides Labor that is currently in use.[/color]\n"
						if not yna.budgetWorks: 
							slabel.label.text += ("[color=990000ff]This building provides resources currently in use."+
									" Without it, you would fall into debt.[/color]\n")
						slabel.label.text += "Deactivate"
					else:
						if not yna.energyWorks: 
							slabel.label.text += "[color=990000ff]There is insufficient Energy to power this building.[/color]\n"
						if not yna.laborWorks: 
							slabel.label.text += "[color=990000ff]There is insufficient Labor to power this building.[/color]\n"
						if not yna.budgetWorks: 
							slabel.label.text += ("[color=990000ff]This building consumes resources that the colony does not havev."+
									" You cannot activate it without falling into debt.[/color]\n") 
						slabel.label.text += "Activate"
					slabel.label.text += (" this " + Global.buildingNames[selectedBuilding] + " at " + str(tile) + "?")
			else: slabel.label.set_text("[color=990000ff]There is no building at " + str(tile)+"[/color]")

func updateDemolishConfirmation(tile):
	#print("blu")
	var options = sidebarOptions.get_children()
	var yna = false
	var slabel = false
	for option in options:
		if option is YNA: 
			yna = option
			#print("facts")
		if option is SidebarLabel: slabel = option
	if not yna is bool and yna.option == SidebarOption.TYPE.DEMOLISH: 
		fetchSelectedTile.emit()
		#print("fool")
		yna.building = selectedBuilding
		yna.energyWorks = yna.checkEnergy(yna.building, true)
		yna.laborWorks = yna.checkLabor(yna.building, true)
		if slabel is not bool:
			if not selectedBuilding is bool and selectedBuilding != Global.BUILDING.EMPTY:
				if selectedBuilding == Global.BUILDING.CENTER: slabel.label.set_text("[color=990000ff]Cannot destroy Colony Center[/color]")
				else: slabel.label.set_text("Demolish this " + Global.buildingNames[selectedBuilding] + " at " + str(tile) + "?")
			else: slabel.label.set_text("[color=990000ff]There is nothing to demolish at " + str(tile)+"[/color]")
			#slabel.updateSize()

func updateBuildingConfirmation():
	var options = sidebarOptions.get_children()
	var yna = false
	var infobox = false
	for option in options:
		if option is YNA: yna = option
		if option is Infobox: infobox = option
	if not yna is bool and yna.option == SidebarOption.TYPE.BUILDING:
		fetchSelectedTile.emit()
		yna.priceWorks = yna.checkPrice(yna.building)
		yna.terrainWorks = yna.checkTerrain(yna.building, selectedTerrain)
		yna.neighbors = selectedNeighbors
		yna.energyWorks = yna.checkEnergy(yna.building)
		yna.laborWorks = yna.checkLabor(yna.building)
	if not infobox is bool:
		infobox.terrain = selectedTerrain
		infobox.neighbors = selectedNeighbors
		infobox.updateText()

func confirmSave(slot):
	var choice := choiceNotificationBlueprint.instantiate()
	add_child(choice)
	choice.size = Vector2(256, 180)
	choice.centerOnScreen()
	choice.setContent("Save Game", "This will save your game on Slot " + str(slot))
	choice.setChoices("Proceed?")
	#print(choice)
	var result = await choice.getChoice()
	if result: 
		Event.saveGame.emit(slot)
		return
	else: return

func confirmExit():
	var choice := choiceNotificationBlueprint.instantiate()
	add_child(choice)
	choice.size = Vector2(256, 200)
	choice.centerOnScreen()
	choice.setContent("Exit Game", "This will send you to the main menu. Make sure to save your game first.")
	choice.setChoices("Exit without saving?")
	var result = await choice.getChoice()
	if result: get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
	else: return

func directToPostConfirmation(option : SidebarOption.TYPE):
	match option:
		SidebarOption.TYPE.SLOT_1:
			print("lols")
			await confirmSave(1)
		SidebarOption.TYPE.SLOT_2:
			await confirmSave(2)
		SidebarOption.TYPE.SLOT_3:
			await confirmSave(3)
		SidebarOption.TYPE.EXIT:
			await confirmExit()
	Event.deselect_cursor.emit()
	makeSidebar(sidebarMenu)

func postConfirmation(confirm : bool, option : SidebarOption.TYPE, building, startActivated=true):
	#print("postconfirm")
	if confirm:
		match option:
			SidebarOption.TYPE.BUILDING:
				if not building is bool:
					subtractCost(building)
					Event.create_building.emit(Global.selectedTile, building, startActivated)
			SidebarOption.TYPE.NEXT_TURN:
				Event.next_turn.emit()
				updateResourcebar()
			SidebarOption.TYPE.DEMOLISH:
				Event.demolish_building.emit()
			SidebarOption.TYPE.ACTIVATE:
				Event.toggle_activation.emit(Global.selectedTile)
	Event.deselect_cursor.emit()
	#print(sidebarMenu)
	makeSidebar(sidebarMenu)

func tradeConfirmed(_resource, _quantity):
	Event.deselect_cursor.emit()
	makeSidebar(SidebarOption.TYPE.MARKET)

func subtractCost(building : Global.BUILDING):
	for resource in Global.buildingCosts[building]:
		Global.reserves[resource] -= Global.buildingCosts[building][resource]
