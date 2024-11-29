class_name Sim_Item extends Sim_Entity

const type := 3

var position: Vector3

func clone() -> Sim_Item:
	var n := Sim_Item.new()
	n.position = position
	return n
	
func update2(ctx: Context, input_frame: Dictionary) -> void:
	for box: Sim_Hitbox in ctx.sim.hitboxes:
		if box.collides_aabb(AABB(position - Vector3.ONE * 0.1, Vector3.ONE * 0.2)) != Vector3.ZERO:
			remove = true
			return
	
func ser(buf: DataBuffer) -> void: 
	buf.u8(type)
	buf.vec3_f32(position)
	
static func deser(buf: DataBuffer) -> Sim_Item: 
	var ni := Sim_Item.new()
	ni.position = buf.vec3_f32()
	return ni
	
func print_state() -> void:
	print("Sim_Item", [position])
