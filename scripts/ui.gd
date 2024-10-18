extends Control

@export var sidebar : Control
@export var resourcebar : Control
@export var sidebarOptions : VBoxContainer
@export var resourcebarOptions : HBoxContainer

@export var optionBlueprint : PackedScene

var sidebarMenu : SidebarOption.TYPE

func _ready():
	Event.option_pressed.connect(makeSidebar)
	makeSidebar(SidebarOption.TYPE.MAIN)

func backOption(option : SidebarOption.TYPE):
	var back = createOption(option)
	back.label.set_text("BACK")
	sidebarOptions.add_child(back)

func createOption(type : SidebarOption.TYPE):
	var option = optionBlueprint.instantiate()
	option.init(type)
	return option

func clearSidebar():
	for option in sidebarOptions.get_children():
		option.queue_free()

func makeSidebar(option : SidebarOption.TYPE):
	clearSidebar()
	var back : SidebarOption
	sidebarMenu = option
	match option:
		SidebarOption.TYPE.MAIN:
			sidebarOptions.add_child(createOption(SidebarOption.TYPE.BUILD))
			sidebarOptions.add_child(createOption(SidebarOption.TYPE.ACT))
			sidebarOptions.add_child(createOption(SidebarOption.TYPE.MARKET))
		SidebarOption.TYPE.BUILD:
			sidebarOptions.add_child(createOption(SidebarOption.TYPE.COLONY))
			sidebarOptions.add_child(createOption(SidebarOption.TYPE.PRODUCTION))
			backOption(SidebarOption.TYPE.MAIN)
