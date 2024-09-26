extends Area2D

class_name Tile

var tile : Vector2i
var height : int

func _ready():
	pass

func _process(_delta):
	pass

func updateTilePosition():
	position = tile * Global.tileSize
	position.y -= height * Global.tileSize.y / 4
