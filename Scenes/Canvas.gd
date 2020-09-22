extends Node2D

var Stroke = preload("res://Scenes/Stroke.tscn")
var Splat = preload("res://Scenes/Splat.tscn")

var strokes = [
	preload("res://Images/strokes/red.png"),
	preload("res://Images/strokes/blue.png"),
	preload("res://Images/strokes/green.png"),
	preload("res://Images/strokes/orange.png"),
	preload("res://Images/strokes/purple.png"),
	preload("res://Images/strokes/yellow.png"),
	preload("res://Images/strokes/metalstroke.png")
]

var pos = 0.0
var start_pos = 0.0
var stage = 0
var next = 0

var cur_stroke = null

var was_mode = 0

func _physics_process(delta):
	var mode = $"/root/Global".mode
	
	if $"/root/Global".end:
		pos += 300 * delta
	else:
		pos += $"/root/Global".speed * delta
	
	if was_mode == 0 and mode == 1:
		$AnimationPlayer.playback_speed = 1
		$AnimationPlayer.play("mode")
		was_mode = 1
		remove_all($Stage1)
		remove_all($Stage2)
		remove_all($Stage3)
	elif was_mode == 1 and mode == 0:
		$AnimationPlayer.playback_speed = 2
		$AnimationPlayer.play_backwards("mode")
		was_mode = 0
		remove_all($Stage1)
		remove_all($Stage2)
		remove_all($Stage3)
	
	$bg1.position.x = -fmod(pos, 3840)
	$bg2.position.x = -fmod(pos, 3840)
	$bg3.position.x = -fmod(pos, 3840)
	$Stage1.position.x = 9750 - fmod(pos, 15000)
	$Stage2.position.x = 9750 - fmod(pos + 5000, 15000)
	$Stage3.position.x = 9750 - fmod(pos + 10000, 15000)
	$Strokes.position.x = -pos
	
	for s in $Strokes.get_children():
		if s.global_position.x < -10000:
			s.jump()
	
	var p = fmod(pos, 15000)
	if next == 0 and p >= 5000:
		remove_all($Stage3)
		next = 1
	elif next == 1 and p >= 10000:
		remove_all($Stage2)
		next = 2
	elif next == 2 and p < 5000:
		remove_all($Stage1)
		next = 0
	
	if $"/root/Global".active:
		var r = pos - start_pos
		if stage == 0 and r > 8000:
			$ModeSpawner.enabled = true
			stage = 1
		elif stage == 1 and r > 50000:
			$BombSpawner2.enabled = true
			stage = 2
		elif stage == 2 and r > 100000:
			$BombSpawner.max_at_once = 3
			stage = 3
		elif stage == 3 and r > 150000:
			$BombSpawner3.enabled = true
			$SpeedSpawner.min_time = 2
			$SpeedSpawner.max_time = 7
			stage = 4
		elif stage == 4 and r > 200000:
			$BombSpawner.max_at_once = 4
			$StarSpawner.min_time = 4
			$StarSpawner.max_time = 10
			$BombSpawner3.min_time = 5
			stage = 5
		elif stage == 5 and r > 250000:
			$ModeSpawner.min_time = 9
			$BombSpawner3.max_at_once = 2
			stage = 6
		elif stage == 6 and r > 300000:
			$BombSpawner2.mode_mode = 2
			$PaintSpawner.min_time = 5
			$PaintSpawner.max_time = 9

func remove_all(s):
	for c in s.get_children():
		if c.has_method("remove"):
			c.remove()

func on_spawn(item, hu):
	var p = fmod(pos, 15000)
	var mode = $"/root/Global".mode
	if p >= 0 and p < 5000:
		item.position.x += p
		if mode == 1:
			$Stage1.add_child(item)
		else:
			$Stage2.add_child(item)
	elif p >= 5000 and p < 10000:
		item.position.x += p - 5000
		if mode == 1:
			$Stage3.add_child(item)
		else:
			$Stage1.add_child(item)
	else:
		item.position.x += p - 10000
		if mode == 1:
			$Stage2.add_child(item)
		else:
			$Stage3.add_child(item)
	get_parent().add_head(hu)

func paint(p, v, r = true):
	if cur_stroke:
		p += Vector2(pos - cur_stroke.position.x, 0)
		cur_stroke.real = r
		if v > 0:
			cur_stroke.add_point(p, v)
		else:
			cur_stroke.add_point(p, 0)
			cur_stroke = null
	elif v > 0:
		var s = Stroke.instance()
		var color = $"/root/Global".color
		if color >= 6:
			s.get_child(0).width = 80
		s.get_child(0).texture = strokes[color]
		s.position = Vector2(pos, 0)
		s.add_point(p, 0)
		s.real = r
		cur_stroke = s
		$Strokes.add_child(s)

func on_bomb(p):
		var sp = Splat.instance()
		sp.position = Vector2(pos, 0) + p
		$Strokes.add_child(sp)
