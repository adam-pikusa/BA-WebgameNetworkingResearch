class_name History

const DEBUG_STATE_INTERVAL := 30 * 10

var _sim: Simulation = null
var _last_sim: Simulation = null

func sim() -> Simulation: 
	if _sim == null:
		_sim = Simulation.new()
	
	return _sim

func last_sim() -> Simulation:
	if _last_sim == null:
		_last_sim = sim().clone()
		
	return _last_sim

func load_snapshot(buf: DataBuffer, snapshot_size: int) -> void:
	_sim.deserialize(buf, snapshot_size)
	_last_sim = _sim.clone()
	
	print("received state snapshot:")
	sim().print_state()

func simulate(ctx: Context, input_frame: Dictionary, events: DataBuffer) -> void:
	_last_sim = _sim.clone()
	ctx.sim = _sim
	Simulation.simulate(ctx, input_frame, events)
	if _sim.state_tick % DEBUG_STATE_INTERVAL == 0:
		State.client.debug_state(_sim.state_tick, _sim.serialize_b64())
