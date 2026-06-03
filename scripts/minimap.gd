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
	minimapTile.overall.animation = tile.overall.animation
	minimapTile.overall.frame = tile.overall.frame
	updateText(tile.tile, tile.terrain, tile.building, tile.subtiles[0].building.use_parent_material)

func updateText(tile, terrain, building, active):
	var ttext = (Global.TERRAIN.find_key(terrain))
	ttext = ttext.replace(" ", "_").capitalize() 
	var btext = ""
	if building is bool or building == Global.BUILDING.EMPTY: btext = "No Building"
	else: 
		if not active: btext = "[color=ffff00ff]Disabled[/color] "
		btext += (Global.buildingNames[building])
	#btext = btext.replace(" ", "_").capitalize() 
	if Global.turn < 50:
		label.set_text("[center]Turn " + str(Global.turn) + "/" + str(Global.gameLength) + "[/center]\n[font_size=16]" + str(tile) + "\n" + ttext + "\n" + btext + "[/font_size]")
	else: label.set_text("[center]Turn [color=#ff0000ff]" + str(Global.turn) + "[/color]/" + str(Global.gameLength) + "[/center]\n[font_size=16]" + str(tile) + "\n" + ttext + "\n" + btext + "[/font_size]")
