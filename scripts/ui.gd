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

var sidebarMenu : SidebarOption.TYPE
var categoryIndex = 0

func _ready():
	Event.option_pressed.connect(makeSidebar)
	Event.confirmation_required.connect(askConfirmation)
	Event.update_confirmation.connect(updateBuildingConfirmation)
	Event.next_turn_confirmation.connect(askConfirmationNextTurn)
	makeSidebar(SidebarOption.TYPE.MAIN)
	updateResourcebar()

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
	categoryName.set_text(Global.resourceCategoriesLR[categoryIndex])
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

var selectedTerrain
var selectedNeighbors
signal fetchSelectedTile()

func setSelectedTile(neighbors, terrain):
	selectedNeighbors = neighbors
	selectedTerrain = terrain

func createBuildingOption(building : Global.BUILDING):
	var option = optionBlueprint.instantiate()
	option.building = building
	fetchSelectedTile.emit()
	option.terrain = selectedTerrain
	option.tile = selectedNeighbors
	option.init(SidebarOption.TYPE.BUILDING)
	sidebarOptions.add_child(option)

func clearSidebar():
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
		SidebarOption.TYPE.BUILD:
			createOption(SidebarOption.TYPE.COLONY)
			createOption(SidebarOption.TYPE.POWER)
			createOption(SidebarOption.TYPE.HARVEST)
			createOption(SidebarOption.TYPE.PRODUCTION)
			backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.ACT:
			backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.MARKET:
			backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.COLONY:
			createBuildingOption(Global.BUILDING.CITY)
			createBuildingOption(Global.BUILDING.ROAD)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.POWER:
			createBuildingOption(Global.BUILDING.NUCLEAR_PLANT)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.HARVEST:
			createBuildingOption(Global.BUILDING.MINE)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.PRODUCTION:
			createBuildingOption(Global.BUILDING.STEEL_MILL)
			backOption(SidebarOption.TYPE.BUILD)
	sidebarMenu = option

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
		yna.neighbors = neighbors
		infobox.building = building
		infobox.terrain = terrain
		infobox.neighbors = neighbors
		infobox.updateText()
	sidebarOptions.add_child(yna)
	yna.confirm.connect(postConfirmation)
	#print("confirm")

func updateBuildingConfirmation():
	var options = sidebarOptions.get_children()
	var yna = false
	var infobox = false
	for option in options:
		if option is YNA: yna = option
		if option is Infobox: infobox = option
	if yna is not bool and yna.option != SidebarOption.TYPE.NEXT_TURN:
		fetchSelectedTile.emit()
		yna.priceWorks = yna.checkPrice(yna.building)
		yna.terrainWorks = yna.checkTerrain(yna.building, selectedTerrain)
		yna.neighbors = selectedNeighbors
	if infobox is not bool:
		infobox.terrain = selectedTerrain
		infobox.neighbors = selectedNeighbors
		infobox.updateText()

func postConfirmation(confirm : bool, option : SidebarOption.TYPE, building):
	#print("postconfirm")
	if confirm:
		match option:
			SidebarOption.TYPE.BUILDING:
				if not building is bool:
					subtractCost(building)
					Event.create_building.emit(Global.selectedTile, building)
			SidebarOption.TYPE.NEXT_TURN:
				Event.next_turn.emit()
				updateResourcebar()
	Event.deselect_cursor.emit()
	#print(sidebarMenu)
	makeSidebar(sidebarMenu)

func subtractCost(building : Global.BUILDING):
	for resource in Global.buildingCosts[building]:
		Global.reserves[resource] -= Global.buildingCosts[building][resource]
