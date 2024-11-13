extends Node2D

class_name Map

@export var tileBlueprint : PackedScene
var altitudeMap = {}
var terrainMap = {}
var rawMap = {}
var tileMap = {} #contains indexed references to ALL tile nodes, organized by tile position
var buildingMap = {}
var noise = preload("res://resources/altitudeNoise.tres")

func _ready():
	Event.create_building.connect(createBuilding)

func createBuilding(tile : Vector2i, building : Global.BUILDING):
	buildingMap[tile] = building
	tileMap[tile].building = building
	tileMap[tile].updateBuilding()
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
	generatePoles()

func generatePoles():
	var poleSize = ceili(Global.mapSize.y * 0.05)
	var seed
	for height in range(0, poleSize):
		for width in range(0, Global.mapSize.x):
			seed = randi_range(0, 7)
			if seed >= 2:
				seed = randi_range(0, 6)
				if seed == 0: terrainMap[Vector2i(width, height)] = Global.TERRAIN.NITROGEN
				elif seed == 1: terrainMap[Vector2i(width, height)] = Global.TERRAIN.PHOSPHORUS
				else: terrainMap[Vector2i(width, height)] = Global.TERRAIN.ICE
	for height in range(0, poleSize):
		for width in range(0, Global.mapSize.x):
			seed = randi_range(0, 7)
			if seed >= 2:
				seed = randi_range(0, 6)
				if seed == 0: terrainMap[Vector2i(width, Global.mapSize.y - height - 1)] = Global.TERRAIN.NITROGEN
				elif seed == 1: terrainMap[Vector2i(width, Global.mapSize.y - height - 1)] = Global.TERRAIN.PHOSPHORUS
				else: terrainMap[Vector2i(width, Global.mapSize.y - height - 1)] = Global.TERRAIN.ICE

func generateFeatures():
	for i in range(0, 6): generateBlot(randomPosition(), percentSizeOfMap(0.15), .15, Global.TERRAIN.PHOSPHORUS)
	for i in range(0, 6): generateBlot(randomPosition(), percentSizeOfMap(0.15), .15, Global.TERRAIN.NITROGEN)
	for i in range(0, 6): generateBlot(randomPosition(), percentSizeOfMap(0.15), .15, Global.TERRAIN.ICE)
	for i in range(0, 8): generateBlot(randomPosition(), percentSizeOfMap(0.3), .05, Global.TERRAIN.LITHIUM)
	for i in range(0, 10): generateBlot(randomPosition(), percentSizeOfMap(0.3), .05, Global.TERRAIN.GOLD)
	for i in range(0, 10): generateBlot(randomPosition(), percentSizeOfMap(0.3), .05, Global.TERRAIN.URANIUM)
	for i in range(0, 2): generateBlot(randomPosition(), percentSizeOfMap(0.75), .05, Global.TERRAIN.ZINC)
	for i in range(0, 2): generateBlot(randomPosition(), percentSizeOfMap(0.75), .05, Global.TERRAIN.COPPER)
	for i in range(0, 4): generateBlot(randomPosition(), percentSizeOfMap(0.75), .05, Global.TERRAIN.CARBON)
	for i in range(0, 4): generateBlot(randomPosition(), percentSizeOfMap(0.75), .05, Global.TERRAIN.IRON)
	"""
	for x in range(0, Global.mapSize.x):
		for y in range(0, Global.mapSize.y):
			if randi()%2==0: terrainMap[Vector2i(x, y)] = Global.TERRAIN.PLAIN #half all ores
	"""

func percentSizeOfMap(percent):
	return Vector2i(ceili(Global.mapSize.x * percent), ceili(Global.mapSize.y * percent))

func randomPosition():
	return Vector2i(randi_range(0, Global.mapSize.x-1), randi_range(0, Global.mapSize.y-1))

func generateBlot(location : Vector2i, size : Vector2i, density, terrain : Global.TERRAIN):
	for x in range(0, size.x):
		for y in range(0, size.y):
			if checkEllipseBounds(x-size.x/2, y-size.y/2, size.x, size.y):
				if randf_range(0, 1) <= density: terrainMap[Vector2i((x+location.x)%Global.mapSize.x, (y+location.y)%Global.mapSize.y)] = terrain

func checkEllipseBounds(x : int, y : int, w : int, h : int):
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
			tileInstance.initialized = true
			tileInstance.building = Global.BUILDING.EMPTY
			tileInstance.updateBuilding()
			tileMap[tileInstance.tile] = tileInstance
			add_child(tileInstance)
	starterColony(Vector2i(Global.mapSize.x/2, Global.mapSize.y/2))

func starterColony(location):
	createBuilding(location, Global.BUILDING.CENTER)

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
