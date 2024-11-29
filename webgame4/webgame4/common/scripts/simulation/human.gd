class_name Sim_Human extends Sim_Entity

const type := 1

const disc_radius := .3
const disc_height := .6

const head_height := Vector3(0, 1.6, 0)

var bound_to_input: int
var position: Vector3
var position_last: Vector3
var look_pitch: float
var look_yaw: float

func clone() -> Sim_Human:
	var n := Sim_Human.new()
	n.bound_to_input = bound_to_input
	n.position = position
	n.position_last = position_last
	n.look_pitch = look_pitch
	n.look_yaw = look_yaw
	return n

func init(bound_to_input: int) -> void:
	self.bound_to_input = bound_to_input
	position = Vector3(43, 2.8, 24)
	position_last = position
	look_pitch = 0
	look_yaw = 0
	
func move(ctx: Context, input_data: int) -> void:
	position_last = position
	
	var yaw := InputHelper.get_look_input_yaw(input_data)
	var walk_dir := InputHelper.get_move_dir_vector3(input_data)
	
	
	#var cells := ctx.grid.get_surrounding_cells(position)
	
	var test_position := position
	test_position += walk_dir.rotated(Vector3.UP, yaw) * 3.0 * Simulation.DELTA
	
	var foot_ray := ctx.space_ray_col(test_position + Vector3.UP, test_position + Vector3.DOWN * 0.5)
	
	if foot_ray == Vector3.ZERO: test_position.y -= Simulation.DELTA * 4.0
	else: test_position = foot_ray + Vector3.UP * 0.1
	
	#if ctx.space_sphere_col(test_position + Vector3.UP, .3): return
	
	position = test_position + ctx.space_sphere_col(test_position + Vector3.UP * 0.8, .4)
	
	#for c: AABB in cells:
	#	if c == CollisionGrid.CELL_INVALID: continue
	#	var disc_center := position + Vector3.UP * .96
	#	position += Collision.cylinder_aabb(disc_center, disc_radius, disc_height, c)
	
	if position.y <= 0.3:
		position = Vector3(43, 2.8, 24)
		position_last = Vector3(43, 2.8, 24)
	
func _get_look_ray() -> Vector3:
	return Vector3.FORWARD.rotated(Vector3.RIGHT, look_pitch).rotated(Vector3.UP, look_yaw)
	
	
func update1(ctx: Context, input_frame: Dictionary) -> void:
	var input_data: int = input_frame[bound_to_input] 
	move(ctx, input_data)
	look_pitch = InputHelper.get_look_input_pitch(input_data)
	look_yaw = InputHelper.get_look_input_yaw(input_data)
	
	if InputHelper.action1(input_data):
		ctx.sim.hitboxes.append(
			Sim_Hitbox.Hitscan.new(
				self, 
				position + head_height, 
				_get_look_ray(),
				3))
	
func ser(buf: DataBuffer) -> void:
	buf.u8(type)
	buf.u8(bound_to_input)
	buf.vec3_f32(position)
	buf.vec3_f32(position_last)
	buf.f32(look_pitch)
	buf.f32(look_yaw)
	
static func deser(buf: DataBuffer) -> Sim_Entity: 
	var ni := Sim_Human.new()
	ni.bound_to_input = buf.u8()
	ni.position = buf.vec3_f32()
	ni.position_last = buf.vec3_f32()
	ni.look_pitch = buf.f32()
	ni.look_yaw = buf.f32()
	return ni
	
func print_state() -> void:
	print("Sim_Human", [bound_to_input, position, position_last, look_pitch, look_yaw])
