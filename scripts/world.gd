extends Node2D

class_name World

@onready var map = $map

func _ready():
	map.generateMap()
	map.initMap()
