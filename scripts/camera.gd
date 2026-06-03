extends Camera2D

var velocity : Vector2
var maxSpeed = 25

var minPos = Vector2(-((Global.mapSize.x)*Global.tileSize.x-Global.mapSize.y*Global.tileSize.y), 0)# + Vector2(0,
		#-Global.mapSize.y*Global.tileSize.y/2)
var maxPos = Vector2(((Global.mapSize.x)*Global.tileSize.x-Global.mapSize.y*Global.tileSize.y), 
		((Global.mapSize.x)*Global.tileSize.x-Global.mapSize.y*Global.tileSize.y))# + Vector2(0, 
		#((Global.mapSize.x)*Global.tileSize.x-Global.mapSize.y*Global.tileSize.y)-Global.mapSize.y*Global.tileSize.y/2)
var origin = Vector2((maxPos.x+minPos.x)/2, (maxPos.y+minPos.y)/2)

func _process(delta):
	var input = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	velocity += Vector2(input.x, input.y) * delta * 60
	if velocity.x < 0: velocity.x = max(velocity.x, -maxSpeed * delta * 60) 
	elif velocity.x > 0: velocity.x = min(velocity.x, maxSpeed * delta * 60)
	if velocity.y < 0: velocity.y = max(velocity.y, -maxSpeed * delta * 60) 
	elif velocity.y > 0: velocity.y = min(velocity.y, maxSpeed * delta * 60)
	global_position += velocity
	velocity *= 0.9
	if global_position.x > maxPos.x: global_position.x = maxPos.x
	if global_position.x < minPos.x: global_position.x = minPos.x
	if global_position.y > maxPos.y: global_position.y = maxPos.y
	if global_position.y < minPos.y: global_position.y = minPos.y
	
	if global_position.y < upperBoundFunction(global_position.x): 
		global_position.y = upperBoundFunction(global_position.x)
	if global_position.y > lowerBoundFunction(global_position.x): 
		global_position.y = lowerBoundFunction(global_position.x)

func goTo(coord: Vector2i):
	global_position.x = coord.x*Global.tileSize.x/2 - coord.y*Global.tileSize.x/2
	global_position.y = coord.x*Global.tileSize.y/2 + coord.y*Global.tileSize.y/2

func upperBoundFunction(x: float) -> float:
	return ((origin.y-minPos.y)/(maxPos.x-origin.x))*abs(x-origin.x) + minPos.y
func lowerBoundFunction(x: float) -> float:
	return ((origin.y-maxPos.y)/(maxPos.x-origin.x))*abs(x-origin.x) + maxPos.y
func leftBoundFunction(y: float) -> float:
	return ((origin.x-minPos.x)/(minPos.y-origin.y))*abs(y-origin.y) + minPos.x
func rightBoundFunction(y: float) -> float:
	return ((origin.x-maxPos.x)/(minPos.y-origin.y))*abs(y-origin.y) + maxPos.x
