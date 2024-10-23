extends NinePatchRect

class_name SidebarLabel

@export var label : Label

func updateSize():
	size.y = label.size.y + 32
