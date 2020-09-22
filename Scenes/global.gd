extends Node

var active = false
var end = false
var mode = 0
var speed = 600.0
var ceiling = 600.0
var z = 0.0
var color = 0
var loc = Vector2(0, 0)

func reset():
	active = false
	end = false
	mode = 0
	speed = 600.0
	ceiling = 600.0
	z = 0.0
	color = 0
	loc = Vector2(0, 0)
