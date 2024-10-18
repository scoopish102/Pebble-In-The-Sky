extends Node2D

class_name Map

@export var tileBlueprint : PackedScene
var altitudeMap = {}
var terrainMap = {}
var rawMap = {}
var tileMap = {}
var buildingMap = {}
var noise = preload("res://resources/altitudeNoise.tres")

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
			if randi()%3 == 0: terrainMap[Vector2i(width, height)] = Global.TERRAIN.CRATER
			else: terrainMap[Vector2i(width, height)] = Global.TERRAIN.PLAIN

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
