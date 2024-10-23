extends Control

@export var sidebar : Control
@export var resourcebar : Control
@export var sidebarOptions : VBoxContainer
@export var resourcebarOptions : HBoxContainer

@export var optionBlueprint : PackedScene
@export var ynaBlueprint : PackedScene
@export var sLabelBlueprint : PackedScene

var sidebarMenu : SidebarOption.TYPE

func _ready():
	Event.option_pressed.connect(makeSidebar)
	Event.confirmation_required.connect(askConfirmation)
	makeSidebar(SidebarOption.TYPE.MAIN)

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

func askConfirmation(option : SidebarOption.TYPE, building : Global.BUILDING):
	clearSidebar()
	var slabel : SidebarLabel = sLabelBlueprint.instantiate()
	slabel.label.set_text(Global.BUILDING.keys()[building])
	print(slabel.label.text)
	slabel.updateSize()
	sidebarOptions.add_child(slabel)
	var yna : YNA = ynaBlueprint.instantiate()
	yna.option = option
	yna.building = building
	sidebarOptions.add_child(yna)
	yna.confirm.connect(postConfirmation)
	print("confirm")

func postConfirmation():
	print("postconfirm")
	makeSidebar(sidebarMenu)
	pass
