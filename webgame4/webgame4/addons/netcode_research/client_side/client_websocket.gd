class_name ClientWebSocket extends ClientReliable

var _ws_peer := WebSocketPeer.new()

var _sent_code := false
var _confirm_code

func _ready() -> void:
	got_join_response.connect(func(join_data):
		_confirm_code = join_data["code"]
		_ws_peer.connect_to_url(join_data["url"], TLSOptions.client_unsafe()))

func _send_confirmation_code():
	var buf: PackedByteArray
	buf.resize(4)
	buf.encode_u32(0, _confirm_code)
	_ws_peer.put_packet(buf)
	_sent_code = true
	print("sent confirmation code")

func request_join(server_name: String, client_name: String) -> void:
	_request_join(server_name, client_name, JSON.stringify({ 
		"connection_type": "websocket" 
	}))

func _recv() -> void:
	_ws_peer.poll()

	var ready_state := _ws_peer.get_ready_state()
	if ready_state != WebSocketPeer.STATE_OPEN:
		#printerr("websocket client not open:", ErrorCodes.WebSocket_ReadyState[ready_state])
		return
	
	if !_sent_code and _confirm_code != null:
		_send_confirmation_code()
		
	while true:
		var recv_packets := _ws_peer.get_available_packet_count()
		if recv_packets == 0: return
		#print("recv server data: %d" % [recv_packets])
		incoming_stream.append_array(_ws_peer.get_packet())

func update(gsi: GameStateInterface, input_sample: int) -> void:
	_recv()
	_parse_incoming_stream(gsi, input_sample)

func send(data: PackedByteArray) -> void:
	_ws_peer.put_packet(data)
