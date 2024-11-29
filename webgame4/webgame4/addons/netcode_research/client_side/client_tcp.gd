class_name ClientTCP extends ClientReliable

var _tcp_peer := StreamPeerTCP.new()
var _sent_code := false
var _confirm_code

func _ready() -> void:
	got_join_response.connect(func(join_data):
		_confirm_code = join_data["code"]
		_tcp_peer.connect_to_host(join_data["address"], join_data["port"]))

func _send_confirmation_code():
	var buf: PackedByteArray
	buf.resize(4)
	buf.encode_u32(0, _confirm_code)
	_tcp_peer.put_data(buf)
	_sent_code = true
	print("sent confirmation code")

func request_join(server_name: String, client_name: String) -> void:
	_request_join(server_name, client_name, JSON.stringify({ 
		"connection_type": "tcp" 
	}))

func _recv() -> void:
	_tcp_peer.poll()

	var status := _tcp_peer.get_status()
	if status != StreamPeerTCP.STATUS_CONNECTED:
		return
	
	if !_sent_code and _confirm_code != null:
		_send_confirmation_code()
		
	while true:
		var avail_bytes := _tcp_peer.get_available_bytes()
		if avail_bytes == 0: return
		incoming_stream.append_array(_tcp_peer.get_data(avail_bytes))

func update(gsi: GameStateInterface, input_sample: int) -> void:
	_recv()
	_parse_incoming_stream(gsi, input_sample)

func send(data: PackedByteArray) -> void:
	_tcp_peer.put_data(data)
