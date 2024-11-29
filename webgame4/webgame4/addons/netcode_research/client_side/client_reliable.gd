class_name ClientReliable extends ClientBase

var _incoming_events := DataBuffer.new()
var _buf := DataBuffer.new()
var incoming_stream: PackedByteArray

func shift_incoming_stream(amount: int):
	incoming_stream = incoming_stream.slice(amount)

func send(data: PackedByteArray) -> void: printerr("send func not implemented on client!")

func _parse_incoming_stream(gsi: GameStateInterface, input_sample: int) -> void:
	while true:
		_buf.begin_packet_read(incoming_stream)
		
		if _buf.bytes_remaining() == 0: 
			break
		
		if _parse_packet(gsi, false):
			_buf.begin_packet_read(incoming_stream)
			_parse_packet(gsi, true)
			
		else:
			print("packet incomplete")
			break
			
	_base_update(gsi.get_state_tick())

	if p_buffer == null: return

	_buf.begin_packet_write()
	p_buffer.send_inputs(_buf, gsi.get_state_tick(), client_tick, input_sample)
		
	var events_size := 0
	_buf.u8(events_size)
	
	send(_buf.get_buf())
	
	client_tick += 1

func _parse_packet(gsi: GameStateInterface, commit: bool) -> bool:
	var input_frame = {}
	_incoming_events.begin_packet_write()

	match _buf.u8():
		Protocol.PT_SNAPSHOT:
			if _buf.bytes_remaining() < 4: return false
			var snapshot_size := _buf.u32()
			
			if _buf.bytes_remaining() < snapshot_size: return false
			if commit:
				gsi.load_snapshot(_buf, snapshot_size)
				p_buffer = PredictionBuffer.new(gsi.get_state_tick() - 1)
			else:
				_buf.advance(snapshot_size)
			
		Protocol.PT_DATA:
			if _buf.bytes_remaining() < 3: return false
			
			var error := _buf.i16()
			if commit: 
				err_buf.add(error)
			
			var count := _buf.u8()
			
			if _buf.bytes_remaining() < count * (1 + 8): return false
			for i: int in count:
				var input_client_id := _buf.u8()
				var input := _buf.i64()
				
				if commit: 
					input_frame[input_client_id] = input
				
			if _buf.bytes_remaining() == 0: return false
			var events_size := _buf.u8()
			
			if events_size > 0:
				if _buf.bytes_remaining() < events_size: return false
				if commit: 
					_incoming_events.copy_from_recv_buffer(_buf, events_size)
				
				_buf.advance(events_size)
			
			if commit:
				_incoming_events.begin_packet_read(_incoming_events.get_buf())
				gsi.simulate(input_frame, _incoming_events)
	
	if commit: 
		shift_incoming_stream(_buf.bytes_read())
	
	return true
