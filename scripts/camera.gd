extends Camera2D

var velocity : Vector2
var maxSpeed = 25

func _process(_delta):
	var input = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	velocity += Vector2(input.x, input.y)
	if velocity.x < 0: velocity.x = max(velocity.x, -maxSpeed) 
	elif velocity.x > 0: velocity.x = min(velocity.x, maxSpeed)
	if velocity.y < 0: velocity.y = max(velocity.y, -maxSpeed) 
	elif velocity.y > 0: velocity.y = min(velocity.y, maxSpeed)
	global_position += velocity
	velocity *= 0.9
