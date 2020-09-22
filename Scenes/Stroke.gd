extends Node2D

var points = []
var widths = []
var dists = []
var length = 0.0
var num = 0
var real = true
var life = 40

func _ready():
	$Line2D.points = PoolVector2Array()
	$Line2D.width_curve = Curve.new()

func add_point(pos, v):
	if num > 0:
		var from_last = pos.distance_squared_to(points[-1])
		dists.append(length + from_last)
		length += from_last
	else:
		dists.append(0.0)
	points.append(pos)
	widths.append(v)
	num += 1
	if num >= 2:
		$Line2D.width_curve.clear_points()
		for i in range(num):
			$Line2D.width_curve.add_point(Vector2(dists[i] / length, widths[i]))
		$Line2D.width_curve.bake()
		$Line2D.points = PoolVector2Array(points)

func jump():
	if real and life > 0:
		position.x += 15000
	else:
		queue_free()
	life -= 1
