extends Node

var client
var game
var server

func toggle_fullscreen() -> void:
	var current_mode := DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(
		DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN if 
		current_mode != DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN else 
		DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		toggle_fullscreen()
