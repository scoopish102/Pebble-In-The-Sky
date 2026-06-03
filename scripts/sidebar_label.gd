extends PanelContainer

class_name SidebarLabel

@export var label : RichTextLabel

func updateSize():
	set_deferred("size.y", label.size.y + 32)
