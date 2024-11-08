extends PanelContainer

class_name ResourceOption

@export var nameLabel = Label
@export var budgetLabel = Label
@export var reserveLabel = Label
var resource : Global.RESOURCE

func _ready():
	Event.update_resources.connect(update)

func update():
	if resource == Global.RESOURCE.ENERGY or resource == Global.RESOURCE.LABOR:
		reserveLabel.visible = false
	nameLabel.text = Global.RESOURCE.keys()[resource]
	budgetLabel.text = str(Global.budgets[resource])
	if Global.budgets[resource] > 0: budgetLabel.modulate = Color(0, 2, 0)
	elif Global.budgets[resource] < 0: budgetLabel.modulate = Color(2, 0, 0)
	else: budgetLabel.modulate = Color(1, 1, 1)
	reserveLabel.text = str(Global.reserves[resource])
	"""if Global.reserves[resource] > 0: reserveLabel.modulate = Color(0, 2, 0)
	elif Global.reserves[resource] < 0: reserveLabel.modulate = Color(2, 0, 0)
	else: reserveLabel.modulate = Color(1, 1, 1)"""
