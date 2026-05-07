class_name Minimap extends PanelContainer

@export var label : RichTextLabel
@export var minimapTile : Tile

func _ready():
	for subtile in minimapTile.subtiles:
		subtile.terrain.stop()
		subtile.building.stop()

func copyFrom(tile: Tile):
	var subtileInfo = []
	for subtile in tile.subtiles:
		subtileInfo.append(subtile.getCopyInfo())
	for sid in range(len(minimapTile.subtiles)):
		minimapTile.subtiles[sid].copyFrom(subtileInfo[sid])
	updateText(tile.tile, tile.terrain, tile.building)

func updateText(tile, terrain, building):
	var ttext = (Global.TERRAIN.find_key(terrain))
	ttext = ttext.replace(" ", "_").capitalize() 
	var btext = ""
	if building is bool: btext = "No Building"
	else: btext = (Global.buildingNames[building])
	#btext = btext.replace(" ", "_").capitalize() 
	if Global.turn < 25:
		label.set_text("[center]Turn " + str(Global.turn) + "/30[/center]\n[font_size=16]" + str(tile) + "\n" + ttext + "\n" + btext + "[/font_size]")
	else: label.set_text("[center]Turn [color=#ff0000ff]" + str(Global.turn) + "[/color]/30[/center]\n[font_size=16]" + str(tile) + "\n" + ttext + "\n" + btext + "[/font_size]")
