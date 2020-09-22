extends Node2D

var real = 0.0
var distance = 0.0

var flash_t = 0.0

func _ready():
	pass

func _physics_process(delta):
	position.y = (real - $"/root/Global".ceiling) / ($"/root/Global".z + 1)
	var s = (-distance / 9000) + 1
	scale = Vector2(s, s)
	if distance < 3000:
		flash_t += delta
		if fmod(flash_t, 0.3) >= 0.15:
			visible = true
		else:
			visible = false
	if distance < 1100:
		visible = false

func bad():
	$Sprite.visible = true
	$Sprite2.visible = false
