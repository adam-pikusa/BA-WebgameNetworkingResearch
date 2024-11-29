class_name PredictionBuffer

var _buf: PackedInt64Array = []
var _base_tick := 0
var _sent_tick := 0

func _init(initial_tick: int) -> void:
	_sent_tick = initial_tick
	_base_tick = initial_tick + 1

func send_inputs(buf: DataBuffer, state_tick: int, client_tick: int, input: int) -> void:
	while _base_tick + (_buf.size() - 1) < client_tick: _buf.append(input)
	
	var input_count := client_tick - _sent_tick
	
	if input_count <= 0:
		buf.u8(0)
		return
	
	buf.u8(input_count)
	for i in input_count:
		_sent_tick += 1
		buf.i64(_buf[_sent_tick - _base_tick])

func get_input(at_tick: int) -> int:
	if at_tick < _base_tick: return 0
	if at_tick >= _base_tick + _buf.size(): return 0
	
	return _buf[at_tick - _base_tick]
