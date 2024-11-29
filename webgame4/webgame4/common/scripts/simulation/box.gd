class_name Sim_Box extends Sim_Entity

const type := 2

var position: Vector3
var position_last: Vector3

func clone() -> Sim_Box:
	var n := Sim_Box.new()
	n.position = position
	n.position_last = position_last
	return n
	
func update1(ctx: Context, input_frame: Dictionary) -> void: 
	position_last = position
	var force := Vector3.ZERO
	for e: Sim_Entity in ctx.sim.entities:
		if e == self: continue
		if position.distance_squared_to(e.position) < 2*2:
			force += position - e.position
	var translate := force.normalized() * 0.5 * Simulation.DELTA
	translate.y = 0
	position += translate

func ser(buf: DataBuffer) -> void: 
	buf.u8(type)
	buf.vec3_f32(position)
	buf.vec3_f32(position_last)

static func deser(buf: DataBuffer) -> Sim_Box: 
	var ni := Sim_Box.new()
	ni.position = buf.vec3_f32()
	ni.position_last = buf.vec3_f32()
	return ni
	
func print_state() -> void:
	print("Sim_Box", [position, position_last])
