extends Node2D

class_name Cursor

var mousePosition : Vector2
var tile : Vector2i
var uiSelect : bool = false

@export var subcursors : Array[Sprite2D]
@export var map : Map
@export var display : Node2D

func _ready():
	Event.deselect_cursor.connect(deselect)

func update(minimap):
	mousePosition = get_global_mouse_position()
	if not Global.selected:
		tile = positionToTile(mousePosition)
		Global.selectedTile = tile
	else:
		if Input.is_action_just_pressed("ui_tileselect") and not uiSelect: 
			deselect()
			return
	if not tile == Vector2i(-1, -1):
		visible = true
		#position = map.tileMap[tile].position
		#display.position.y = map.tileMap[tile].display.position.y - Global.tileSize.y/4
		#aminimap.copyFrom(map.tileMap[tile])
		alignAltitude(tile)
		if Input.is_action_just_pressed("ui_tileselect") and not uiSelect: 
			select()
	else:
		visible = false
	Event.update_demolish_confirmation.emit(tile)
	Event.update_activate_confirmation.emit(tile)

func select():
	pass
	"""#Event.trade_order.emit(Global.RESOURCE.STEEL, 0)
	#print(Global.trades[Global.RESOURCE.STEEL])
	Event.update_resources.emit()
	#map.tileMap[tile].display.position.y = map.tileMap[tile].normalHeight - 20
	#map.tileMap[tile].selected = true
	Global.selected = true
	modulate = Color(255, 0, 0)
	Event.update_confirmation.emit()
	Event.update_demolish_confirmation.emit(tile)
	var terrain = false
	if tile in map.terrainMap: terrain = map.terrainMap[tile]
	var building = false
	if tile in map.buildingMap: building = map.buildingMap[tile]
	var activation = false
	if tile in map.activationMap: activation = map.activationMap[tile]
	var altitude = false
	if tile in map.altitudeMap: altitude = map.altitudeMap[tile]
	Event.tileSelected.emit(tile, terrain, building, activation, altitude)
	Event.tileSelectedNoArgs.emit()
	#print(tile)
	#print(Global.budgets)
	"""

func deselect():
	if tile == Vector2i(-1, -1): 
		Global.selected = false
		modulate = Color(255, 250, 0)
		Event.update_confirmation.emit()
		Event.update_demolish_confirmation.emit(tile)
		return
	#map.tileMap[tile].display.position.y = map.tileMap[tile].normalHeight
	#map.tileMap[tile].selected = false
	Global.selected = false
	modulate = Color(255, 250, 0)
	Event.update_confirmation.emit()
	Event.update_demolish_confirmation.emit(tile)
	Event.tileDeselected.emit()
	
func alignAltitude(_tile):
	#if map.tileMap[tile].waterlogged: 
	#	subcursors[0].position = Vector2(0, 0)
	#	subcursors[1].position = Vector2(-Global.tileSize.x/4, Global.tileSize.y/4)
	#	subcursors[2].position = Vector2(Global.tileSize.x/4, Global.tileSize.y/4)
	#	subcursors[3].position = Vector2(0, Global.tileSize.y/2)
	#else:
	#	for index in range(0, len(subcursors)):
	#		subcursors[index].position = map.tileMap[_tile].subtiles[index].position
	pass

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

func _on_ui_mouse_entered():
	uiSelect = false
	#print(uiSelect)

func _on_ui_mouse_exited():
	uiSelect = true
	#print(uiSelect)
