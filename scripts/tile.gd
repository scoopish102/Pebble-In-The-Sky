extends Node2D

class_name Tile

#generated data in relation to the map
var tile : Vector2i
var altitude : int
var terrain : Global.TERRAIN
var waterlogged = false
var raw : float
#internal variables related to selection
var initialized = false
var selected = false
var hover = false
var normalHeight : float

var building = false

@export var subtiles : Array[Subtile]
@export var display : Node2D
@export var sea : Sprite2D
@export var overall : AnimatedSprite2D

func _ready():
	pass

func _process(_delta):
	if not initialized: return
	if not Global.selected and selected:
		selected = false
		display.position.y = normalHeight

func updatePosition():
	position = Vector2(0, 0)
	position += Vector2(Global.tileSize.x/2, Global.tileSize.y/2) * tile.x
	position += Vector2(-Global.tileSize.x/2, Global.tileSize.y/2) * tile.y
	z_index = (tile.x + tile.y) * 2

func updateTerrain():
	if waterlogged:
		sea.visible = true
		for subtile in subtiles:
			subtile.visible = false
		return
	for subtile in subtiles:
		subtile.updateTerrain(terrain)
	if int(raw*100)%2 == 0: subtiles[randi_range(0,3)].terrain.visible = false
	if int(raw*100)%2 == 0: subtiles[randi_range(0,3)].terrain.visible = false

func resetAltitudeDiversification():
	subtiles[0].position.y = 0
	subtiles[1].position.y = 16
	subtiles[2].position.y = 16
	subtiles[3].position.y = 32

func diversifyAltitude(N, E, S, W):
	if not waterlogged: 
		position.y -= (altitude-1) * Global.height * 2
	else: 
		position.y -= Global.height * (Global.seaLevel-2)
	normalHeight = display.position.y
	if N is int: 
		if N > altitude: 
			subtiles[0].position.y -= Global.height/2.0
			subtiles[2].position.y -= Global.height/2.0
		elif N < altitude:
			subtiles[0].position.y += Global.height/2.0
			subtiles[2].position.y += Global.height/2.0
	if E is int: 
		if E > altitude: 
			subtiles[3].position.y -= Global.height/2.0
			subtiles[2].position.y -= Global.height/2.0
		elif E < altitude:
			subtiles[3].position.y += Global.height/2.0
			subtiles[2].position.y += Global.height/2.0
	if S is int: 
		if S > altitude: 
			subtiles[3].position.y -= Global.height/2.0
			subtiles[1].position.y -= Global.height/2.0
		elif S < altitude:
			subtiles[3].position.y += Global.height/2.0
			subtiles[1].position.y += Global.height/2.0
	if W is int: 
		if W > altitude: 
			subtiles[0].position.y -= Global.height/2.0
			subtiles[1].position.y -= Global.height/2.0
		elif W < altitude:
			subtiles[0].position.y += Global.height/2.0
			subtiles[1].position.y += Global.height/2.0

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
	if not building is bool and building == Global.BUILDING.ROAD: 
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
