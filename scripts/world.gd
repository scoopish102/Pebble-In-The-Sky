extends Node2D

class_name World

@onready var map = $map
@onready var game = $game

func _ready():
	map.generateMap()
	var spawn = map.initMap()
	game.camera.goTo(spawn)
	game.updateBudgets()
