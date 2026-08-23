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
	
	#MARKET
	CURRENT_TRADES,
	
	#SAVE
	SLOT_1, #save on slot 1
	SLOT_2, #save on slot 2
	SLOT_3, #save on slot 3

	YES, NO, #for YNA
	BUILDING,
	QUICKTRADE, #for viewing and cancelling current trades
	TRADE, #for initiating the trade screen
	SCORE #End-of-game scoreboard
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
	match type:
		TYPE.BUILD: label.text = "[img]res://resources/uiTrimIcons/build.tres[/img] " + label.text
		TYPE.ACT: label.text = "[img]res://resources/uiTrimIcons/act.tres[/img] " + label.text
		TYPE.MARKET: label.text = "[img]res://resources/uiTrimIcons/market.tres[/img] " + label.text
		TYPE.SAVE: label.text = "[img]res://resources/uiTrimIcons/save.tres[/img] " + label.text
		TYPE.EXIT: label.text = "[img]res://resources/uiTrimIcons/exit.tres[/img] " + label.text
	if type == TYPE.CURRENT_TRADES: label.set_text("Current Trades")
	if type == TYPE.NEXT_TURN:  
		if Global.turn >= Global.gameLength: label.set_text("[img]res://resources/uiTrimIcons/nextturn.tres[/img] "+"FINISH GAME")
		else: label.set_text("[img]res://resources/uiTrimIcons/nextturn.tres[/img] "+"NEXT TURN")
	if type == TYPE.SLOT_1: label.set_text(Global.otherNames[1])
	elif type == TYPE.SLOT_2: label.set_text(Global.otherNames[2])
	elif type == TYPE.SLOT_3: label.set_text(Global.otherNames[3])
	if type == TYPE.ACTIVATE: label.set_text("TOGGLE ACTIVATION")
	if type == TYPE.TRADE and not resource is bool:
		label.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		label.add_theme_color_override("default_color", Color("3b3b3bff"))
		if resource == Global.RESOURCE.CIVGOODS:
			label.text = "[img]" + Global.resIcons[resource] + "[/img] Civilian Goods"
		else: label.text = "[img]" + Global.resIcons[resource] + "[/img] " + str(Global.RESOURCE.keys()[resource]).replace(" ", "_").capitalize()

func quickTradeLabel(res: Global.RESOURCE):
	label.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	label.add_theme_color_override("default_color", Color("3b3b3bff"))
	#print(resource)
	if Global.trades[res] > 0: label.text = "Buying "
	else: label.text = "Selling "
	label.text += str(Global.trades[res])
	if res == Global.RESOURCE.CIVGOODS:
		label.text += " [img]" + Global.resIcons[res] + "[/img] Civ. Goods"
	else: label.text += " [img]" + Global.resIcons[res] + "[/img] " + str(Global.RESOURCE.keys()[res]).replace(" ", "_").capitalize()

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
	elif type == TYPE.QUICKTRADE:
		Event.cancel_trade_confirmation.emit(resource)
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
