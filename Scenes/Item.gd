extends Node2D

var amp = 0.0
var speed = 1.0
var center = 0.0
var t = 0.0

var headsup = null
var id = 0
var cid = 0

var remove_t = 0.0
var remove_b = false

func _ready():
	if $"/root/Global".mode == 1:
		scale = Vector2(1.5, 1.5)
	else:
		scale = Vector2(1, 1)

func _physics_process(delta):
	t += delta * speed
	position.y = sin(t) * amp + center
	headsup.real = position.y
	headsup.distance = global_position.x - 1024
	if remove_b:
		remove_t -= delta
		if remove_t <= 0.0:
			queue_free()
			headsup.queue_free()

func remove():
	if id == 0 or id == 3:
		get_child(1).get_child(1).playback_speed = 7.0
		remove_t = .8
		remove_b = true
	else:
		queue_free()
		headsup.queue_free()
