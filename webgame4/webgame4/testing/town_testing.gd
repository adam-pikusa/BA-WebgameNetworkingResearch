extends Node3D

var char_shape := SphereShape3D.new()
var param := PhysicsShapeQueryParameters3D.new()
var ray := PhysicsRayQueryParameters3D.new()

func _ready() -> void:
	char_shape.radius = 0.3
	
	

func _on_v_slider_value_changed(value: float) -> void:
	var b: Node3D = $TheBox
	b.position.y = 4.2 + value
		
	param.transform.origin = b.position
	param.shape = char_shape
	var shape_collisions := get_world_3d().direct_space_state.collide_shape(param)
	var shape_intersects := get_world_3d().direct_space_state.intersect_shape(param)
	$Data.text = str(shape_collisions)
	
	#ray.from = b.position
	#ray.to = b.position + Vector3.DOWN
	#
	#$Data.text = str(get_world_3d().direct_space_state.intersect_ray(ray))
