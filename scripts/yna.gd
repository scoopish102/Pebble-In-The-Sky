extends HBoxContainer

class_name YNA

@export var yes : SidebarOption
@export var no : SidebarOption

var option : SidebarOption.TYPE
var building = false

signal confirm(confirmed : bool, yna : YNA)

func _on_yes():
	confirm.emit(true, self)
	queue_free()

func _on_no():
	confirm.emit(false, self)
	queue_free()
