extends Node2D

class_name Map

@export var tileBlueprint : PackedScene

func initMap():
	var tileInstance : Tile
	for width in range(0, Global.mapSize.x):
		for height in range(0, Global.mapSize.y):
			tileInstance = tileBlueprint.instantiate()
			tileInstance.tile = Vector2i(width, height)
			tileInstance.height = randi_range(0, 3)
			tileInstance.updatePosition()
			tileInstance.randomizeTerrain()
			add_child(tileInstance)
