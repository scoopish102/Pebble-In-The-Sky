extends Control

@export var sidebar : Control
@export var resourcebar : Control
@export var sidebarOptions : VBoxContainer
@export var resourcebarOptions : HBoxContainer
@export var resourceCategory : PanelContainer
@export var categoryName : Label
@export var minimap : Minimap
@export var notifications : Control
@export var sidebarCover : Panel
@export var scoringPanel : Panel
@export var categoryButtons : Array[Button]
@export var nextTurnButton : Panel

@export var resourceBlueprint : PackedScene
@export var optionBlueprint : PackedScene
@export var ynaBlueprint : PackedScene
@export var sLabelBlueprint : PackedScene
@export var infoBoxBlueprint : PackedScene
@export var tradeOptionBlueprint : PackedScene
@export var notificationBlueprint: PackedScene
@export var choiceNotificationBlueprint: PackedScene
@export var singleOptionNotificationBlueprint: PackedScene

@export var scoringPanelTitle : RichTextLabel
@export var scoringPanelContent : RichTextLabel
@export var leaderboard : RichTextLabel

@export var showBuildingIcon: Texture
@export var hideBuildingIcon: Texture

var leaders = [
	"1. Leto II",
	"2. Luo Ji",
	"3. Salvor Hardin",
	"4. Yang Wen-Li",
	"5. Chrisjen Avasarala",
	"6. Locke (Peter Wiggin)",
	"7. Jonathan Archer",
	"8. Bernardo de la Paz",
	"9. Mustapha Mond",
	"10. Hannegan II",
	"11. Cleon II",
	"12. Palpatine",
	"13. Shaddam Corrino IV",
	"14. Achilles de Flandres",
	"15. Manuel Rey Diaz"
]

var leaderScores = [
	150000, #Leto
	100000, #Luo
	90000, #Hardin
	80000, #Yang
	70000, #Avasarala
	60000, #Locke
	50000, #Archer
	40000, #Bernardo
	30000, #Mond
	20000, #Hannegan
	10000, #Cleon
	7500, #Palpatine
	5000, #Shaddam
	2500, #Achilles
	1000, #Rey Diaz
]

var leaderQuotes = [
	"The only rule governing creativity is the act of creation itself.",
	"Staying alive is not enough to guarantee survival. Development is the best way to ensure survival.",
	"Violence is the last refuge of the incompetent.",
	"People tend to make the common mistake of believing that a situation will last forever.",
	"A whisper will do, if it's all that you can manage.",
	"The power to cause pain is the only power that matters, the power to kill and destroy.",
	"A few courageous people began to realize they could make a difference.",
	"I am free, no matter what rules surround me.",
	"Civilization has no need of nobility or heroism.",
	"To minimize suffering and to maximize security were natural and proper ends of society and Caesar.",
	"What kept Cleon strong? It's obvious. He is strong, because he permits no strong subjects.",
	"I am the Senate.",
	"Now we see true motives.",
	"Stay right with God. I'll stay right with Achilles.",
	"My people... I did it all for you!"
]

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
	Event.cancel_trade_confirmation.connect(cancelTradeConfirmation)
	#Event.tileSelected.connect(openTileInfo)
	#Event.tileDeselected.connect(closeTileInfo)
	get_tree().get_root().size_changed.connect(windowSizeChanged)
	windowSizeChanged()
	makeSidebar(SidebarOption.TYPE.MAIN)
	scoringPanel.visible = false
	#updateResourcebar()

func _process(_delta):
	if Input.is_action_just_pressed("1"): changeResourceMenu(0)
	if Input.is_action_just_pressed("2"): changeResourceMenu(1)
	if Input.is_action_just_pressed("3"): changeResourceMenu(2)
	if Input.is_action_just_pressed("4"): changeResourceMenu(3)
	if Input.is_action_just_pressed("5"): changeResourceMenu(4)
	if Input.is_action_just_pressed("6"): changeResourceMenu(5)
	if Input.is_action_just_pressed("7"): changeResourceMenu(6)
	if Input.is_action_just_pressed("8"): changeResourceMenu(7)

#func openTileInfo(tile, terrain, building, activation, altitude): pass
#func closeTileInfo(): pass

var showSidebar = false
var stringToType = {
	&"market":SidebarOption.TYPE.MARKET, &"tech":SidebarOption.TYPE.MARKET,
	&"politics":SidebarOption.TYPE.MARKET, &"save":SidebarOption.TYPE.SAVE,
	&"build":SidebarOption.TYPE.BUILD
}

func _on_button_toggled(toggled_on, emitter, type: StringName):
	if toggled_on:
		if not showSidebar: openSidebar(stringToType[type])
		else: 
			for button in categoryButtons: 
				if button != emitter: button.set_pressed_no_signal(false)
			makeSidebar(stringToType[type])
	else: 
		#print("lumbagos")
		closeSidebar()

func windowSizeChanged():
	var screenSize = get_viewport_rect().size
	if showSidebar: sidebar.position.x = screenSize.x-sidebar.size.x
	else: sidebar.position.x = screenSize.x

var tween : Tween

func openSidebar(type: SidebarOption.TYPE): 
	showSidebar = true
	makeSidebar(type)
	var screenSize = get_viewport_rect().size
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(sidebar, "position:x", screenSize.x-sidebar.size.x, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func closeSidebar(): 
	showSidebar = false
	for button in categoryButtons:
		button.set_pressed_no_signal(false)
	var screenSize = get_viewport_rect().size
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(sidebar, "position:x", screenSize.x, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func changeResourceMenu(index: int):
	categoryIndex = index
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
	return back

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

func displayCurrentTrades():
	createSidebarLabel("Current Trades")
	var currentTrades = 0
	for resource in Global.trades.keys(): 
		if Global.trades[resource] != 0:
			#print(resource)
			quickTradeInterface(resource)
			currentTrades += 1
	if currentTrades == 0:
		var info = sLabelBlueprint.instantiate()
		info.label.text = ("Right now, your colony has no active trade routes." + 
				"\nTrade routes are created when you buy or sell resources on the market." + 
				"\nIncrease your maximum trade capacity by building Spaceports.")
		sidebarOptions.add_child(info)

func createSidebarLabel(text):
	var slabel = sLabelBlueprint.instantiate()
	slabel.label.text = text
	sidebarOptions.add_child(slabel)
	return slabel

func quickTradeInterface(resource : Global.RESOURCE):
	var option = createOption(SidebarOption.TYPE.QUICKTRADE)
	option.resource = resource
	option.init(SidebarOption.TYPE.QUICKTRADE)
	option.quickTradeLabel(resource)
	#print(option.resource)
	#sidebarOptions.add_child(option)

func createMarket():
	for resource in Global.trades:
		createTradeOption(resource)

func createTradeOption(resource : Global.RESOURCE): 
	var option = createOption(SidebarOption.TYPE.TRADE)
	option.resource = resource
	option.init(SidebarOption.TYPE.TRADE)
	#sidebarOptions.add_child(option)

func clearSidebar():
	#print("cho")
	for option in sidebarOptions.get_children():
		option.queue_free()

func makeSidebar(option : SidebarOption.TYPE):
	clearSidebar()
	#print(option)
	match option:
		SidebarOption.TYPE.MAIN:
			#generateAchievementLog()
			#createOption(SidebarOption.TYPE.BUILD)
			#createOption(SidebarOption.TYPE.ACT)
			#createOption(SidebarOption.TYPE.MARKET)
			#createOption(SidebarOption.TYPE.NEXT_TURN)
			#createOption(SidebarOption.TYPE.SAVE)
			#createOption(SidebarOption.TYPE.EXIT)
			pass
		SidebarOption.TYPE.BUILD:
			createSidebarLabel("Build Menu")
			createOption(SidebarOption.TYPE.COLONY)
			createOption(SidebarOption.TYPE.POWER)
			createOption(SidebarOption.TYPE.HARVEST)
			createOption(SidebarOption.TYPE.PRODUCTION)
			createOption(SidebarOption.TYPE.MANUFACTORY)
			#backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.ACT:
			createOption(SidebarOption.TYPE.DEMOLISH)
			createActivateOption()
			#backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.MARKET:
			createSidebarLabel("Market Menu")
			createOption(SidebarOption.TYPE.CURRENT_TRADES)
			createMarket()
			#backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.CURRENT_TRADES:
			displayCurrentTrades()
			backOption(SidebarOption.TYPE.MARKET)
		SidebarOption.TYPE.SAVE:
			createSidebarLabel("Save and Exit")
			createOption(SidebarOption.TYPE.SLOT_1)
			createOption(SidebarOption.TYPE.SLOT_2)
			createOption(SidebarOption.TYPE.SLOT_3)
			createOption(SidebarOption.TYPE.EXIT)
			#backOption(SidebarOption.TYPE.MAIN)
		SidebarOption.TYPE.COLONY:
			createSidebarLabel("Colony Buildings")
			createBuildingOption(Global.BUILDING.CITY)
			createBuildingOption(Global.BUILDING.ROAD)
			createBuildingOption(Global.BUILDING.SPACEPORT)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.POWER:
			createSidebarLabel("Power Buildings")
			createBuildingOption(Global.BUILDING.SOLAR_FARM)
			createBuildingOption(Global.BUILDING.NUCLEAR_PLANT)
			createBuildingOption(Global.BUILDING.FUSION_PLANT)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.HARVEST:
			createSidebarLabel("Harvesters")
			createBuildingOption(Global.BUILDING.MINE)
			createBuildingOption(Global.BUILDING.QUARRY)
			createBuildingOption(Global.BUILDING.ICE_MINE)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.PRODUCTION:
			createSidebarLabel("Production Buildings")
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
			createSidebarLabel("Manufactories")
			createBuildingOption(Global.BUILDING.ELECTRONICS_FACTORY)
			createBuildingOption(Global.BUILDING.CIVILIAN_FACTORY)
			backOption(SidebarOption.TYPE.BUILD)
		SidebarOption.TYPE.SCORE:
			scoringPanel.visible = true
			closeSidebar()
			scoringPanelTitle.text = "Colony of" + Global.colonyName + "- [color=000099ff]" + str(Global.score) + "[img]res://resources/resIcons/score.tres[/img] Score[/color]"
			leaderboard.text = generateLeaderboard()
			scoringPanelContent.text = generateAchievementLog()
			createOption(SidebarOption.TYPE.EXIT)
			backOption(SidebarOption.TYPE.MAIN).label.set_text("CONTINUE GAME")
	sidebarMenu = option

func generateLeaderboard():
	var text = ""
	var scored = false
	for leader in range(len(leaders)):
		text += leaders[leader] + " - "
		if Global.score > leaderScores[leader] and not scored: text += "[color=000099ff]"
		text += str(leaderScores[leader]) + " Score"
		if Global.score > leaderScores[leader] and not scored: 
			text += "\n" + leaderQuotes[leader] + "[/color]"
			scored = true
		text += "\n"
	return text

func generateAchievementLog():
	var text = ""
	var sorted = Global.achievementsRecord.keys()
	sorted.sort_custom(func(a, b): return Global.achievementsRecord[a].to_int() < Global.achievementsRecord[b].to_int())
	for achievement in sorted:
		text += Global.achievementNames[achievement] + " on turn " + Global.achievementsRecord[achievement] + ".\n"
		#print(Global.achievementNames[achievement], ": ", Global.achievementsRecord[achievement])
	return text

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

func camelConversion(input: String) -> String:
	var words: PackedStringArray = input.to_lower().split("_")
	var camel_case: String = ""
	for i in range(0, words.size()):
		camel_case += words[i].capitalize()
	return camel_case

func askConfirmationNextTurn():
	clearSidebar()
	var slabel : SidebarLabel = sLabelBlueprint.instantiate()
	sidebarOptions.add_child(slabel)
	if Global.turn >= Global.gameLength: slabel.label.text = "Finish Game?"
	else: slabel.label.set_text("Advance to Next Turn?")
	var cob = []
	var supercob = []
	for res in Global.budgets.keys():
		if Global.budgets[res] < 0:
			cob.append(res)
		if Global.reserves[res] + Global.budgets[res] < 0:
			supercob.append(res)
	if len(cob) > 0: 
		slabel.label.text += "\n[color=ffff00ff]Warning: You currently have a deficit of"
		var cobcount = 0
		for res in cob:
			slabel.label.text += " " + camelConversion(str(Global.RESOURCE.keys()[res]))
			cobcount += 1
			if cobcount == len(cob): continue
			elif cobcount == len(cob)-1: slabel.label.text += " and"
			else: slabel.label.text += ","
		slabel.label.text += ".[/color]"
		if Global.turn >= Global.gameLength: slabel.label.text += ("\n[color=ffff00ff]FINISHING THE GAME"
				+ " WITH A DEFICIT IN ANY RESOURCE WILL REDUCE YOUR SCORE BY 10% AND SUBTRACT IT BY 2500 PER RESOURCE.[/color]")
	if len(supercob) > 0: 
		slabel.label.text += "\n[color=990000ff]Warning: You will have a debt of"
		var cobcount = 0
		for res in supercob:
			slabel.label.text += " " + camelConversion(str(Global.RESOURCE.keys()[res]))
			cobcount += 1
			if cobcount == len(supercob): continue
			elif cobcount == len(supercob)-1: slabel.label.text += " and"
			else: slabel.label.text += ","
		slabel.label.text += " if you continue to the next turn now.[/color]"
		if Global.turn >= Global.gameLength: slabel.label.text += ("\n[color=990000ff]FINISHING THE GAME"
				+ " WITH A DEBT IN ANY RESOURCE WILL HALVE YOUR SCORE AND SUBTRACT IT BY 5000 PER RESOURCE.[/color]")
	if Global.turn >= Global.gameLength: slabel.label.text += ("\n[color=000099ff]Are you SURE you want to finish this game now?[/color]")
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
		if not yna.building: 
			slabel.label.set_text("[color=990000ff]There is no building at " + str(tile)+"[/color]")
			return
		yna.energyWorks = yna.checkEnergy(yna.building, selectedActivated)
		yna.laborWorks = yna.checkLabor(yna.building, selectedActivated)
		if yna.building != Global.BUILDING.ROAD and not Global.buildingBudgets[yna.building] is bool:
			if &"DEPOSIT" in Global.buildingBudgets[yna.building].keys(): 
				var depositType = Global.depositToResource[selectedTerrain]
				yna.budgetWorks = yna.checkOtherBudgets(yna.building, selectedActivated, depositType)
			else: yna.budgetWorks = yna.checkOtherBudgets(yna.building, selectedActivated)
		else: yna.budgetWorks = true
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
							slabel.label.text += ("[color=990000ff]This building consumes resources that the colony does not have."+
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

func quickNotif(title : String, content : String, option : String = "Okay."):
	var notif := singleOptionNotificationBlueprint.instantiate()
	notifications.add_child(notif)
	notif.size.x = 380
	notif.centerOnScreen()
	notif.setContent(title, content)
	notif.setOption(option)

func quickConfirm(title : String, content : String):
	var notif := choiceNotificationBlueprint.instantiate()
	notifications.add_child(notif)
	notif.size.x = 380
	notif.centerOnScreen()
	notif.setContent(title, content)
	notif.setChoices("Confirm Action?")

func cancelTradeConfirmation(resource):
	var tradeCannotCancel = ((Global.reserves[Global.RESOURCE.MONEY] + Global.budgets[Global.RESOURCE.MONEY] - 
			Global.trades[resource] * Global.resourcePrices[resource]) < 0 or 
			(Global.reserves[resource] + Global.budgets[resource] - 
			Global.trades[resource] * Global.resourcePrices[resource]) < 0)
	if tradeCannotCancel: 
		var notif := singleOptionNotificationBlueprint.instantiate()
		notifications.add_child(notif)
		notif.size.x = 420
		notif.centerOnScreen()
		var ttext = "Currently "
		if Global.trades[resource] > 0: ttext += "buying "
		else: ttext += "selling "
		ttext += str(abs(Global.trades[resource])) + " [img]" + Global.resIcons[resource] + "[/img] "
		if resource == Global.RESOURCE.CIVGOODS: ttext += "Civilian Goods per turn."
		else: ttext += (camelConversion(str(Global.RESOURCE.keys()[resource]))) + " per turn."
		#ttext += "\nThis consumes " + str(abs(Global.trades[resource])) + " [img]" + Global.resIcons[Global.RESOURCE.TRADE] + "[/img] Trade Capacity."
		ttext += "\nThis trade "
		if Global.trades[resource] > 0: ttext += "costs "
		else: ttext += "sells for "
		ttext += str(abs(Global.trades[resource]*Global.resourcePrices[resource])) + " [img]" + Global.resIcons[Global.RESOURCE.MONEY] + "[/img] Money per turn."
		if (Global.reserves[resource] + Global.budgets[resource] - 
			Global.trades[resource] * Global.resourcePrices[resource]) < 0:
			ttext += "\nYou cannot cancel this trade, as your colony relies on the resources gained from this trade."
		if (Global.reserves[Global.RESOURCE.MONEY] + Global.budgets[Global.RESOURCE.MONEY] - 
			Global.trades[resource] * Global.resourcePrices[resource]) < 0:
			ttext += "\nYour colony relies on the profit gained from this trade."
		notif.setContent("[color=990000ff]Cannot Cancel Trade Route.[/color]", ttext, 36)
		#notif.fixHeight(48)
		notif.setOption("Okay.")
		return
	else:
		var choice := choiceNotificationBlueprint.instantiate()
		notifications.add_child(choice)
		choice.size.x = 420
		choice.centerOnScreen()
		var ttext = "Currently "
		if Global.trades[resource] > 0: ttext += "buying "
		else: ttext += "selling "
		ttext += str(abs(Global.trades[resource])) + " [img]" + Global.resIcons[resource] + "[/img] "
		if resource == Global.RESOURCE.CIVGOODS: ttext += "Civilian Goods every turn."
		else: ttext += (camelConversion(str(Global.RESOURCE.keys()[resource]))) + " per turn."
		ttext += "\nCancelling this trade route will free up " + str(abs(Global.trades[resource])) + " [img]" + Global.resIcons[Global.RESOURCE.TRADE] + "[/img] Trade Capacity."
		choice.setContent("[img]"+Global.resIcons[resource]+"[/img]"+" Trade Route Cancellation", ttext, 36)
		choice.setChoices("Cancel This Trade Route?")
		#choice.fixHeight(36)
		var result = await choice.getChoice()
		if result:
			Global.trades[resource] = 0
			Event.update_resources.emit()
			makeSidebar(SidebarOption.TYPE.CURRENT_TRADES)
			return
		else: return

func confirmSave(slot):
	var choice := choiceNotificationBlueprint.instantiate()
	notifications.add_child(choice)
	choice.size.x = 256
	choice.setContent("[img]res://resources/uiTrimIcons/save.tres[/img] Save Game", "This will save your game on Slot " + str(slot) + ".")
	choice.setChoices("Proceed?")
	choice.centerOnScreen()
	#print(choice)
	var result = await choice.getChoice()
	if result: 
		Event.saveGame.emit(slot)
		return
	else: return

func deleteSlot(slot: int):
	var file_path: String = "user://save"+str(slot)+".json"
	# Check if the file actually exists first
	if FileAccess.file_exists(file_path):
		# Attempt to remove the file
		var error = DirAccess.remove_absolute(file_path)
		if error == OK: 
			#print("JSON file deleted successfully!")
			pass
		else: print("Failed to delete file. Error code: ", error)
	else: print("File does not exist.")

func confirmExit():
	var choice := choiceNotificationBlueprint.instantiate()
	notifications.add_child(choice)
	choice.size.x = 256
	choice.centerOnScreen()
	if sidebarMenu != SidebarOption.TYPE.SCORE: 
		choice.setContent("[img]res://resources/uiTrimIcons/exit.tres[/img] Exit Game", "This will send you to the main menu. Make sure to save your game first.")
		choice.setChoices("Exit without saving?")
	else:
		choice.setContent("[img]res://resources/uiTrimIcons/exit.tres[/img] Exit Completed Game", 
				"This will send you to the main menu.")
		if Global.loadSlot != 0: choice.content.text += "You may not be able to return, since this save slot, slot " + str(Global.loadSlot) + " will be wiped!"
		choice.setChoices("Finish game?")
	var result = await choice.getChoice()
	if result: 
		if sidebarMenu == SidebarOption.TYPE.SCORE and Global.loadSlot != 0: deleteSlot(Global.loadSlot)
		Event.loadScene.emit("res://scenes/mainMenu.tscn")#get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
	else: return
		#scoringPanel.visible = false

func directToPostConfirmation(option : SidebarOption.TYPE):
	match option:
		SidebarOption.TYPE.SLOT_1:
			#print("lols")
			await confirmSave(1)
		SidebarOption.TYPE.SLOT_2:
			await confirmSave(2)
		SidebarOption.TYPE.SLOT_3:
			await confirmSave(3)
		SidebarOption.TYPE.EXIT:
			await confirmExit()
	Event.deselect_cursor.emit()
	makeSidebar(sidebarMenu)

func endGame():
	Event.deselect_cursor.emit()
	Global.score += Global.budgets[Global.RESOURCE.WEALTH]+Global.budgets[Global.RESOURCE.INDUSTRY]+Global.budgets[Global.RESOURCE.INFLUENCE]
	makeSidebar(SidebarOption.TYPE.SCORE)

func beginNextTurn():
	Event.next_turn.emit()
	updateResourcebar()

func postConfirmation(confirm : bool, option : SidebarOption.TYPE, building, startActivated=true):
	#print("postconfirm")
	if confirm:
		match option:
			SidebarOption.TYPE.BUILDING:
				if not building is bool:
					subtractCost(building)
					Event.create_building.emit(Global.selectedTile, building, startActivated)
			SidebarOption.TYPE.NEXT_TURN:
				if Global.turn == Global.gameLength: 
					Event.deselect_cursor.emit()
					Global.score += Global.budgets[Global.RESOURCE.WEALTH]+Global.budgets[Global.RESOURCE.INDUSTRY]+Global.budgets[Global.RESOURCE.INFLUENCE]
					makeSidebar(SidebarOption.TYPE.SCORE)
					return
				else:
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

func _on_notification_container_child_entered_tree(_node):
	#print(notifications.get_child_count())
	if not notifications.get_child_count() <= 0: 
		#print("yo")
		sidebarCover.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_notification_container_child_exiting_tree(_node):
	if notifications.get_child_count() - 1 == 0:
		#print("oy") 
		sidebarCover.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_buildings_toggled(toggled_on):
	Global.hideBuildings = not toggled_on
	Event.updateTileAppearances.emit()
	if toggled_on: minimap.showbuildingButton.icon = showBuildingIcon
	else: minimap.showbuildingButton.icon = hideBuildingIcon

func _on_shade_toggled(toggled_on):
	Global.shadeUnselected = toggled_on
	Event.updateTileAppearances.emit()
