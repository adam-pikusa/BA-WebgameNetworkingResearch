class_name Cam extends Node3D

@onready var _cam: Camera3D = $Camera3D
@onready var _cursor: Line2D = $Cursor

var moving: float = 0.0
var tilt: float = 0.0
var cursor := false

func input_yaw() -> float: return rotation.y
func input_pitch() -> float: return rotation.x

func focus() -> void:
	_cam.make_current()

func _input(event: InputEvent) -> void:
	if State.game.block_movement: return
	if !_cam.current: return
	if not event is InputEventMouseMotion: return
	
	var mouse_motion: InputEventMouseMotion = event
	
	var rot_val := -mouse_motion.relative.x * (State.game as GameState).look_sens
	var rot_val_ver := mouse_motion.relative.y * (State.game as GameState).look_sens
	
	rotation.y += rot_val
	rotation.x = clampf(rotation.x - rot_val_ver, -PI * 0.48, PI * 0.48)

func _process(delta: float) -> void:
	_cursor.visible = cursor
	#print(tilt)
	if tilt > 0:
		tilt -= delta
		if tilt < 0: tilt = 0
		
	elif tilt < 0:
		tilt += delta
		if tilt > 0: tilt = 0
		
	if !_cam.current: return
	if State.game.block_movement: return
	
	var time := Time.get_ticks_msec() * 0.001
	
	_cam.position.x = sin(10.0 * moving * time * 0.5) * 0.02
	_cam.position.y = sin(10.0 * moving * time      ) * 0.02
	
	_cam.rotation.z = tilt * tilt * tilt * tilt * tilt * 0.05
