class_name Collision

static func cylinder_aabb(cylinder_center: Vector3, cylinder_radius: float, cylinder_height: float, aabb: AABB) -> Vector3:
	if cylinder_center.y - cylinder_height * 0.5 > aabb.position.y + aabb.size.y: return Vector3.ZERO
	if cylinder_center.y + cylinder_height * 0.5 < aabb.position.y: return Vector3.ZERO
	
	var circle_center := Vector2(cylinder_center.x, cylinder_center.z)
	var extent := Vector2(
		aabb.size.x * 0.5,
		aabb.size.z * 0.5)
	var square_center := Vector2(
		aabb.position.x,
		aabb.position.z) + extent
	var segment := circle_center - square_center
	var closest_point := square_center + segment.clamp(-extent, extent)
	var closest_point_to_circle_center := circle_center - closest_point
	var dist := closest_point_to_circle_center.length()
	var resolve_vector := closest_point_to_circle_center / dist * (cylinder_radius - dist)
	return Vector3(resolve_vector.x, 0, resolve_vector.y) if dist <= cylinder_radius else Vector3.ZERO
