class_name InputBufferReliable

# buffer receives inputs 
# - in order 
# - starting from the tick of the first snapshot the client received
# - without gaps
# but the inputs might be too old or too far into the future
# -> ignore these bad inputs

# get_input is called every simulation tick
# -> return a default value if necessary
# -> buffer tick is coupled to server_tick 

const BUFFER_SIZE := 5 * 30

var _buffer: PackedInt64Array # queue
var _latest_recv_input := 0

func _init(starting_input_tick: int) -> void:
	_buffer.resize(BUFFER_SIZE)
	_latest_recv_input = starting_input_tick

func receive_input(server_tick: int, input: int) -> void:
	_latest_recv_input += 1
	
	if _latest_recv_input < server_tick:
		# ignore: too late
		return
		
	elif _latest_recv_input >= server_tick + BUFFER_SIZE:
		# ignore: too far into the future 
		return
	
	else:
		_buffer[_latest_recv_input - server_tick] = input

func get_input() -> int:
	var input := _buffer[0]
	
	# shift buffer
	for i in _buffer.size() - 1:
		_buffer[i] = _buffer[i + 1]
		
	_buffer[_buffer.size() - 1] = 0

	return input

func get_error(server_tick: int) -> int:
	return _latest_recv_input - server_tick 
