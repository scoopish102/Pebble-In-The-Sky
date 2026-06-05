extends Node2D

class_name Map

@export var tileBlueprint : PackedScene
var altitudeMap = {}
var terrainMap = {}
var rawMap = {}
var tileMap = {} #contains indexed references to ALL tile nodes, organized by tile position
var buildingMap = {}
var activationMap = {}
var noise = preload("res://resources/altitudeNoise.tres")

func _ready():
	randomize()
	Event.create_building.connect(createBuilding)
	Event.toggle_activation.connect(toggleActivation)

func getMapCode(map, _debug=false) -> String:
	var code: String = ""
	for index in map.keys():
		code += str(index.x) + "," + str(index.y) + ":" + str(map[index]) + ";"
	code = code.erase(code.length() - 1, 1)
	#if debug: print(code)
	return code

func convertMapCode(code: String, _debug=false):
	#print("yolo")
	var map = {}
	for index in (code.get_slice_count(";")):
		var slice = code.get_slice(";", index)
		var cSlice = slice.get_slice(":", 0)
		var coord = Vector2i(int(cSlice.get_slice(",", 0)), int(cSlice.get_slice(",", 1)))
		var value = int(slice.get_slice(":", 1))
		map[coord] = value
	#updateRoads()
	return map

func convertMapCodeFloat(code: String, _debug=false):
	#print("yolo")
	var map = {}
	for index in (code.get_slice_count(";")):
		var slice = code.get_slice(";", index)
		var cSlice = slice.get_slice(":", 0)
		var coord = Vector2i(int(cSlice.get_slice(",", 0)), int(cSlice.get_slice(",", 1)))
		var value = float(slice.get_slice(":", 1))
		map[coord] = value
	#updateRoads()
	return map

func convertMapCodeBool(code: String, _debug=false):
	#print("yolo")
	var map = {}
	for index in (code.get_slice_count(";")):
		var slice = code.get_slice(";", index)
		var cSlice = slice.get_slice(":", 0)
		var coord = Vector2i(int(cSlice.get_slice(",", 0)), int(cSlice.get_slice(",", 1)))
		var value = slice.get_slice(":", 1)
		match value:
			"true": value = true
			"false": value = false
		map[coord] = value
	#updateRoads()
	return map

func toggleActivation(tile):
	#print("yea")
	if tile in activationMap:
		activationMap[tile] = not activationMap[tile]
		tileMap[tile].updateBuilding(getSpecificNeighbors(tile), activationMap[tile])
		Event.update_resources.emit()

func updateAllBuildings():
	for tile in buildingMap:
		tileMap[tile].updateBuilding(getSpecificNeighbors(tile), activationMap[tile])
	Event.update_resources.emit()

func demolish(tile):
	buildingMap.erase(tile)
	tileMap[tile].building = false
	tileMap[tile].updateBuilding(getSpecificNeighbors(tile), activationMap[tile])
	updateRoads()
	Event.update_resources.emit()

func updateRoads():
	for tile in buildingMap.keys():
		if buildingMap[tile] == Global.BUILDING.ROAD:
			tileMap[tile].updateBuilding(getSpecificNeighbors(tile), activationMap[tile])

func createBuilding(tile : Vector2i, building : Global.BUILDING, startActivated=true):
	buildingMap[tile] = building
	activationMap[tile] = startActivated
	tileMap[tile].building = building
	tileMap[tile].updateBuilding(getSpecificNeighbors(tile), startActivated)
	tileMap[tile].resetAltitudeDiversification()
	Global.score += Global.buildingScores[building]
	updateRoads()
	Event.update_resources.emit()

func generateMap():
	var randomOffset = Vector2i(randi()%1000, randi()%1000)
	altitudeMap.clear()
	terrainMap.clear()
	var rawNoise
	for width in range(0, Global.mapSize.x):
		for height in range(0, Global.mapSize.y):
			rawNoise = noise.get_noise_2dv(Vector2i(width, height) + randomOffset)
			rawMap[Vector2i(width, height)] = rawNoise
			if rawNoise >= 0.25: rawNoise = 3
			elif rawNoise >= 0: rawNoise = 2
			elif rawNoise >= -0.25: rawNoise = 1
			else: rawNoise = 0
			altitudeMap[Vector2i(width, height)] = rawNoise
			terrainMap[Vector2i(width, height)] = Global.TERRAIN.PLAIN
	generateFeatures()
	guaranteedOres()
	generatePoles()

func clearMaps():
	buildingMap.clear()
	terrainMap.clear()
	altitudeMap.clear()
	rawMap.clear()
	activationMap.clear()

func generatePoles():
	var poleSize = ceili(Global.mapSize.y * 0.05)
	var mapseed
	for height in range(0, poleSize):
		for width in range(0, Global.mapSize.x):
			mapseed = randi_range(0, 7)
			if mapseed >= 2:
				mapseed = randi_range(0, 6)
				if mapseed == 0: terrainMap[Vector2i(width, height)] = Global.TERRAIN.NITROGEN
				elif mapseed == 1: terrainMap[Vector2i(width, height)] = Global.TERRAIN.PHOSPHORUS
				else: terrainMap[Vector2i(width, height)] = Global.TERRAIN.ICE
	for height in range(0, poleSize):
		for width in range(0, Global.mapSize.x):
			mapseed = randi_range(0, 7)
			if mapseed >= 2:
				mapseed = randi_range(0, 6)
				if mapseed == 0: terrainMap[Vector2i(width, Global.mapSize.y - height - 1)] = Global.TERRAIN.NITROGEN
				elif mapseed == 1: terrainMap[Vector2i(width, Global.mapSize.y - height - 1)] = Global.TERRAIN.PHOSPHORUS
				else: terrainMap[Vector2i(width, Global.mapSize.y - height - 1)] = Global.TERRAIN.ICE

func generateFeatures():
	for i in range(0, 3): generateBlot(randomPosition(), percentSizeOfMap(0.75), .075, Global.TERRAIN.CARBON)
	for i in range(0, 3): generateBlot(randomPosition(), percentSizeOfMap(0.75), .075, Global.TERRAIN.COPPER)
	for i in range(0, 3): generateBlot(randomPosition(), percentSizeOfMap(0.75), .075, Global.TERRAIN.IRON)
	for i in range(0, 6): generateBlot(randomPosition(), percentSizeOfMap(0.15), .1, Global.TERRAIN.PHOSPHORUS)
	for i in range(0, 6): generateBlot(randomPosition(), percentSizeOfMap(0.15), .1, Global.TERRAIN.NITROGEN)
	for i in range(0, 4): generateBlot(randomPosition(), percentSizeOfMap(0.3), .05, Global.TERRAIN.LITHIUM)
	for i in range(0, 4): generateBlot(randomPosition(), percentSizeOfMap(0.5), .05, Global.TERRAIN.ZINC)
	for i in range(0, 5): generateBlot(randomPosition(), percentSizeOfMap(0.5), .05, Global.TERRAIN.ICE)
	for i in range(0, 6): generateBlot(randomPosition(), percentSizeOfMap(0.5), .05, Global.TERRAIN.GOLD)
	for i in range(0, 7): generateBlot(randomPosition(), percentSizeOfMap(0.5), .05, Global.TERRAIN.URANIUM)
	"""
	for x in range(0, Global.mapSize.x):
		for y in range(0, Global.mapSize.y):
			if randi()%2==0: terrainMap[Vector2i(x, y)] = Global.TERRAIN.PLAIN #half all ores
	"""

func guaranteedOres():
	var guaranteedTiles = []
	for x in range(Global.mapSize.x/2-6,Global.mapSize.x/2+6):
		for y in range(Global.mapSize.y/2-6,Global.mapSize.y/2+6):
			guaranteedTiles.append(Vector2i(x, y))
	guaranteedTiles.shuffle()
	for tile in guaranteedTiles:
		terrainMap[tile] = Global.TERRAIN.PLAIN
	for i in range(0, 12):
		terrainMap[guaranteedTiles[i]] = Global.TERRAIN.IRON
	for i in range(12, 18):
		terrainMap[guaranteedTiles[i]] = Global.TERRAIN.CARBON
	for i in range(18, 24):
		terrainMap[guaranteedTiles[i]] = Global.TERRAIN.URANIUM
	for i in range(24, 36):
		terrainMap[guaranteedTiles[i]] = Global.TERRAIN.COPPER
	for i in range(36, 42):
		terrainMap[guaranteedTiles[i]] = Global.TERRAIN.ZINC
	for i in range(42, 54):
		terrainMap[guaranteedTiles[i]] = Global.TERRAIN.ICE
	for i in range(54, 57):
		terrainMap[guaranteedTiles[i]] = Global.TERRAIN.GOLD
	for i in range(57, 60):
		terrainMap[guaranteedTiles[i]] = Global.TERRAIN.LITHIUM
	for i in range(63, 66):
		terrainMap[guaranteedTiles[i]] = Global.TERRAIN.NITROGEN
	for i in range(66, 69):
		terrainMap[guaranteedTiles[i]] = Global.TERRAIN.PHOSPHORUS

func percentSizeOfMap(percent):
	return Vector2i(ceili(Global.mapSize.x * percent), ceili(Global.mapSize.y * percent))

func randomPosition():
	return Vector2i(randi_range(0, Global.mapSize.x-1), randi_range(0, Global.mapSize.y-1))

func generateBlot(location : Vector2i, size : Vector2i, density, terrain : Global.TERRAIN):
	for x in range(0, size.x):
		for y in range(0, size.y):
			@warning_ignore("narrowing_conversion", "integer_division")
			if checkEllipseBounds(x-size.x/2, y-size.y/2, size.x, size.y):
				if randf_range(0, 1) <= density: terrainMap[Vector2i((x+location.x)%Global.mapSize.x, (y+location.y)%Global.mapSize.y)] = terrain

func checkEllipseBounds(x : int, y : int, w : int, h : int):
	@warning_ignore("integer_division")
	if (pow(x, 2)/pow(w/2,2))+(pow(y, 2)/pow(h/2,2)) <= 1: return true
	else: return false

func initMap():
	tileMap.clear()
	var tileInstance : Tile
	var neighborAltitudes = []
	for width in range(0, Global.mapSize.x):
		for height in range(0, Global.mapSize.y):
			tileInstance = tileBlueprint.instantiate()
			tileInstance.tile = Vector2i(width, height)
			tileInstance.altitude = altitudeMap[tileInstance.tile]
			tileInstance.raw = rawMap[tileInstance.tile]
			if tileInstance.altitude < Global.seaLevel: tileInstance.waterlogged = true
			tileInstance.terrain = terrainMap[tileInstance.tile]
			tileInstance.updatePosition()
			tileInstance.updateTerrain()
			neighborAltitudes = diversifyAltitude(tileInstance.tile)
			tileInstance.diversifyAltitude(neighborAltitudes[0], neighborAltitudes[1], neighborAltitudes[2], neighborAltitudes[3])
			tileInstance.diversifyModulate()
			tileInstance.updateBuilding()
			tileInstance.initialized = true
			if tileInstance.tile in buildingMap: tileInstance.building = buildingMap[tileInstance.tile]
			else: tileInstance.building = Global.BUILDING.EMPTY
			tileMap[tileInstance.tile] = tileInstance
			add_child(tileInstance)
	var spawn = Vector2i(Global.mapSize.x/2, Global.mapSize.y/2)
	return spawn

func starterColony(location):
	createBuilding(location, Global.BUILDING.CENTER)

func getTrueNeighborCount(tile : Vector2i) -> int:
	var count = 0
	if buildingMap.has(tile + Vector2i(1, 0)) and not buildingMap[tile + Vector2i(1, 0)] == Global.BUILDING.EMPTY: count += 1
	if buildingMap.has(tile + Vector2i(-1, 0)) and not buildingMap[tile + Vector2i(-1, 0)] == Global.BUILDING.EMPTY: count += 1
	if buildingMap.has(tile + Vector2i(0, 1)) and not buildingMap[tile + Vector2i(0, 1)] == Global.BUILDING.EMPTY: count += 1
	if buildingMap.has(tile + Vector2i(0, -1)) and not buildingMap[tile + Vector2i(0, -1)] == Global.BUILDING.EMPTY: count += 1
	return count

func getNeighborTypes(tile : Vector2i) -> Array:
	var nesw : Array = [Global.BUILDING.EMPTY, Global.BUILDING.EMPTY, Global.BUILDING.EMPTY, Global.BUILDING.EMPTY]
	if buildingMap.has(tile + Vector2i(-1, 0)): nesw[0] = buildingMap[tile + Vector2i(-1, 0)]
	if buildingMap.has(tile + Vector2i(0, -1)): nesw[1] = buildingMap[tile + Vector2i(0, -1)]
	if buildingMap.has(tile + Vector2i(1, 0)): nesw[2] = buildingMap[tile + Vector2i(1, 0)]
	if buildingMap.has(tile + Vector2i(0, 1)): nesw[3] = buildingMap[tile + Vector2i(0, 1)]
	return nesw

func getNeighborsOfType(tile : Vector2i, type : Global.BUILDING) -> int:
	var count = 0
	#if buildingMap.has(tile + Vector2i(0, 0)) and not buildingMap[tile + Vector2i(0, 0)] == Global.BUILDING.EMPTY: return -1
	if buildingMap.has(tile + Vector2i(1, 0)) and buildingMap[tile + Vector2i(1, 0)] == type: count += 1
	if buildingMap.has(tile + Vector2i(-1, 0)) and buildingMap[tile + Vector2i(-1, 0)] == type: count += 1
	if buildingMap.has(tile + Vector2i(0, 1)) and buildingMap[tile + Vector2i(0, 1)] == type: count += 1
	if buildingMap.has(tile + Vector2i(0, -1)) and buildingMap[tile + Vector2i(0, -1)] == type: count += 1
	return count

func getNeighborCount(tile : Vector2i) -> int:
	var count = 0
	if buildingMap.has(tile + Vector2i(0, 0)) and not buildingMap[tile + Vector2i(0, 0)] == Global.BUILDING.EMPTY: return -1
	if buildingMap.has(tile + Vector2i(1, 0)) and not buildingMap[tile + Vector2i(1, 0)] == Global.BUILDING.EMPTY: count += 1
	if buildingMap.has(tile + Vector2i(-1, 0)) and not buildingMap[tile + Vector2i(-1, 0)] == Global.BUILDING.EMPTY: count += 1
	if buildingMap.has(tile + Vector2i(0, 1)) and not buildingMap[tile + Vector2i(0, 1)] == Global.BUILDING.EMPTY: count += 1
	if buildingMap.has(tile + Vector2i(0, -1)) and not buildingMap[tile + Vector2i(0, -1)] == Global.BUILDING.EMPTY: count += 1
	return count

func getSpecificNeighbors(tile : Vector2i) -> Array[bool]:
	var nesw : Array[bool] = [false, false, false, false]
	if buildingMap.has(tile + Vector2i(-1, 0)) and not buildingMap[tile + Vector2i(-1, 0)] == Global.BUILDING.EMPTY: nesw[0] = true
	if buildingMap.has(tile + Vector2i(0, -1)) and not buildingMap[tile + Vector2i(0, -1)] == Global.BUILDING.EMPTY: nesw[1] = true
	if buildingMap.has(tile + Vector2i(1, 0)) and not buildingMap[tile + Vector2i(1, 0)] == Global.BUILDING.EMPTY: nesw[2] = true
	if buildingMap.has(tile + Vector2i(0, 1)) and not buildingMap[tile + Vector2i(0, 1)] == Global.BUILDING.EMPTY: nesw[3] = true
	return nesw

func diversifyAltitude(tile: Vector2i):
	var N = false
	var E = false
	var S = false
	var W = false
	if tile.y > 0: N = altitudeMap[Vector2i(tile.x, tile.y-1)]
	if tile.x < Global.mapSize.x-1: E = altitudeMap[Vector2i(tile.x+1, tile.y)]
	if tile.y < Global.mapSize.y-1: S = altitudeMap[Vector2i(tile.x, tile.y+1)]
	if tile.x > 0: W = altitudeMap[Vector2i(tile.x-1, tile.y)]
	return [N, E, S, W]
