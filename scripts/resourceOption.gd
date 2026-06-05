extends PanelContainer

class_name ResourceOption

@export var nameLabel = RichTextLabel
@export var budgetLabel = Label
@export var reserveLabel = Label
@export var resource : Global.RESOURCE

func _ready():
	Event.update_resources.connect(update)

func update():
	#print("lol")
	tooltip_text = Global.resourceDescriptions[resource]
	for child in get_children():
		child.tooltip_text = Global.resourceDescriptions[resource]
	if resource in [Global.RESOURCE.TRADE,Global.RESOURCE.ENERGY,Global.RESOURCE.LABOR,Global.RESOURCE.WEALTH,Global.RESOURCE.INDUSTRY,Global.RESOURCE.INFLUENCE,Global.RESOURCE.SCORE]:
		reserveLabel.visible = false
	if resource == Global.RESOURCE.CIVGOODS:
		nameLabel.text = "[img]" + Global.resIcons[resource] + "[/img] Civilian Goods"
	else: nameLabel.text = "[img]" + Global.resIcons[resource] + "[/img] " + str(Global.RESOURCE.keys()[resource]).replace(" ", "_").capitalize()
	if resource == Global.RESOURCE.SCORE: budgetLabel.text = str(Global.score)
	else: budgetLabel.text = str(Global.budgets[resource])
	if not resource in [Global.RESOURCE.WEALTH,Global.RESOURCE.INDUSTRY,Global.RESOURCE.INFLUENCE,Global.RESOURCE.SCORE]:
		if Global.budgets[resource] > 0: budgetLabel.modulate = Color(0, 2, 0)
		elif Global.budgets[resource] < 0: budgetLabel.modulate = Color(2, 0, 0)
		else: budgetLabel.modulate = Color("3b3b3b")
	elif resource == Global.RESOURCE.TRADE:
		if Global.budgets[resource] > 0: budgetLabel.modulate = Color(0, 2, 0)
		else: budgetLabel.modulate = Color(2, 0, 0)
	else:#if resource == Global.RESOURCE.SCORE:
		budgetLabel.modulate = Color(0.0, 0.0, 1.616, 1.0)
	#else: budgetLabel.modulate = Color("3b3b3b")
	reserveLabel.text = "/ " + str(Global.reserves[resource])
	"""if Global.reserves[resource] > 0: reserveLabel.modulate = Color(0, 2, 0)
	elif Global.reserves[resource] < 0: reserveLabel.modulate = Color(2, 0, 0)
	else: """
	reserveLabel.modulate = Color("3b3b3b")
