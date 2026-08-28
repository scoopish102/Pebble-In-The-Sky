extends Node2D

class_name BuildingTile

#generated data in relation to the map
@export var tile : Vector2i
@export var altitude : int
var raw : float
#internal variables related to selection
var initialized = false
var selected = false
var hover = false
var normalHeight : float

@export var demoTile = false #if this tile is just being used as a demonstration, e.g. minimap or main menu

@export var building : Global.BUILDING = Global.BUILDING.EMPTY

@export var subtiles : Array[BuildingSubtile]
@export var display : Node2D
@export var overall : AnimatedSprite2D

func _ready():
	Event.tileSelectedNoArgs.connect(processModulate.bind(true))
	Event.tileDeselected.connect(processModulate.bind(false))
	Event.updateTileAppearances.connect(updateAppearances)
	for subtile in subtiles:
		subtile.demoTile = demoTile
		subtile.tileCoord = tile

func updateAltitudes():
	var change = altitude-4
	for subtile in subtiles:
		subtile.offset = -32 - change*4

func updateAppearances():
	if not demoTile:
		if not Global.hideBuildings: overall.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		else: overall.self_modulate = Color(1.0, 1.0, 1.0, 0.2)
	processModulate(Global.selected)

func processModulate(sel): 
	if demoTile or not Global.shadeUnselected: 
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		return
	if sel:
		if selected: 
			modulate = Color(1.0, 1.0, 1.0, 1.0)
			overall.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		else: modulate = Color(0.6, 0.6, 0.6, 1.0)
	else: modulate = Color(1.0, 1.0, 1.0, 1.0)

func diversifyModulate():
	var modulateStrength = 1 + (raw/4)
	var subtileOriginalPosition = [0, Global.tileSize.y/4, Global.tileSize.y/4, Global.tileSize.y/2]
	display.modulate = Color(modulateStrength, modulateStrength, modulateStrength, 1)
	for subtile in subtiles:
		modulateStrength = 1 + ((subtile.position.y - subtileOriginalPosition[subtiles.find(subtile)])/150)
		subtile.modulate = Color(modulateStrength, modulateStrength, modulateStrength, 1)

func updateBuilding(neighbors=[false, false, false, false], activated=true):
	#if building == Global.BUILDING.EMPTY: return
	overall.set_animation(&"EMPTY")
	if building is Global.BUILDING and building == Global.BUILDING.ROAD: 
		var frame = roadFrames(neighbors)
		overall.set_animation(&"ROAD")
		overall.set_frame(frame)
	for subtile in subtiles:
		subtile.updateBuilding(building, activated)
		#print(activated)

func roadFrames(neighbors=[false,false,false,false]):
	var frame = 0
	if neighbors[0]:
		if neighbors[1]:
			if neighbors[2]:
				if neighbors[3]: frame = 0 #nesw
				else: frame = 1 #nes
			elif neighbors[3]: frame = 4 #new
			else: frame = 7 #ne
		elif neighbors[2]:
			if neighbors[3]: frame = 3 #nsw
			else: frame = 5 #ns
		elif neighbors[3]: frame = 10 #nw
		else: frame = 11 #n
	elif neighbors[1]:
		if neighbors[2]: 
			if neighbors[3]: frame = 2 #esw
			else: frame = 8 #es
		elif neighbors[3]: frame = 6 #ew
		else: frame = 12 #e
	elif neighbors[2]:
		if neighbors[3]: frame = 9 #sw
		else: frame = 13 #s
	elif neighbors[3]: frame = 14 #w
	else: frame = 15 #none
	return frame
