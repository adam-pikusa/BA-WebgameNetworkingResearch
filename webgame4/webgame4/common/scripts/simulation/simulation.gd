class_name Simulation

const DELTA := 1.0 / 30.0

var state_tick := 0
var entities: Array[Sim_Entity] = []
var hitboxes: Array[Sim_Hitbox] = []

func init_base_game_state(box_positions: Array[Vector3], item_positions: Array[Vector3]) -> void:
	for i: Vector3 in box_positions:
		var ni := Sim_Box.new()
		ni.position = i
		entities.append(ni)
	
	for i: Vector3 in item_positions:
		var ni := Sim_Item.new()
		ni.position = i
		entities.append(ni)

static func simulate(ctx: Context, input_frame: Dictionary, events: DataBuffer) -> void:
	while events.bytes_remaining() > 0:
		var event_type := events.u8()
		print("simulation: processing event type:", event_type)
		match event_type:
			Protocol.NR_EVENT_PLAYER_JOINED:
				var input_id := events.u8()
				var ni := Sim_Human.new()
				ni.init(input_id)
				ctx.sim.entities.append(ni)
				print("simulation: adding new client ", input_id)
			_:
				print("simulation: received unknown event:", event_type)
	
	ctx.sim.hitboxes.clear()
	for e: Sim_Entity in ctx.sim.entities: e.update1(ctx, input_frame)
	for e: Sim_Entity in ctx.sim.entities: e.update2(ctx, input_frame)
	
	var remove_index := 0
	while remove_index < ctx.sim.entities.size():
		if ctx.sim.entities[remove_index].remove:
			ctx.sim.entities.remove_at(remove_index)
			continue
		remove_index += 1

	ctx.sim.state_tick += 1

func get_serialized_size() -> int:
	var buf := DataBuffer.new()
	buf.begin_packet_write()
	serialize(buf)
	return buf.bytes_written()

func serialize(buf: DataBuffer) -> void:
	buf.u32(state_tick)
	buf.i16(entities.size())
	for e: Sim_Entity in entities:
		e.ser(buf)
	
func serialize_b64() -> String:
	var buf := DataBuffer.new()
	buf.begin_packet_write()
	serialize(buf)
	return Marshalls.raw_to_base64(buf.get_buf())
	
func deserialize(buf: DataBuffer, snapshot_size: int) -> void:
	state_tick = buf.u32()
	entities.clear()
	var e_count := buf.i16()
	for i in e_count:
		entities.append(Sim_Entity.deser(buf))

func clone() -> Simulation:
	var n := Simulation.new()
	n.state_tick = state_tick
	for e in entities:
		n.entities.append(e.clone())
	return n
	
func get_hash() -> int:
	var buf := DataBuffer.new()
	buf.begin_packet_write()
	serialize(buf)
	return hash(buf.get_buf())

func print_state() -> void:
	print("printing state:")
	print("tick: ", state_tick)
	for e: Sim_Entity in entities:
		e.print_state()
