extends Control

class_name SidebarOption

enum TYPE {
	MAIN, #default, broadest menu
		BUILD, #opens menu for building buildings
		ACT,
		MARKET, #opens menu for managing trades
	
	#BUILDINGS
	COLONY, #opens menu for colony related buildings
	PRODUCTION, #opens menu for factories

	YES, NO, #for YNA
	BUILDING
}

@export var type : TYPE
@export var hitbox : Button
@export var defaultSprite : NinePatchRect
@export var hoverSprite : NinePatchRect
@export var disabledSprite : NinePatchRect
@export var label : Label

var disabled = false
var yna : YNA
var building = false

func init(_type : TYPE):
	type = _type
	label.set_text(TYPE.keys()[type])

func _process(_delta):
	if not hitbox.is_hovered() == hoverSprite.visible: hoverSprite.visible = hitbox.is_hovered()

func _on_pressed():
	if disabled: 
		return
	if type == TYPE.BUILDING:
		Event.confirmation_required.emit(type, building)
		return
	if type == TYPE.YES or type == TYPE.NO:
		return
	Event.option_pressed.emit(type)
