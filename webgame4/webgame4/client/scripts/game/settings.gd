extends Control

var open := false

func _input(event: InputEvent) -> void:
	if !Input.is_action_just_pressed("settings"): return
	
	open = !open
	_set_open(open)

func _set_open(is_open: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_open else Input.MOUSE_MODE_CAPTURED
	State.game.block_movement = is_open
	visible = is_open

func _on_h_slider_sens_value_changed(value: float) -> void:
	State.game.look_sens = value

func _on_button_screen_mode_toggle_pressed() -> void:
	State.toggle_fullscreen()
