extends Control

class_name SidebarOption

enum TYPE {
	MAIN, #default, broadest menu
		BUILD, #opens menu for building buildings
		ACT, #actions upon buildings
		MARKET, #opens menu for managing trades
		NEXT_TURN, #next turn
		SAVE, #save the game
		EXIT, #exit to menu
	
	#BUILDINGS
	COLONY, #opens menu for colony related buildings
	POWER, #opens menu for power buildings, like generators
	HARVEST, #opens menu for resource harvest buildings, like mines and quarries
	PRODUCTION, #opens menu for factories, mills, and refineries
	MANUFACTORY, #opens menu for (manu)factories of products

	#ACTIONS
	ACTIVATE, #lets you activate or de-activate buildings
	DEMOLISH, #lets you demolish buildings
	
	#SAVE
	SLOT_1, #save on slot 1
	SLOT_2, #save on slot 2
	SLOT_3, #save on slot 3

	YES, NO, #for YNA
	BUILDING,
	TRADE #for initiating the trade screen
}

@export var type : TYPE
@export var hitbox : Button
@export var defaultSprite : NinePatchRect
@export var hoverSprite : NinePatchRect
@export var disabledSprite : NinePatchRect
@export var label : RichTextLabel

var disabled = true
var yna : YNA
var resource = Global.RESOURCE.MONEY
var building = false
var terrain = false
var tile = false
var activate = false

func init(_type : TYPE):
	type = _type
	#print("bro HOW")
	if not type == TYPE.BUILDING: label.set_text(TYPE.keys()[type])
	else: label.set_text(Global.buildingNames[building])
	if type == TYPE.NEXT_TURN: label.set_text("NEXT TURN")
	if type == TYPE.SLOT_1: label.set_text("Save Slot 1")
	elif type == TYPE.SLOT_2: label.set_text("Save Slot 2")
	elif type == TYPE.SLOT_3: label.set_text("Save Slot 3")
	if type == TYPE.TRADE and not resource is bool:
		if resource == Global.RESOURCE.CIVGOODS:
			label.text = "[img]" + Global.resIcons[resource] + "[/img] Civilian Goods"
		else: label.text = "[img]" + Global.resIcons[resource] + "[/img] " + str(Global.RESOURCE.keys()[resource]).replace(" ", "_").capitalize()

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
	elif type in [TYPE.SLOT_1,TYPE.SLOT_2,TYPE.SLOT_3,TYPE.EXIT]:
		Event.direct_confirmation.emit(type)
		return
	elif type == TYPE.ACTIVATE:
		Event.activate_confirmation.emit(tile, building, activate)
		return
	elif type == TYPE.TRADE:
		if not resource is bool: Event.trade_confirmation.emit(resource)
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
