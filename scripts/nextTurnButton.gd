class_name nextTurnButton extends Control
@export var choiceNotificationBlueprint : PackedScene
@export var notifications : Control

signal beginNextTurn
signal endGame

var tween : Tween

func moveHands():
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($"small hand", "rotation_degrees", 360*Global.turn, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($"large hand", "rotation_degrees", 360.0/Global.gameLength * Global.turn, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func _ready():
	Event.next_turn.connect(updateText)

func initiate(turn, gameLength):
	updateText()
	$"large hand".rotation_degrees = 360.0/gameLength * turn
	$"small hand".rotation_degrees = 360*turn

func updateText():
	#print("bro")
	var text : String
	if Global.gameLength - Global.turn < 10: 
		text = "[color=ff0000ff]" + str(Global.turn) + "[/color]/" + str(Global.gameLength)
		if Global.turn >= Global.gameLength: 
			$"next turn".text = "End Game"
		else: $"next turn".text = "Next Turn"
	else: text = str(Global.turn) + "/" + str(Global.gameLength)
	$'turn count'.text = text
	#print(text)

func quickConfirm(title : String, content : String, choices : String, windowSize : Vector2 = Vector2(352, 256)):
	var notif := choiceNotificationBlueprint.instantiate()
	notifications.add_child(notif)
	notif.size = windowSize
	notif.centerOnScreen()
	notif.setContent(title, content)
	notif.setChoices(choices)
	return notif

func nextTurn(): 
	if Global.turn >= Global.gameLength: 
		endGame.emit()
		$hitbox.disabled = true
	else: beginNextTurn.emit()
	moveHands()

func confirm():
	var cob = []
	var supercob = []
	var ttext = ""
	for res in Global.budgets.keys():
		if Global.budgets[res] < 0:
			cob.append(res)
		if Global.reserves[res] + Global.budgets[res] < 0:
			supercob.append(res)
	if len(cob) > 0: 
		ttext += "\n[color=ffff00ff]You currently have a deficit of"
		var cobcount = 0
		for res in cob:
			ttext += " " + camelConversion(str(Global.RESOURCE.keys()[res]))
			cobcount += 1
			if cobcount == len(cob): continue
			elif cobcount == len(cob)-1: ttext += " and"
			else: ttext += ","
		ttext += ".[/color]"
		if Global.turn >= Global.gameLength: ttext += ("\n[color=ffff00ff]FINISHING THE GAME"
				+ " WITH A DEFICIT IN ANY RESOURCE WILL REDUCE YOUR SCORE BY 10% AND SUBTRACT IT BY 2500 PER RESOURCE.[/color]")
	if len(supercob) > 0: 
		ttext += "\n[color=990000ff]You will have a debt in"
		var cobcount = 0
		for res in supercob:
			ttext += " " + camelConversion(str(Global.RESOURCE.keys()[res]))
			cobcount += 1
			if cobcount == len(supercob): continue
			elif cobcount == len(supercob)-1: ttext += " and"
			else: ttext += ","
		ttext += " if you continue to the next turn now.[/color]"
		if Global.turn >= Global.gameLength: ttext += ("\n[color=990000ff]FINISHING THE GAME"
				+ " WITH A DEBT IN ANY RESOURCE WILL HALVE YOUR SCORE AND SUBTRACT IT BY 5000 PER RESOURCE.[/color]")
	if Global.turn == Global.gameLength: ttext += ("\n[color=000099ff]Are you SURE you want to finish this game now?[/color]")
	if Global.turn == Global.gameLength: 
		@warning_ignore("integer_division")
		var notif = quickConfirm("End of Turn 60", "This is the last turn in the game. Are you ready for scoring, or do you want to stay a little longer?", "", Vector2(352, 160 + (ceil(len(ttext)/(352/8)) * 32)))
		var result = await notif.getChoice()
		if result: nextTurn()
	elif Global.turn >= Global.gameLength:
		return
	else: 
		if len(ttext) < 1: 
			nextTurn()
			return
		@warning_ignore("integer_division")
		var notif = quickConfirm("Turn Advancement Confirmation", "Are you ready to advance to the next turn?" + ttext, "", Vector2(352, 160 + (ceil(len(ttext)/(352/8)) * 32)))
		var result = await notif.getChoice()
		if result: nextTurn()
	#nextTurn()

func camelConversion(input: String) -> String:
	var words: PackedStringArray = input.to_lower().split("_")
	var camel_case: String = ""
	for i in range(0, words.size()):
		camel_case += words[i].capitalize()
	return camel_case
