extends Control

@export var sidebar : PanelContainer
@export var resourcebar : PanelContainer
@export var sidebarOptions : VBoxContainer
@export var resourcebarOptions : HBoxContainer
@export var resourceCategory : PanelContainer
@export var categoryName : Label

@export var resourceBlueprint : PackedScene
@export var optionBlueprint : PackedScene
@export var ynaBlueprint : PackedScene
@export var sLabelBlueprint : PackedScene

var sidebarMenu : SidebarOption.TYPE
var categoryIndex = 0

func _ready():
	Event.option_pressed.connect(makeSidebar)
	Event.confirmation_required.connect(askConfirmation)
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

func createBuildingOption(building : Global.BUILDING):
	var option = optionBlueprint.instantiate()
	option.init(SidebarOption.TYPE.BUILDING)
	option.building = building
	option.label.set_text(Global.BUILDING.keys()[building])
	sidebarOptions.add_child(option)

func clearSidebar():
	for option in sidebarOptions.get_children():
		option.queue_free()

func makeSidebar(option : SidebarOption.TYPE):
	clearSidebar()
	sidebarMenu = option
	match option:
		SidebarOption.TYPE.MAIN:
			createOption(SidebarOption.TYPE.BUILD)
			createOption(SidebarOption.TYPE.ACT)
			createOption(SidebarOption.TYPE.MARKET)
		SidebarOption.TYPE.BUILD:
			createOption(SidebarOption.TYPE.COLONY)
			createOption(SidebarOption.TYPE.PRODUCTION)
			backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.COLONY:
			createBuildingOption(Global.BUILDING.CITY)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.PRODUCTION:
			createBuildingOption(Global.BUILDING.FACTORY)
			backOption(SidebarOption.TYPE.BUILD)

func askConfirmation(option : SidebarOption.TYPE, building):
	clearSidebar()
	var slabel : SidebarLabel = sLabelBlueprint.instantiate()
	slabel.label.set_text(Global.BUILDING.keys()[building])
	#print(slabel.label.text)
	slabel.updateSize()
	sidebarOptions.add_child(slabel)
	var yna : YNA = ynaBlueprint.instantiate()
	yna.option = option
	if option == SidebarOption.TYPE.BUILDING:
		yna.building = building
		yna.priceWorks = yna.checkPrice(yna.building)
	sidebarOptions.add_child(yna)
	yna.confirm.connect(postConfirmation)
	#print("confirm")

func postConfirmation(confirm : bool, option : SidebarOption.TYPE, building):
	#print("postconfirm")
	makeSidebar(sidebarMenu)
	if confirm:
		match option:
			SidebarOption.TYPE.BUILDING:
				if not building is bool:
					subtractCost(building)
					Event.create_building.emit(Global.selectedTile, building)
	Event.deselect_cursor.emit()

func subtractCost(building : Global.BUILDING):
	for resource in Global.buildingCosts[building]:
		Global.reserves[resource] -= Global.buildingCosts[building][resource]
