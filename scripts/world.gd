extends Node2D

class_name World

@onready var map = $map
@onready var game = $game
@onready var ui = $canvas/ui

var tween : Tween
func _ready():
	$canvas/Transition.visible = true
	$canvas/Transition.material.set_shader_parameter("radius", 0.0)
	Event.saveGame.connect(saveGame)
	Event.loadScene.connect(loadScene)
	loadSaveSlotNames()
	if Global.loadSlot == 0: 
		Global.mapSize = Vector2i(24, 24)
		map.generateMap()
		game.initResources()
		game.startingResources()
	else:
		loadGame(Global.loadSlot)
		#print(map.buildingMap)
	#game.initResources()
	var spawn = await map.initMap()
	if Global.loadSlot == 0: 
		map.starterColony(spawn)
	game.camera.goTo(spawn)
	game.updateBudgets()
	ui.updateResourcebar()
	ui.makeSidebar(SidebarOption.TYPE.MAIN)
	map.updateAllBuildings()
	#print(map.activationMap)
	ui.nextTurnButton.initiate(Global.turn, Global.gameLength)
	tween = get_tree().create_tween()
	tween.set_parallel(false)
	tween.tween_property($canvas/Transition, "material:shader_parameter/radius", 1.0, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback($canvas/Transition.set_visible.bind(false))
	await tween.finished
	game.loaded = true
	tween.kill()

func loadScene(nextScene):
	$canvas/Transition.material.set_shader_parameter("radius", 1.0)
	$canvas/Transition.visible = true
	tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel(false)
	tween.tween_property($canvas/Transition, "material:shader_parameter/radius", 0.0, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	await get_tree().process_frame
	get_tree().change_scene_to_file(nextScene)

func _process(_delta):
	#if Input.is_action_just_pressed("debug"): Global.reserves[Global.RESOURCE.MONEY] = 0
	$camera/Stars.material.set_shader_parameter("offset", $camera.position)
	pass

func saveGame(slot):
	var saveData = {
		"colonyName":Global.colonyName,
		"turn":Global.turn,
		"score":Global.score,
		"reserves":Global.reserves,
		"trades":Global.trades,
		"buildings":map.getMapCode(map.buildingMap, true),
		"terrains":map.getMapCode(map.terrainMap),
		"altitudes":map.getMapCode(map.altitudeMap),
		"raws":map.getMapCode(map.rawMap),
		"activations":map.getMapCode(map.activationMap),
		"gameSize.x":Global.mapSize.x,
		"gameSize.y":Global.mapSize.y,
		"gameLength":Global.gameLength,
		"achievements":Global.achievementsToCode(),
		"buildingCount":Global.buildingCount,
		"cityCount":Global.cityCount,
		"mineCount":Global.mineCount,
		"version":"mainmenu"
	}
	var saveFile = FileAccess.open("user://save"+str(slot)+".json", FileAccess.WRITE)
	var jsonString = JSON.stringify(saveData)
	saveFile.store_line(jsonString)
	saveFile.close()
	var infolog: SingleOptionNotification = ui.singleOptionNotificationBlueprint.instantiate()
	ui.add_child(infolog)
	#ui.notifications.append(infolog)
	infolog.size = Vector2(256, 128)
	infolog.centerOnScreen()
	infolog.setContent("SAVED GAME", "Game successfully saved!")
	infolog.setOption("Okay")
	loadSaveSlotNames()
	await infolog.result
	Global.loadSlot = slot
	#ui.notifications.erase(infolog)
	infolog.queue_free()
	#print("Game Saved Successfully?")

func loadGame(slot) -> bool:
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
	Global.turn = int(saveData["turn"])
	Global.score = int(saveData["score"])
	Global.gameLength = int(saveData["gameLength"])
	game.initResources()
	#print(saveData["reserves"])
	for res in saveData["reserves"]:
		Global.reserves[int(res)] = int(saveData["reserves"][res])
	for res in saveData["trades"]:
		Global.trades[int(res)] = int(saveData["trades"][res])
	Global.mapSize = Vector2i(saveData["gameSize.x"], saveData["gameSize.y"])
	map.clearMaps()
	map.buildingMap = map.convertMapCode(saveData["buildings"], false)
	#print(map.buildingMap)
	map.terrainMap = map.convertMapCode(saveData["terrains"])
	map.altitudeMap = map.convertMapCode(saveData["altitudes"], false)
	#print(map.altitudeMap)
	map.rawMap = map.convertMapCodeFloat(saveData["raws"])
	map.activationMap = map.convertMapCodeBool(saveData["activations"], false)
	if "achievements" in saveData.keys(): Global.loadAchievements(saveData["achievements"])
	Global.buildingCount = saveData["buildingCount"]
	Global.cityCount = saveData["cityCount"]
	Global.mineCount = saveData["mineCount"]
	return true

func loadSaveSlotNames():
	for slot in range(1,4):
		Global.otherNames[slot] = "Save Slot " + str(slot)
		if not FileAccess.file_exists("user://save"+str(slot)+".json"):
			print("No save found.")
			continue
		var saveFile = FileAccess.open("user://save"+str(slot)+".json", FileAccess.READ)
		var jsonString = saveFile.get_line()
		var json = JSON.new()
		var parse = json.parse(jsonString)
		if not parse == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", jsonString, " at line ", json.get_error_line())
			continue
		var saveData = json.data
		saveFile.close()
		if "colonyName" in saveData: Global.otherNames[slot] = saveData["colonyName"] + "\nTurn " + str(int(saveData["turn"]))
		else: Global.otherNames[slot] = "Unnamed Colony" + "\nTurn " + str(int(saveData["turn"]))
