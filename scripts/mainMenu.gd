class_name MainMenu extends Control

@export var notificationBlueprint: PackedScene
@export var choiceNotificationBlueprint: PackedScene
@export var singleOptionNotificationBlueprint: PackedScene
@export var loadingNotificationBlueprint: PackedScene

@export var mainMenu : MarginContainer
@export var saveSlots : MarginContainer
@export var creditsMenu : MarginContainer

@export var newGame : Button
@export var loadGame : Button
@export var credits : Button
@export var quitGame : Button

@export var slot1 : Button
@export var slot2 : Button
@export var slot3 : Button
@export var saveBack : Button

@export var tileSubViewport : SubViewport
@export var map : Map
@export var ss1 : Map
@export var ss2 : Map
@export var ss3 : Map
@export var cursor : Cursor

@export var notifications : Control

var loaded = false

var tween : Tween

func _ready():
	$Transition.material.set_shader_parameter("radius", 0.0)
	Global.otherNames.clear()
	mainMenu.visible = true
	saveSlots.visible = true
	creditsMenu.visible = true
	saveSlots.position.x += saveSlots.size.x
	creditsMenu.position.x += creditsMenu.size.x
	Global.loadSlot = 0
	$Transition.visible = true
	loaded = false
	await initTiles()
	await preloadWorldPreviews(1)
	await preloadWorldPreviews(2)
	await preloadWorldPreviews(3)
	slot1.disabled = not checkSlot(1)
	slot2.disabled = not checkSlot(2)
	slot3.disabled = not checkSlot(3)
	$"SaveSlots/Panel/MarginContainer/VBoxContainer/1/Secondaries/Preview".disabled = not checkSlot(1)
	$"SaveSlots/Panel/MarginContainer/VBoxContainer/1/Secondaries/Trash".disabled = not checkSlot(1)
	$"SaveSlots/Panel/MarginContainer/VBoxContainer/2/Secondaries/Preview".disabled = not checkSlot(2)
	$"SaveSlots/Panel/MarginContainer/VBoxContainer/2/Secondaries/Trash".disabled = not checkSlot(2)
	$"SaveSlots/Panel/MarginContainer/VBoxContainer/3/Secondaries/Preview".disabled = not checkSlot(3)
	$"SaveSlots/Panel/MarginContainer/VBoxContainer/3/Secondaries/Trash".disabled = not checkSlot(3)
	loadMainMenuSave()
	tween = get_tree().create_tween()
	tween.set_parallel(false)
	tween.tween_property($Transition, "material:shader_parameter/radius", 1.0, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback($Transition.set_visible.bind(false))
	await tween.finished
	tween.kill()

func _on_credits_pressed():
	$MainMenu/sidebarCover.mouse_filter = Control.MOUSE_FILTER_STOP
	$Credits/sidebarCover.mouse_filter = Control.MOUSE_FILTER_STOP
	tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(mainMenu, "position", Vector2(mainMenu.position.x+mainMenu.size.x, mainMenu.position.y), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(creditsMenu, "position", Vector2(creditsMenu.position.x-creditsMenu.size.x, creditsMenu.position.y), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	tween.kill()
	$MainMenu/sidebarCover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Credits/sidebarCover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#mainMenu.visible = false
	#saveSlots.visible = true
	
func _on_load_game_pressed():
	$MainMenu/sidebarCover.mouse_filter = Control.MOUSE_FILTER_STOP
	$SaveSlots/sidebarCover.mouse_filter = Control.MOUSE_FILTER_STOP
	tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(mainMenu, "position", Vector2(mainMenu.position.x+mainMenu.size.x, mainMenu.position.y), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(saveSlots, "position", Vector2(saveSlots.position.x-saveSlots.size.x, saveSlots.position.y), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	tween.kill()
	$MainMenu/sidebarCover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$SaveSlots/sidebarCover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#mainMenu.visible = false
	#saveSlots.visible = true

func _on_back_pressed():
	$MainMenu/sidebarCover.mouse_filter = Control.MOUSE_FILTER_STOP
	$SaveSlots/sidebarCover.mouse_filter = Control.MOUSE_FILTER_STOP
	tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(saveSlots, "position", Vector2(saveSlots.position.x+saveSlots.size.x, saveSlots.position.y), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(mainMenu, "position", Vector2(mainMenu.position.x-mainMenu.size.x, mainMenu.position.y), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	tween.kill()
	$MainMenu/sidebarCover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$SaveSlots/sidebarCover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loadMainMenuSave()
	
func _on_credits_back_pressed():
	$MainMenu/sidebarCover.mouse_filter = Control.MOUSE_FILTER_STOP
	$Credits/sidebarCover.mouse_filter = Control.MOUSE_FILTER_STOP
	tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(creditsMenu, "position", Vector2(creditsMenu.position.x+creditsMenu.size.x, creditsMenu.position.y), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(mainMenu, "position", Vector2(mainMenu.position.x-mainMenu.size.x, mainMenu.position.y), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	tween.kill()
	$MainMenu/sidebarCover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Credits/sidebarCover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loadMainMenuSave()

func loadScene(nextScene):
	$Transition.material.set_shader_parameter("radius", 1.0)
	$Transition.visible = true
	tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(false)
	tween.tween_property($Transition, "material:shader_parameter/radius", 0.0, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	await get_tree().process_frame
	get_tree().change_scene_to_file(nextScene)

func _on_slot_1_pressed():
	var choice := choiceNotificationBlueprint.instantiate()
	notifications.add_child(choice)
	choice.size = Vector2(256, 216)
	choice.centerOnScreen()
	choice.setContent("[img]res://resources/uiTrimIcons/load.tres[/img] Load Slot 1", "This will load your game saved on Save Slot 1.")
	choice.setChoices("Proceed?")
	var result = await choice.getChoice()
	if result: 
		Global.loadSlot = 1
		loadScene("res://scenes/world.tscn")
	else: return

func _on_slot_2_pressed():
	var choice := choiceNotificationBlueprint.instantiate()
	notifications.add_child(choice)
	choice.size = Vector2(256, 216)
	choice.centerOnScreen()
	choice.setContent("[img]res://resources/uiTrimIcons/load.tres[/img] Load Slot 2", "This will load your game saved on Save Slot 2.")
	choice.setChoices("Proceed?")
	var result = await choice.getChoice()
	if result: 
		Global.loadSlot = 2
		loadScene("res://scenes/world.tscn")
	else: return

func _on_slot_3_pressed():
	var choice := choiceNotificationBlueprint.instantiate()
	notifications.add_child(choice)
	choice.size = Vector2(256, 216)
	choice.centerOnScreen()
	choice.setContent("[img]res://resources/uiTrimIcons/load.tres[/img] Load Slot 3", "This will load your game saved on Save Slot 3.")
	choice.setChoices("Proceed?")
	var result = await choice.getChoice()
	if result: 
		Global.loadSlot = 3
		loadScene("res://scenes/world.tscn")
	else: return

func _on_quit_game_pressed():
	get_tree().quit()

func _on_new_game_pressed():
	Global.loadSlot = 0
	loadScene("res://scenes/world.tscn")

var save = {}

func initTiles():
	mapID = 0
	loaded = false
	Global.mapSize = Vector2i(40, 40)
	for tile in map.tileMap.values():
		tile.queue_free()
	map.global_position.x = Global.tileSize.x*Global.mapSize.x/8
	map.global_position.y = -Global.tileSize.y*Global.mapSize.y/3
	map.tileMap.clear()
	map.clearMaps()
	map.generateMap()
	#var ln = createLoadingNotification(Vector2(480, 216), "Loading Map", "Please wait while the map loads.", "Close Notification")
	#var callback = Callable(self, "reportProgress")
	var spawn = await map.initMapPM()
	map.global_position = Vector2(480, -480)
	if Global.loadSlot == 0: 
		map.starterColony(spawn)
	#map.updateAllBuildings()
	#$Tiles/TileContainer/SubViewport/camera.goTo(spawn)
	#cursor.global_position = map.global_position
	var ogSpawn = spawn
	var ran = randi_range(1, 2) * [1, -1].pick_random()
	spawn.x += ran
	map.createBuilding(spawn, Global.BUILDING.SPACEPORT, true)
	if abs(ran) == 2: map.createBuilding(Vector2i(spawn.x - ran/2, spawn.y), Global.BUILDING.ROAD, true)
	spawn = ogSpawn
	ran = randi_range(1, 2) * [1, -1].pick_random()
	spawn.y += ran
	map.createBuilding(spawn, Global.BUILDING.NUCLEAR_PLANT, true)
	if abs(ran) == 2: map.createBuilding(Vector2i(spawn.x, spawn.y - ran/2), Global.BUILDING.ROAD, true)
	ran = randi_range(1, 2) * [1, -1].pick_random()
	spawn.x += ran
	print("sh")
	map.createBuilding(spawn, Global.BUILDING.CIVILIAN_FACTORY, true)
	if abs(ran) == 2: map.createBuilding(Vector2i(spawn.x - ran/2, spawn.y), Global.BUILDING.ROAD, true)
	"""self.save = {"buildings":map.getMapCode(map.buildingMap, true),
		"terrains":map.getMapCode(map.terrainMap),
		"altitudes":map.getMapCode(map.altitudeMap),
		"raws":map.getMapCode(map.rawMap),
		"activations":map.getMapCode(map.activationMap),
		"gameSize.x":Global.mapSize.x,
		"gameSize.y":Global.mapSize.y}"""
	#ln.progressBar.value = 100
	loaded = true

func selectNewTile(tile: Vector2i):
	cursor.deselect()
	cursor.tile = tile
	#cursor.position = map.tileMap[tile].position + Vector2(Global.tileSize.x*Global.mapSize.x/8, -Global.tileSize.y*Global.mapSize.y/3)
	#cursor.display.position.y = map.tileMap[tile].display.position.y - Global.tileSize.y/4
	cursor.select()

func _on_new_game_mouse_entered():
	if loaded and mapID == 0 and not Global.selected: selectNewTile(map.buildingMap.find_key(Global.BUILDING.NUCLEAR_PLANT))

func _on_load_game_mouse_entered():
	if loaded and mapID == 0 and not Global.selected: selectNewTile(map.buildingMap.find_key(Global.BUILDING.SPACEPORT))

func _on_credits_mouse_entered():
	if loaded and mapID == 0 and not Global.selected: selectNewTile(map.buildingMap.find_key(Global.BUILDING.CIVILIAN_FACTORY))

func deselect_cursor():
	if Global.selected: 
		cursor.deselect()

var mapID = 0

func loadMainMenuSave():
	mapID = 0
	loaded = false
	map.visible = true
	ss1.visible = false
	ss2.visible = false
	ss3.visible = false
	"""var saveData = save
	Global.mapSize = Vector2i(saveData["gameSize.x"], saveData["gameSize.y"])
	map.clearMaps()
	for tile in map.tileMap.values():
		tile.queue_free()
	map.tileMap.clear()
	map.global_position.x = Global.tileSize.x*Global.mapSize.x/8
	map.global_position.y = -Global.tileSize.y*Global.mapSize.y/3
	map.buildingMap = map.convertMapCode(saveData["buildings"], false)
	map.terrainMap = map.convertMapCode(saveData["terrains"])
	map.altitudeMap = map.convertMapCode(saveData["altitudes"], false)
	map.rawMap = map.convertMapCodeFloat(saveData["raws"])
	map.activationMap = map.convertMapCodeBool(saveData["activations"], false)
	var ln = createLoadingNotification(Vector2(480, 216), "Loading Map", "Please wait while the map loads.", "Close Notification")
	var callback = Callable(self, "reportProgress")
	await map.initMapWithCallback(callback)
	map.updateAllBuildings()
	map.global_position.x = Global.tileSize.x*Global.mapSize.x/8
	map.global_position.y = -Global.tileSize.y*Global.mapSize.y/3
	ln.progressBar.value = 100"""
	loaded = true

func reportProgress(percent: float) -> void:
	$Transition.material.set_shader_parameter("animation_progress", 1-percent)
	#Event.updateProgressBar.emit(percent)

func createLoadingNotification(notifSize: Vector2, title: String, content: String, buttonLabel: String) -> LoadingNotification:
	var loadingNotif := loadingNotificationBlueprint.instantiate()
	notifications.add_child(loadingNotif)
	loadingNotif.size = notifSize
	loadingNotif.centerOnScreen()
	loadingNotif.setContent(title, content)
	loadingNotif.setOption(buttonLabel)
	return loadingNotif

func loadWorldPreview(slot: int):
	map.visible = false
	ss1.visible = false
	ss2.visible = false
	ss3.visible = false
	match slot:
		1: ss1.visible = true
		2: ss2.visible = true
		3: ss3.visible = true

func preloadWorldPreviews(slot: int):
	if not checkSlot(slot): return
	mapID = slot
	loaded = false
	var pmap : Map
	match slot:
		1: pmap = ss1
		2: pmap = ss2
		3: pmap = ss3
	if not FileAccess.file_exists("user://save"+str(slot)+".json"):
		print("No save found.")
		return false
	var saveFile = FileAccess.open("user://save"+str(slot)+".json", FileAccess.READ)
	var jsonString = saveFile.get_line()
	var json = JSON.new()
	var parse = json.parse(jsonString)
	if not parse == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", jsonString, " at line ", json.get_error_line())
		return false
	var saveData = json.data
	saveFile.close()
	if "colonyName" in saveData.keys():
		Global.otherNames[slot] = (saveData["colonyName"])
		match slot:
			1: slot1.text = saveData["colonyName"] + "\nTurn " + str(int(saveData["turn"]))
			2: slot2.text = saveData["colonyName"] + "\nTurn " + str(int(saveData["turn"]))
			3: slot3.text = saveData["colonyName"] + "\nTurn " + str(int(saveData["turn"]))
	else:
		match slot:
			1: slot1.text = "Unnamed Colony" + "\nTurn " + str(int(saveData["turn"]))
			2: slot2.text = "Unnamed Colony" + "\nTurn " + str(int(saveData["turn"]))
			3: slot3.text = "Unnamed Colony" + "\nTurn " + str(int(saveData["turn"]))
	Global.mapSize = Vector2i(saveData["gameSize.x"], saveData["gameSize.y"])
	pmap.clearMaps()
	for tile in pmap.tileMap.values():
		tile.queue_free()
	pmap.tileMap.clear()
	pmap.buildingMap = pmap.convertMapCode(saveData["buildings"], false)
	pmap.terrainMap = pmap.convertMapCode(saveData["terrains"])
	pmap.altitudeMap = pmap.convertMapCode(saveData["altitudes"], false)
	pmap.rawMap = pmap.convertMapCodeFloat(saveData["raws"])
	pmap.activationMap = pmap.convertMapCodeBool(saveData["activations"], false)
	pmap.global_position.x = Global.tileSize.x*Global.mapSize.x/5
	pmap.global_position.y = -Global.tileSize.y*Global.mapSize.y/5
	#var ln = createLoadingNotification(Vector2(480, 216), "Loading Map", "Please wait while the map loads.", "Close Notification")
	#var callback = Callable(self, "reportProgress")
	await pmap.initMapPM()
	pmap.global_position = Vector2(-32, 0)
	pmap.updateAllBuildings()
	#ln.progressBar.value = 100
	loaded = true

func confirmDeletion(slot: int):
	var choice := choiceNotificationBlueprint.instantiate()
	notifications.add_child(choice)
	choice.size = Vector2(300, 216)
	choice.centerOnScreen()
	choice.setContent("[color=990000ff][img]res://resources/uiTrimIcons/trash.tres[/img] Delete Slot "+str(slot)+"[/color]",
			"This will [color=990000ff]delete[/color] your game on Slot "+str(slot)+". \n[color=990000ff]THIS CANNOT BE UNDONE.[/color]")
	choice.setChoices("[font_size=32][color=990000ff]ARE YOU SURE?[/color][/font_size]")
	var result = await choice.getChoice()
	if result: 
		deleteSlot(slot)
		if mapID != 0: initTiles()

func checkSlot(slot: int):
	var file_path: String = "user://save"+str(slot)+".json"
	return FileAccess.file_exists(file_path)

func deleteSlot(slot: int):
	var file_path: String = "user://save"+str(slot)+".json"
	# Check if the file actually exists first
	if FileAccess.file_exists(file_path):
		# Attempt to remove the file
		var error = DirAccess.remove_absolute(file_path)
		if error == OK: 
			#print("JSON file deleted successfully!")
			if slot == 1:
				slot1.disabled = true
				$"SaveSlots/Panel/MarginContainer/VBoxContainer/1/Secondaries/Preview".disabled = true
				$"SaveSlots/Panel/MarginContainer/VBoxContainer/1/Secondaries/Trash".disabled = true
			if slot == 2:
				slot2.disabled = true
				$"SaveSlots/Panel/MarginContainer/VBoxContainer/2/Secondaries/Preview".disabled = true
				$"SaveSlots/Panel/MarginContainer/VBoxContainer/2/Secondaries/Trash".disabled = true
			if slot == 3:
				slot3.disabled = true
				$"SaveSlots/Panel/MarginContainer/VBoxContainer/3/Secondaries/Preview".disabled = true
				$"SaveSlots/Panel/MarginContainer/VBoxContainer/3/Secondaries/Trash".disabled = true
			loadMainMenuSave()
		else: print("Failed to delete file. Error code: ", error)
	else: print("File does not exist.")

func _on_notification_container_child_entered_tree(_node):
	#print(notifications.get_child_count())
	if not notifications.get_child_count() <= 0: 
		#print("yo")
		$MainMenu/sidebarCover.mouse_filter = Control.MOUSE_FILTER_STOP
		$SaveSlots/sidebarCover.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_notification_container_child_exiting_tree(_node):
	if notifications.get_child_count() - 1 == 0:
		#print("oy") 
		$MainMenu/sidebarCover.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$SaveSlots/sidebarCover.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta):
	$Panel.rotation += 1

func debug():
	loadMainMenuSave()

func _on_content_meta_clicked(meta):
	OS.shell_open(str(meta))
