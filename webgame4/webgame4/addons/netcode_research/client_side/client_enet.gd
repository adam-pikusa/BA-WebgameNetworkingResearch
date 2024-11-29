class_name ClientENet extends ClientReliable

var _enet_con: ENetConnection
var _enet_peer: ENetPacketPeer
var _outgoing_stream: PackedByteArray

func _ready() -> void:
	got_join_response.connect(func(join_data):
		var addr: String = join_data["address"]
		var port: int = join_data["port"]
		var code: int = join_data["code"]
		
		print("enet client connecting to %s:%d with code %d" % [addr, port, code])
		_enet_con = ENetConnection.new()
		_enet_con.create_host(128, 2)
		_enet_peer = _enet_con.connect_to_host(addr, port, 2, code))

func request_join(server_name: String, client_name: String) -> void:
	_request_join(server_name, client_name, JSON.stringify({
		"connection_type": "enet" 
	}))

func _recv() -> void:
	if _enet_con == null: return
	while true:
		var res := _enet_con.service()
		var event_type: ENetConnection.EventType = res[0]
		var peer: ENetPacketPeer = res[1]
		var data = res[2]
		var channel: int = res[3]
		
		match event_type:
			ENetConnection.EventType.EVENT_ERROR:
				printerr("enet error.")
				return
			ENetConnection.EventType.EVENT_NONE:
				return
			ENetConnection.EventType.EVENT_RECEIVE:
				#print("enet got data from ", peer.get_remote_address(), ":", peer.get_remote_port())
				incoming_stream.append_array(peer.get_packet())

func update(gsi: GameStateInterface, input_sample: int) -> void:
	_recv()
	_parse_incoming_stream(gsi, input_sample)

func send(data: PackedByteArray) -> void:
	_outgoing_stream.append_array(data)
	
	if _enet_peer.get_state() != ENetPacketPeer.PeerState.STATE_CONNECTED:
		printerr("cant send data in current moment")
		return
		
	_enet_peer.send(0, _outgoing_stream, ENetPacketPeer.FLAG_RELIABLE)
	_outgoing_stream.clear()

func send_rel(data: PackedByteArray) -> void:
	_enet_peer.send(0, data, ENetPacketPeer.FLAG_RELIABLE)

func send_unrel(packet: PackedByteArray) -> void:
	_enet_peer.send(1, packet, ENetPacketPeer.FLAG_UNRELIABLE_FRAGMENT)
