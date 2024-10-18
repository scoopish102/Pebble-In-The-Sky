extends Node

var tileSize = Vector2i(128, 64)
var mapSize = Vector2i(50, 50)
var height = 8
var seaLevel = 0

var selectedTile = Vector2i(0, 0)
var selected = false

enum TERRAIN {
	PLAIN,
	CRATER,
	SEA
}

enum BUILDING {
	EMPTY,
	CITY
}
