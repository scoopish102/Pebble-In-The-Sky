extends Camera2D

var velocity : Vector2
var maxSpeed = 25

func _process(delta):
	var input = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	velocity += Vector2(input.x, input.y) * delta * 60
	if velocity.x < 0: velocity.x = max(velocity.x, -maxSpeed * delta * 60) 
	elif velocity.x > 0: velocity.x = min(velocity.x, maxSpeed * delta * 60)
	if velocity.y < 0: velocity.y = max(velocity.y, -maxSpeed * delta * 60) 
	elif velocity.y > 0: velocity.y = min(velocity.y, maxSpeed * delta * 60)
	global_position += velocity
	velocity *= 0.9

func goTo(coord: Vector2i):
	global_position.x = coord.x*Global.tileSize.x/2 - coord.y*Global.tileSize.x/2
	global_position.y = coord.x*Global.tileSize.y/2 + coord.y*Global.tileSize.y/2
