class_name WorldLabel extends Marker3D

@export var _label: Label

var hidden := false

func set_text(text: String): _label.text = text
	
func _process(delta):
	if hidden: 
		_label.visible = false
		return
	
	var cam := get_viewport().get_camera_3d()
	if cam.is_position_behind(global_position): 
		_label.visible = false
		return
		
	var dist2 := cam.global_position.distance_squared_to(global_position)
	if dist2 > 5 ** 2: 
		_label.visible = false
		return
		
	_label.visible = true
	_label.position = cam.unproject_position(global_position)
	_label.scale = Vector2.ONE * clampf(1.0 - (dist2 * 0.05), 0.3, 1.0)
