extends Node2D

var characters = [
	preload("res://Images/characters/characterred.png"),
	preload("res://Images/characters/characterblue.png"),
	preload("res://Images/characters/charactergreen.png"),
	preload("res://Images/characters/characterorange.png"),
	preload("res://Images/characters/character.png"),
	preload("res://Images/characters/characteryellow.png")
]

const GRAVITY = [1100, 2000]
const FORCE = [-3000, -6000]
const MIN_VELOCITY = [-800, -300]
const MAX_VELOCITY = [550, 150]
const VEL_CATCH = [10, 4]

const MIN_SPEED = [600.0, 2700.0]
const MAX_SPEED = [1800.0, 2900.0]
const RANGE = [[600.0, 2400.0], [600.0, 2800.0]]
const FRICTION = [80.0, 50.0]

const SPEED_UP = [500, 800]
const TARGET_CATCH = [2, 2]
const FROM_LEFT = [3, 5]

const NORMAL_PAINT = 10.0
const MODE_PAINT = 6.0

const PAINT_INTERVAL = 0.01

const WIDTH_MOD = [3, 10]

const ROT = [35, 50]

var velocity = 0.0
var speed = 600.0
var target_speed = 600.0

var paint = NORMAL_PAINT
var painting = false
var p_timer = 0.0
var been_painting = 0.0

var up = false

var reset_t = 0.0

export var title_osc = 0.0

signal vroom(p, v)
signal dead()
signal bomb(pos)
signal start_reset()
signal bonus(v)
signal change()

func _ready():
	randomize()
	$"/root/Global".color = randi() % 6
	$Sprite.texture = characters[$"/root/Global".color]
	emit_signal("change")

func _input(event):
	if event.is_action_pressed("button"):
		up = true
	elif event.is_action_released("button"):
		up = false

func _physics_process(delta):
	
	if $"/root/Global".active and not $"/root/Global".end:
		var mode = $"/root/Global".mode
		
		if mode == 1 and paint <= NORMAL_PAINT:
			$"/root/Global".mode = 0
			$"/root/Global".color = randi() % 6
			$Sprite.texture = characters[$"/root/Global".color]
			emit_signal("change")
			scale = Vector2(1, 1)
			mode = 0
			target_speed = 1200
			$Sprite.scale = Vector2(0.12, 0.12)
		
		velocity += GRAVITY[mode] * delta
		var z_amount = clamp((speed - RANGE[mode][0]) / (RANGE[mode][1] - RANGE[mode][0]), 0, 1)
		$"/root/Global".z = z_amount
		var ceiling = -(z_amount * 600) - 600
		$"/root/Global".ceiling = ceiling
		if up and paint > 0:
			been_painting += delta * WIDTH_MOD[mode]
			var mult = clamp((position.y - ceiling - 50) / 100, 0, 1)
			paint -= mult * delta
			velocity += FORCE[mode] * delta * mult
			if p_timer <= 0.0:
				emit_signal("vroom", brush_pos(mode), mult * clamp(been_painting, 0, 1))
				p_timer = PAINT_INTERVAL
			p_timer -= delta
			$p.volume_db = mult * 25 - 25
			if mult > 0 and not $p.playing:
				$p.play()
			elif mult <= 0 and $p.playing:
				$p.stop()
			painting = true
		elif painting:
			emit_signal("vroom", brush_pos(mode), -1)
			p_timer = 0.0
			been_painting = 0.0
			painting = false
			$p.stop()
		if velocity > MAX_VELOCITY[mode]:
			velocity -= (velocity - MAX_VELOCITY[mode]) * delta * VEL_CATCH[mode]
		elif velocity < MIN_VELOCITY[mode]:
			velocity -= (velocity - MIN_VELOCITY[mode]) * delta * VEL_CATCH[mode]
		position.y += velocity * delta
		
		$Sprite.rotation = velocity * 0.001 + 0.2
		
		if target_speed > MIN_SPEED[mode]:
			target_speed -= FRICTION[mode] * delta
		elif target_speed < MIN_SPEED[mode]:
			target_speed += FRICTION[mode] * delta * 3
		target_speed = clamp(target_speed, 0, MAX_SPEED[mode])
		
		speed += (target_speed - speed) * TARGET_CATCH[mode] * delta
		position.x = (speed - 600) / 6 + 150
		$"/root/Global".speed = speed
		$"/root/Global".loc = position
		if position.y > 50:
			$p.stop()
			emit_signal("dead")
	else:
		if p_timer <= 0.0:
			emit_signal("vroom", brush_pos(0), title_osc, false)
			p_timer = PAINT_INTERVAL
		p_timer -= delta
		if title_osc > 0:
			painting = true
		else:
			p_timer = 0.0
			painting = false
		been_painting = title_osc
		
		if Input.is_action_pressed("button"):
			$"/root/Global".active = true
	if $"/root/Global".end:
		reset_t += delta
		if reset_t > 0.9 and up:
			emit_signal("start_reset")

func brush_pos(mode):
	var d = $Sprite.rotation - (PI / 4) + 0.1
	return position + Vector2(-cos(d) * ROT[mode], -sin(d) * ROT[mode])

func _on_Area2D_area_entered(area):
	var id = area.get_parent().id
	if id == 0:
		target_speed += SPEED_UP[$"/root/Global".mode]
		$s.play()
	elif id == 1 and paint < NORMAL_PAINT:
		paint = NORMAL_PAINT
		$"/root/Global".color = area.get_parent().cid
		$Sprite.texture = characters[$"/root/Global".color]
		$b.play()
		emit_signal("change")
		if painting:
			emit_signal("vroom", brush_pos(0), -1)
			emit_signal("vroom", brush_pos(1), 1)
	elif id == 2:
		paint = NORMAL_PAINT + MODE_PAINT
		target_speed = MIN_SPEED[1]
		scale = Vector2(1.5, 1.5)
		$"/root/Global".mode = 1
		$"/root/Global".color = 6
		velocity -= 1800
		$Sprite.texture = characters[4]
		emit_signal("change")
		$Sprite.scale = Vector2(0.13, 0.13)
		if painting:
			emit_signal("vroom", brush_pos(0), -1)
			emit_signal("vroom", brush_pos(0), 1)
	elif id == 3:
		emit_signal("bonus", 1000)
		$c.play()
	elif id == 4:
		paint -= 1
		emit_signal("bomb", area.get_parent().global_position)
		if position.y < area.get_parent().position.y:
			velocity -= 2000
		else:
			velocity += 1200
		if position.x < area.get_parent().global_position.x - 20:
			target_speed -= 500
		else:
			target_speed += 500
		$e1.play()
		$e2.play()
	area.get_parent().remove()
