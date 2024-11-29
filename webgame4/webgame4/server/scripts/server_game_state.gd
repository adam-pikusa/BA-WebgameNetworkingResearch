class_name ServerGameState extends ServerGameStateInterface

var sim := Simulation.new()
var ctx := Context.new()

func get_state_tick() -> int: 
	return sim.state_tick

func simulate(input_frame: Dictionary, event_buffer: DataBuffer) -> void:
	ctx.sim = sim
	Simulation.simulate(ctx, input_frame, event_buffer)

func serialize(buf: DataBuffer) -> void:
	sim.serialize(buf)

func serialize_b64() -> String: 
	return sim.serialize_b64()
