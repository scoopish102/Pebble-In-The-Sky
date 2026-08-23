extends Node2D

class_name Subtile

@export var tile : AnimatedSprite2D
@export var terrain : AnimatedSprite2D
@export var building : AnimatedSprite2D
var tileCoord : Vector2i
var demoTile = false

func _ready():
	if randi()%2 == 0:
		scale.x *= -1
	Event.updateTileAppearances.connect(updateAppearances)
	Event.tileSelectedNoArgs.connect(updateAppearances)
	Event.tileDeselected.connect(updateAppearances)

func updateAppearances():
	if not demoTile: 
		if not Global.hideBuildings: building.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		else: building.self_modulate = Color(1.0, 1.0, 1.0, 0.2)
		if Global.selected and Global.selectedTile == tileCoord: 
			building.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func updateTerrain(_terrain):
	terrain.set_animation(Global.TERRAIN.keys()[_terrain])
	terrain.set_frame(randi_range(0, terrain.sprite_frames.get_frame_count(terrain.animation)))

func updateBuilding(_building, activated):
	if _building is bool: 
		building.set_animation(&"EMPTY")
		return
	building.use_parent_material = activated
	if not Global.BUILDING.keys()[_building] in building.sprite_frames.get_animation_names():
		building.set_animation(&"EMPTY")
		return
	#print(Global.BUILDING.keys()[_building])
	building.set_animation(Global.BUILDING.keys()[_building])
	building.set_frame(randi_range(0, building.sprite_frames.get_frame_count(building.animation)))

func getCopyInfo():
	return [terrain.animation, terrain.frame, building.animation, building.frame, position.y, scale.x, modulate, terrain.visible, building.use_parent_material]

func copyFrom(info):
	terrain.set_animation(info[0])
	terrain.set_frame(info[1])
	building.set_animation(info[2])
	building.set_frame(info[3])
	position.y = info[4]
	scale.x = info[5]
	modulate = info[6]
	terrain.visible = info[7]
	building.use_parent_material = info[8]
