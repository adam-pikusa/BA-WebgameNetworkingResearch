class_name LatencyLogger

var _time_latency_data: PackedFloat32Array = []

func log_latency(time: float, latency: float) -> void:
	_time_latency_data.append(time)
	_time_latency_data.append(latency)
	
func dump_b64() -> String:
	var result := Marshalls.raw_to_base64(_time_latency_data.to_byte_array())
	_time_latency_data.clear()
	return result
