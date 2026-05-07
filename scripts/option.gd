extends Control

class_name SidebarOption

enum TYPE {
	MAIN, #default, broadest menu
		BUILD, #opens menu for building buildings
		ACT,
		MARKET, #opens menu for managing trades
		NEXT_TURN, #next turn
	
	#BUILDINGS
	COLONY, #opens menu for colony related buildings
	POWER, #opens menu for power buildings, like generators
	HARVEST, #opens menu for resource harvest buildings, like mines and quarries, as well as farms
	PRODUCTION, #opens menu for factories, mills, and refineries
	MANUFACTORY, #opens menu for (manu)factories of products

	#ACTIONS
	DEMOLISH, #lets you demolish buildings

	YES, NO, #for YNA
	BUILDING
}

@export var type : TYPE
@export var hitbox : Button
@export var defaultSprite : NinePatchRect
@export var hoverSprite : NinePatchRect
@export var disabledSprite : NinePatchRect
@export var label : Label

var disabled = true
var yna : YNA
var building = false
var terrain = false
var tile = false

func init(_type : TYPE):
	type = _type
	#print("bro HOW")
	if not type == TYPE.BUILDING: label.set_text(TYPE.keys()[type])
	else: label.set_text(Global.buildingNames[building])
	if type == TYPE.NEXT_TURN: label.set_text("NEXT TURN")
	
func _ready(): 
	disable()
	await get_tree().create_timer(0.05).timeout
	if type != TYPE.YES: enable()

func _process(_delta):
	if disabled: 
		return
	if not hitbox.is_hovered() == hoverSprite.visible: hoverSprite.visible = hitbox.is_hovered()

func disable():
	disabledSprite.visible = true
	hitbox.disabled = true
	disabled = true

func enable():
	disabledSprite.visible = false
	hitbox.disabled = false
	disabled = false

func _on_pressed():
	#print("press", type, get_parent())
	if disabled: 
		return
	elif type == TYPE.DEMOLISH:
		Event.demolish_confirmation.emit(tile, building)
		return
	elif type == TYPE.BUILDING:
		Event.confirmation_required.emit(type, building, terrain)
		return
	elif type == TYPE.YES or type == TYPE.NO:
		return
	elif type == TYPE.NEXT_TURN:
		Event.next_turn_confirmation.emit()
		return
	Event.option_pressed.emit(type)

"""func updateInfo(building=false, terrain=false):
	
	if type == TYPE.BUILDING:
		yna.priceWorks = yna.checkPrice(yna.building)
		yna.terrainWorks = yna.checkTerrain(yna.building, terrain)"""
