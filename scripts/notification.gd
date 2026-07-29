class_name Notification extends VBoxContainer

@export var title : RichTextLabel
@export var exitButton : BaseButton
@export var content : RichTextLabel

static var sampleText := "Come, let us build ourselves a city, with a tower that reaches to the heavens, so that we may make a name for ourselves."
signal result(result: bool)

func setContent(_title: String, _text: String):
	self.title.text = _title
	self.content.text = _text

func exitButtonPressed():
	result.emit(false)
	self.queue_free()

func centerOnScreen():
	Global.screenSize = get_window().size
	self.position.x = Global.screenSize.x/2 - self.size.x/2
	self.position.y = Global.screenSize.y/2 - self.size.y/2

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	# Detect left mouse button click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = get_global_mouse_position() - global_position
		else:
			dragging = false

	# Track mouse movement while dragging
	if event is InputEventMouseMotion and dragging:
		var target_position = get_global_mouse_position() - drag_offset
		global_position = clamp_to_screen(target_position)

# Calculates and enforces screen boundary limits
func clamp_to_screen(target_pos: Vector2) -> Vector2:
	# Get the size of the visible game window/viewport
	var screen_size = get_viewport_rect().size
	
	# Get the size of this specific UI element
	# Note: size assumes the Pivot Offset is set to (0,0) / top-left corner
	var ui_size = size 
	
	# Prevent the UI element from going past the left and top edges (0, 0)
	# and the right and bottom edges (screen size minus UI size)
	var clamped_x = clamp(target_pos.x, 0, screen_size.x - ui_size.x)
	var clamped_y = clamp(target_pos.y, 0, screen_size.y - ui_size.y)
	
	return Vector2(clamped_x, clamped_y)
