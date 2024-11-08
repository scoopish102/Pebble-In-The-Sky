extends Node

signal option_pressed(type : SidebarOption.TYPE)
signal confirmation_required(type : SidebarOption.TYPE)
signal deselect_cursor()
signal create_building(tile : Vector2i, building : Global.BUILDING)
signal update_resources()
