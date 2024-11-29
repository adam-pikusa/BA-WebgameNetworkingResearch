class_name GameState extends GameStateInterface

var h := History.new()
var ctx := Context.new()
var tick_interp := 0.0
var block_movement := false
var look_sens := 0.01
var cur_cam: Cam

func set_cam(cam: Cam) -> void:
	if cur_cam == cam: return
	cur_cam = cam
	cur_cam.focus()

func load_snapshot(buf: DataBuffer, snapshot_size: int) -> void:
	h.load_snapshot(buf, snapshot_size)
	
func simulate(input_frame: Dictionary, events: DataBuffer) -> void:
	h.simulate(ctx, input_frame, events)
	
func get_state_tick() -> int:
	return h.sim().state_tick
