class_name TradeOption extends VBoxContainer

@export var infoLabel : RichTextLabel
@export var amountLabel : RichTextLabel
@export var less : TextureButton
@export var more : TextureButton
@export var deploy : Button

var resource
var quantity

func init():
	quantity = 1
	updateLabels()
	less.disabled = false
	more.disabled = false

func _process(_delta):
	var old = Global.trades[resource]
	var new = Global.trades[resource] + quantity
	var change = abs(old) - abs(new)
	if Global.budgets[Global.RESOURCE.TRADE] + change < 0: deploy.disabled = true
	else: deploy.disabled = false

func updateLabels():
	if resource == Global.RESOURCE.CIVGOODS:
		infoLabel.text = "[img]" + Global.resIcons[resource] + "[/img] Civilian Goods"
	else: infoLabel.text = "[img]" + Global.resIcons[resource] + "[/img] " + str(Global.RESOURCE.keys()[resource]).replace(" ", "_").capitalize()
	infoLabel.text += "\n[font_size=16]Market Price: " + str(Global.resourcePrices[resource]) + "\nCurrently "
	if Global.trades[resource] > 0: infoLabel.text += "Importing [color=00ff00ff]" + str(abs(Global.trades[resource])) + "[/color]"
	elif Global.trades[resource] < 0: infoLabel.text += "Exporting [color=ff0000ff]" + str(abs(Global.trades[resource])) + "[/color]"
	else: infoLabel.text += "Not Trading"
	infoLabel.text += "[/font_size]"
	if quantity > 0: amountLabel.text = "Buy " + str(abs(quantity))
	elif quantity < 0: amountLabel.text = "Sell " + str(abs(quantity))
	else: 
		amountLabel.text = "Maintain Status Quo"
		return
	amountLabel.text += "\n"
	var old = Global.trades[resource]
	var new = Global.trades[resource] + quantity
	var change = abs(old) - abs(new)
	if Global.budgets[Global.RESOURCE.TRADE] + change < 0:
		amountLabel.text += "[color=ff0000ff]" + str(change) + "[/color] [img]res://resources/resIcons/trade.tres[/img]"
	else: amountLabel.text += "[color=00ff00ff]" + str(change) + "[/color] [img]res://resources/resIcons/trade.tres[/img]"
	
func _on_less_pressed():
	#print("less")
	if quantity - 1 == 0: quantity = -1
	else: quantity -= 1
	quantity = max(quantity, -5)
	updateLabels()

func _on_more_pressed():
	if quantity + 1 == 0: quantity = 1
	else: quantity += 1
	quantity = min(quantity, 5)
	updateLabels()

func _on_deploy_trade_pressed():
	#print(quantity)
	Event.trade_order.emit(resource, quantity)
