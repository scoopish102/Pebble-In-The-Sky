extends AnimatedSprite2D

class_name BuildingSubtile
var tileCoord : Vector2i
var demoTile = false

func _ready():
	Event.updateTileAppearances.connect(updateAppearances)
	Event.tileSelectedNoArgs.connect(updateAppearances)
	Event.tileDeselected.connect(updateAppearances)

func updateAppearances():
	if not demoTile: 
		if not Global.hideBuildings: self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		else: self_modulate = Color(1.0, 1.0, 1.0, 0.2)
		if Global.selected and Global.selectedTile == tileCoord: 
			self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func updateBuilding(_building, activated):
	if _building is bool: 
		set_animation(&"EMPTY")
		return
	use_parent_material = activated
	if not Global.BUILDING.keys()[_building] in sprite_frames.get_animation_names():
		set_animation(&"EMPTY")
		return
	#print(Global.BUILDING.keys()[_building])
	set_animation(Global.BUILDING.keys()[_building])
	#CHANGE THIS LINE!!! WE DONT WANT RANDOM FRAMES EVERY TIME!!!
	set_frame(randi_range(0, sprite_frames.get_frame_count(animation)))

func getCopyInfo():
	return [0, 0, animation, frame, position.y, scale.x, modulate, 0, use_parent_material]

func copyFrom(info):
	set_animation(info[2])
	set_frame(info[3])
	position.y = info[4]
	scale.x = info[5]
	modulate = info[6]
	use_parent_material = info[8]
