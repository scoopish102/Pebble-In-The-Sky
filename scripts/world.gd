extends Node2D

class_name World

@onready var map = $map
@onready var game = $game
@onready var ui = $canvas/ui

func _ready():
	Event.saveGame.connect(saveGame)
	if Global.loadSlot == 0: 
		map.generateMap()
		game.initResources()
		game.startingResources()
	else:
		loadGame(Global.loadSlot)
		#print(map.buildingMap)
	#game.initResources()
	var spawn = map.initMap()
	if Global.loadSlot == 0: 
		map.starterColony(spawn)
	game.camera.goTo(spawn)
	game.updateBudgets()
	ui.updateResourcebar()
	map.updateAllBuildings()
	#print(map.activationMap)

func _process(_delta):
	#if Input.is_action_just_pressed("debug"): Global.reserves[Global.RESOURCE.MONEY] = 0
	pass

func saveGame(slot):
	var saveData = {
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
		"version":"adjacency"
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
	await infolog.result
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
	return true
