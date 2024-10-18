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

func updateBuilding():
	if building == Global.BUILDING.EMPTY: return
	for subtile in subtiles:
		subtile.updateBuilding(building)
