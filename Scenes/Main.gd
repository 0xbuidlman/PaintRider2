extends Node2D

var bars = [
	preload("res://Images/bars/red.png"),
	preload("res://Images/bars/blue.png"),
	preload("res://Images/bars/green.png"),
	preload("res://Images/bars/orange.png"),
	preload("res://Images/bars/purple.png"),
	preload("res://Images/bars/yellow.png"),
	preload("res://Images/bars/purple.png")
]

var was_active = false
var was_mode = 0

var rect_t = 0.0
var effect = 0
var end_effect = false

var score_start = 0
var base_score = 0
var extra_score = 0

export var do_reset = false

const TRANSITION1 = 2;
const TRANSITION2 = 6;

func _ready():
	var read = File.new()
	if read.file_exists("user://savedata.json"):
		read.open("user://savedata.json", File.READ)
		var d = parse_json(read.get_as_text())
		$CanvasLayer/Label.text = "HIGHSCORE:     " + str(d["score"])
		read.close()
	else:
		$CanvasLayer/Label.text = "SCORE:     0"
	$AnimationPlayer4.play("open")
	$AnimationPlayer.play("titlesway")
	$AnimationPlayer3.play("player_title")

func _physics_process(delta):
	if do_reset:
		$"/root/Global".reset()
		get_tree().change_scene("res://Scenes/Main.tscn")
	
	if Input.is_action_pressed("ui_left"):
		$Camera2D2.position.x -= delta * 1000
	if Input.is_action_pressed("ui_right"):
		$Camera2D2.position.x += delta * 1000
	
	$CanvasLayer/ProgressBar.value = ($Player.paint / $Player.NORMAL_PAINT) * 100
	$CanvasLayer/ProgressBar2.value = (($Player.paint - $Player.NORMAL_PAINT) / $Player.MODE_PAINT) * 100
	
	if $"/root/Global".end:
		$"/root/Global".z += delta * 0.4
		$"/root/Global".z = clamp($"/root/Global".z, 0, 1)
	var z = $"/root/Global".z + 1;
	$Camera2D.zoom = Vector2(z, z)
	$Camera2D.offset = Vector2(0, z * -600)
	
	if was_mode == 0 and $"/root/Global".mode == 1:
		$CanvasLayer/Heads.visible = true
		$ColorRect.visible = true
		rect_t = PI / TRANSITION1
		$ColorRect.material.set_shader_param("speed", TRANSITION1)
		was_mode = 1
		end_effect = true
		effect = 0
		$AudioStreamPlayer2.volume_db = 0
		$AudioStreamPlayer2.play($AudioStreamPlayer.get_playback_position())
		AudioServer.set_bus_bypass_effects(1, false)
	elif was_mode == 1 and $"/root/Global".mode == 0:
		$CanvasLayer/Heads.visible = false
		$ColorRect.visible = true
		rect_t = PI / TRANSITION2
		$ColorRect.material.set_shader_param("speed", TRANSITION2)
		was_mode = 0
		effect = 1
		end_effect = true
		$AudioStreamPlayer.volume_db = 0
		$AudioStreamPlayer.play($AudioStreamPlayer2.get_playback_position())
		AudioServer.set_bus_bypass_effects(1, false)
	
	rect_t -= delta
	if rect_t > 0.0:
		var trans = TRANSITION1
		if effect == 1:
			trans = TRANSITION2
			$AudioStreamPlayer.volume_db = pow(0.5 + (0.5 * cos(rect_t * trans * 0.5)), 0.5) * 40 - 40
			$AudioStreamPlayer2.volume_db = pow(0.5 + ( 0.5 * (-cos(rect_t * trans * 0.5) + 1)), 0.5) * 40 - 40
		else:
			$AudioStreamPlayer2.volume_db = pow(0.5 + (0.5 * cos(rect_t * trans * 0.5)), 0.5) * 40 - 40
			$AudioStreamPlayer.volume_db = pow(0.5 + ( 0.5 * (-cos(rect_t * trans * 0.5) + 1)), 0.5) * 40 - 40
		AudioServer.get_bus_effect(1, 0).pan = sin(rect_t * trans * 2) * 0.5
		AudioServer.get_bus_effect(1, 1).depth = sin(rect_t * trans) * 1.1 + 0.1
		$ColorRect.material.set_shader_param("time", rect_t)
	else:
		if end_effect:
			AudioServer.set_bus_bypass_effects(1, true)
			if effect == 0:
				$AudioStreamPlayer.stop()
			else:
				$AudioStreamPlayer2.stop()
		$ColorRect.visible = false
	
	if not was_active and $"/root/Global".active:
		$AnimationPlayer2.play("fadeout")
		$AnimationPlayer3.stop()
		was_active = true
		$Player.up = true
		score_start = $Canvas.pos
		$Canvas.start_pos = $Canvas.pos
	
	if $"/root/Global".active and not $"/root/Global".end:
		base_score = floor(($Canvas.pos - score_start) / 500) * 100
		$CanvasLayer/Label.text = "SCORE:     " + str(base_score + extra_score)

func add_head(hu):
	$CanvasLayer/Heads.add_child(hu)

func on_dead():
	$"/root/Global".end = true
	$"/root/Global".mode = 0
	$AnimationPlayer2.play_backwards("fadeout")
	var overwrite = true
	var read = File.new()
	if read.file_exists("user://savedata.json"):
		read.open("user://savedata.json", File.READ)
		var d = parse_json(read.get_as_text())
		if d["score"] > base_score + extra_score:
			overwrite = false
		read.close()
	if overwrite:
		var save = File.new()
		save.open("user://savedata.json", File.WRITE)
		var data = {
			"score": base_score + extra_score
		}
		save.store_line(to_json(data))
		save.close()

func on_reset():
	$ColorRect.visible = true
	rect_t = PI / TRANSITION1
	$ColorRect.material.set_shader_param("speed", TRANSITION1)
	$AnimationPlayer4.play("reset")

func on_bonus(v):
	extra_score += v

func on_change():
	var c = $"/root/Global".color
	$CanvasLayer/ProgressBar.texture_progress = bars[c]
