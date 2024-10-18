extends Node2D

class_name Subtile

@export var tile : AnimatedSprite2D
@export var terrain : AnimatedSprite2D
@export var building : AnimatedSprite2D

func _ready():
	if randi()%2 == 0:
		scale.x *= -1

func updateTerrain(_terrain):
	terrain.set_animation(Global.TERRAIN.keys()[_terrain])
	terrain.set_frame(randi_range(0, terrain.sprite_frames.get_frame_count(terrain.animation)))

func updateBuilding(_building):
	building.set_animation(Global.BUILDING.keys()[_building])
	building.set_frame(randi_range(0, building.sprite_frames.get_frame_count(building.animation)))
