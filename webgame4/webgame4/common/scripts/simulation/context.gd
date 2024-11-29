class_name Context

var sim: Simulation
var space: PhysicsDirectSpaceState3D

var _sphere := SphereShape3D.new()
var _sphere_query := PhysicsShapeQueryParameters3D.new()
var _ray_query := PhysicsRayQueryParameters3D.new()

func space_sphere_col(pos: Vector3, radius: float) -> Vector3:
	_sphere.radius = radius
	_sphere_query.shape = _sphere
	_sphere_query.transform.origin = pos
	
	var res := space.collide_shape(_sphere_query)
	
	var avg := Vector3.ZERO
	
	if res.size() == 0: return avg
	
	var count := res.size() / 2
	
	for i: int in count:
		avg += res[i * 2 + 1] - res[i * 2]
	
	return avg / count

func space_ray_col(start: Vector3, end: Vector3) -> Vector3:
	_ray_query.from = start
	_ray_query.to = end
	
	var res := space.intersect_ray(_ray_query)
	if res.size() == 0: return Vector3.ZERO
	return res["position"]
