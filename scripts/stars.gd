extends ColorRect

@export var cycleTime: float = 1000.0
var time = 0
func _process(delta):
	time += delta * 60
	time = fposmod(time, cycleTime)
	#print(time)
	material.set_shader_parameter("offset", Vector2(512*cos(time*2*PI/cycleTime+0.3), 256*sin(time*4*PI/cycleTime)))
