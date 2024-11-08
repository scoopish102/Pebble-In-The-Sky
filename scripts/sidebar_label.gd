extends NinePatchRect

class_name SidebarLabel

@export var label : Label

func updateSize():
	set_deferred("size.y", label.size.y + 32)
