extends Node2D

class_name Cursor

var mousePosition : Vector2
var tile : Vector2i

@export var subcursors : Array[Sprite2D]
@export var map : Map
@export var display : Node2D

func _process(_delta):
	mousePosition = get_global_mouse_position()
	if not Global.selected:
		tile = positionToTile(mousePosition)
		Global.selectedTile = tile
	else:
		if Input.is_action_just_pressed("ui_select"): 
			deselect()
			return
	if not tile == Vector2i(-1, -1):
		visible = true
		position = map.tileMap[tile].position
		display.position.y = map.tileMap[tile].display.position.y - Global.tileSize.y/4
		alignAltitude(tile)
		if Input.is_action_just_pressed("ui_select"): 
			select()
	else:
		visible = false

func select():
	map.tileMap[tile].display.position.y = map.tileMap[tile].normalHeight - 20
	map.tileMap[tile].selected = true
	Global.selected = true
	modulate = Color(255, 0, 0)

func deselect():
	map.tileMap[tile].display.position.y = map.tileMap[tile].normalHeight
	map.tileMap[tile].selected = false
	Global.selected = false
	modulate = Color(255, 250, 0)
	
func alignAltitude(_tile):
	if map.tileMap[tile].waterlogged: 
		subcursors[0].position = Vector2(0, 0)
		subcursors[1].position = Vector2(-Global.tileSize.x/4, Global.tileSize.y/4)
		subcursors[2].position = Vector2(Global.tileSize.x/4, Global.tileSize.y/4)
		subcursors[3].position = Vector2(0, Global.tileSize.y/2)
	else:
		for index in range(0, len(subcursors)):
			subcursors[index].position = map.tileMap[_tile].subtiles[index].position

func tileToPosition(_tile: Vector2i):
	var returnPosition = Vector2(0, 0)
	returnPosition += Vector2(Global.tileSize.x/2, Global.tileSize.y/2) * _tile.x
	returnPosition += Vector2(-Global.tileSize.x/2, Global.tileSize.y/2) * _tile.y
	#z_index = (tile.x + tile.y) * 2
	return returnPosition

func positionToTile(_position: Vector2):
	var _tile = Vector2i(0, 0)
	_position.y += Global.tileSize.y/2
	_tile.x = (_position.x/Global.tileSize.x) + (_position.y/Global.tileSize.y)
	_tile.y = - (_position.x/Global.tileSize.x) + (_position.y/Global.tileSize.y)
	_tile.x = int(floor(_tile.x))
	_tile.y = int(floor(_tile.y))
	if _tile.x < 0 or _tile.y < 0 or _tile.x >= Global.mapSize.x or _tile.y >= Global.mapSize.y: return Vector2i(-1, -1)
	else: return _tile
