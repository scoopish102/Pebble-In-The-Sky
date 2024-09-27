extends Area2D

class_name Tile

var tile : Vector2i
var height : int

func _ready():
	pass

func _process(_delta):
	pass

func updatePosition():
	position += Vector2(Global.tileSize.x/2, Global.tileSize.y/2) * tile.x
	position += Vector2(-Global.tileSize.x/2, Global.tileSize.y/2) * tile.y
	position.y -= height * 4

func randomizeTerrain():
	for terrain in $terrain.get_children():
		terrain.set_frame(randi_range(0, terrain.sprite_frames.get_frame_count(terrain.animation)))
	#if randi()
