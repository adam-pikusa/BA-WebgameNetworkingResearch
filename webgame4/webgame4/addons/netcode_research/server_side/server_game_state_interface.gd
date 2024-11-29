class_name ServerGameStateInterface

func get_state_tick() -> int: return 0
func simulate(input_frame: Dictionary, event_buffer: DataBuffer) -> void: pass
func serialize(buf: DataBuffer) -> void: pass
func serialize_b64() -> String: return ""
