class_name MainMenu extends Control

@export var notificationBlueprint: PackedScene
@export var choiceNotificationBlueprint: PackedScene
@export var singleOptionNotificationBlueprint: PackedScene

@export var mainMenu : MarginContainer
@export var saveSlots : MarginContainer

@export var newGame : Button
@export var loadGame : Button
@export var credits : Button
@export var quitGame : Button

@export var slot1 : Button
@export var slot2 : Button
@export var slot3 : Button
@export var saveBack : Button

func _ready():
	mainMenu.visible = true
	saveSlots.visible = false
	Global.loadSlot = 0

func _on_load_game_pressed():
	mainMenu.visible = false
	saveSlots.visible = true

func _on_back_pressed():
	saveSlots.visible = false
	mainMenu.visible = true

func loadScene(nextScene):
	get_tree().change_scene_to_file(nextScene)

func _on_slot_1_pressed():
	var choice := choiceNotificationBlueprint.instantiate()
	add_child(choice)
	choice.size = Vector2(256, 216)
	choice.centerOnScreen()
	choice.setContent("[img]res://resources/uiTrimIcons/load.tres[/img] Load Slot 1", "This will load your game saved on Save Slot 1.")
	choice.setChoices("Proceed?")
	var result = await choice.getChoice()
	if result: 
		Global.loadSlot = 1
		loadScene("res://scenes/world.tscn")
	else: return

func _on_slot_2_pressed():
	var choice := choiceNotificationBlueprint.instantiate()
	add_child(choice)
	choice.size = Vector2(256, 216)
	choice.centerOnScreen()
	choice.setContent("[img]res://resources/uiTrimIcons/load.tres[/img] Load Slot 2", "This will load your game saved on Save Slot 2.")
	choice.setChoices("Proceed?")
	var result = await choice.getChoice()
	if result: 
		Global.loadSlot = 2
		loadScene("res://scenes/world.tscn")
	else: return

func _on_slot_3_pressed():
	var choice := choiceNotificationBlueprint.instantiate()
	add_child(choice)
	choice.size = Vector2(256, 216)
	choice.centerOnScreen()
	choice.setContent("[img]res://resources/uiTrimIcons/load.tres[/img] Load Slot 3", "This will load your game saved on Save Slot 3.")
	choice.setChoices("Proceed?")
	var result = await choice.getChoice()
	if result: 
		Global.loadSlot = 3
		loadScene("res://scenes/world.tscn")
	else: return

func _on_quit_game_pressed():
	get_tree().quit()

func _on_new_game_pressed():
	Global.loadSlot = 0
	loadScene("res://scenes/world.tscn")
