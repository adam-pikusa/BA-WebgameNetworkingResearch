class_name ServerReliable extends ServerBase

class ClientConnection extends Node:
	var client_id: int
	var client_name: String
	var confirmed := false
	
	func _init(client_id: int, client_name: String) -> void:
		self.client_id = client_id
		self.client_name = client_name
	
	func get_incoming_stream() -> PackedByteArray: return []
	func shift_incoming_stream(amount: int): pass
	

var clients := {} # client_id: int -> ClientConnection
var inputs := {} # client: Client -> corresponding inputs: Inputs
var input_frame := {} # client_id: int -> input: int

var _buf := DataBuffer.new()
var _incoming_event_buffer := DataBuffer.new()

func send(client_id: int, data: PackedByteArray) -> void: pass

func _parse_packet(sgsi: ServerGameStateInterface, client: ClientConnection, commit: bool) -> bool:
	var client_inputs: InputBufferReliable = inputs[client]
	
	_buf.begin_packet_read(client.get_incoming_stream())
	
	if _buf.bytes_remaining() == 0: return false
	var input_count := _buf.u8()
	
	if _buf.bytes_remaining() < input_count * 8: return false
	for i in input_count:
		var input := _buf.i64()
		if commit: 
			client_inputs.receive_input(sgsi.get_state_tick(), input)
	
	if _buf.bytes_remaining() == 0: return false
	var events_size := _buf.u8()
	
	if _buf.bytes_remaining() < events_size: return false
	if commit:
		_incoming_event_buffer.copy_from_recv_buffer(_buf, events_size)
	
	else:
		_buf.advance(events_size)
	
	if commit:
		client.shift_incoming_stream(_buf.bytes_read())
	
	return true

func _parse_incoming_data(sgsi: ServerGameStateInterface):
	_incoming_event_buffer.begin_packet_write()
	
	for client: ClientConnection in inputs:
		while true:
			if _parse_packet(sgsi, client, false): 
				_parse_packet(sgsi, client, true)
				
			else:
				break

	input_frame.clear()
	
	for client: ClientConnection in inputs:
		input_frame[client.client_id] = inputs[client].get_input()
	
	# generate server events
	
	# new client event
	for client: ClientConnection in clients.values():
		if not client.confirmed: continue
		if client in inputs: continue
	
		_incoming_event_buffer.u8(Protocol.NR_EVENT_PLAYER_JOINED)
		_incoming_event_buffer.u8(client.client_id)
		input_frame[client.client_id] = 0
	
	# simulate
	_incoming_event_buffer.begin_packet_read(_incoming_event_buffer.get_buf())
	sgsi.simulate(input_frame, _incoming_event_buffer)
	
	if sgsi.get_state_tick() % DEBUG_STATE_INTERVAL == 0:
		debug_state(sgsi.get_state_tick(), sgsi.serialize_b64()) 
	
	
	for client: ClientConnection in clients.values():
		if not client.confirmed: continue
		
		_buf.begin_packet_write()
		
		if not client in inputs:
			# new clients get only a snapshot
			
			var ni := InputBufferReliable.new(sgsi.get_state_tick() - 1)
			inputs[client] = ni
			
			_buf.u8(Protocol.PT_SNAPSHOT)
			
			var index_of_snapshot_size_slot := _buf.bytes_written()
			_buf.advance(4)
			
			sgsi.serialize(_buf)
			
			_buf.insert_u32(index_of_snapshot_size_slot, _buf.bytes_written() - 2)
		
		else:
			# existing clients get inputs and events

			var client_inputs: InputBufferReliable = inputs[client]
			
			_buf.u8(Protocol.PT_DATA)
			_buf.i16(client_inputs.get_error(sgsi.get_state_tick()))
			_buf.u8(input_frame.size())
			
			for cii: int in input_frame:
				_buf.u8(cii)
				_buf.i64(input_frame[cii])
			
			# buffer cursor already advanced by sim.simulate
			var events_size := _incoming_event_buffer.bytes_read()
			_buf.u8(events_size)
			if events_size > 0:
				#print("sending events:", events_size)
				_buf.copy_from_beginning_recv_buffer(_incoming_event_buffer)
				#print("data cursor: %d data packet:" % [_buf._cursor], _buf._buf)
		
		send(client.client_id, _buf.get_buf())
