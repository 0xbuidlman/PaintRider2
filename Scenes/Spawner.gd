extends Node2D

var buckets = [
	preload("res://Images/buckets/red.png"),
	preload("res://Images/buckets/blue.png"),
	preload("res://Images/buckets/green.png"),
	preload("res://Images/buckets/orange.png"),
	preload("res://Images/buckets/purple.png"),
	preload("res://Images/buckets/yellow.png")
]

var Item = preload("res://Scenes/Item.tscn")

export var id = 0
export var mode_mode = 0

export var min_time = 1.0
export var max_time = 5.0

export var max_at_once = 1

export (Resource)var a

export var enabled = true

var timer;

signal spawn(item, hu)

func _ready():
	randomize()
	timer = rand_range(0, min_time)

func _physics_process(delta):
	var mode = $"/root/Global".mode
	var good = enabled and $"/root/Global".active and not $"/root/Global".end
	if good and (mode_mode == 2 or (mode_mode == 1 and mode == 1) or (mode_mode == 0 and mode == 0)):
		timer -= delta
		if timer <= 0.0:
			timer = rand_range(min_time, max_time)
			for i in range(randi() % max_at_once + 1):
				var x = Item.instance()
				var hu = x.get_child(0)
				if id == 4:
					hu.bad()
				var anim = a.instance()
				anim.get_child(1).play("a")
				if id == 3 and $"/root/Global".mode == 1:
					anim.get_child(0).visible = false
					anim.get_child(2).visible = true
				if id == 1:
					x.cid = randi() % 6
					anim.get_child(0).texture = buckets[x.cid]
				x.add_child(anim)
				x.headsup = hu
				x.id = id
				x.remove_child(hu)
				x.center = rand_range($"/root/Global".ceiling + 200, -200)
				x.position.x = rand_range(-100, 100)
				x.amp = rand_range(0, 150)
				x.speed = rand_range(1, 3)
				x.t = rand_range(0, 20)
				emit_signal("spawn", x, hu)
