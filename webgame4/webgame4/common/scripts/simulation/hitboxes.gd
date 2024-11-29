class_name Sim_Hitbox

var user: Sim_Entity 
func collides_aabb(aabb: AABB) -> Vector3: return Vector3.ZERO 

class Hitscan extends Sim_Hitbox:
	var origin: Vector3
	var dir: Vector3
	var range: float
	
	func _init(user: Sim_Entity, origin: Vector3, dir: Vector3, range: float):
		self.user = user
		self.origin = origin
		self.dir = dir
		self.range = range
		
	func collides_aabb(aabb: AABB) -> Vector3: 
		var res = aabb.intersects_segment(origin, origin + dir * range)
		return Vector3.ZERO if res == null else res
