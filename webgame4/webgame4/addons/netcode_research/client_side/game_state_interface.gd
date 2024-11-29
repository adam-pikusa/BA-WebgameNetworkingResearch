class_name GameStateInterface

func load_snapshot(buf: DataBuffer, snapshot_size: int) -> void: pass
func simulate(input_frame: Dictionary, events: DataBuffer) -> void: pass
func get_state_tick() -> int: return 0
