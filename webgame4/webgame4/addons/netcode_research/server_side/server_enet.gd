class_name ServerENet extends ServerReliable

class ClientConnectionENet extends ServerReliable.ClientConnection:
	var _enet_peer: ENetPacketPeer
	var _confirm_code: int
	var incoming_stream: PackedByteArray
	var _outgoing_stream: PackedByteArray
	
	func _init(client_id: int, client_name: String, confirm_code: int) -> void:
		super(client_id, client_name)
		_confirm_code = confirm_code
		
	func is_peer(peer: ENetPacketPeer) -> bool:
		return _enet_peer == peer
		
	func confirm_new_connection(peer: ENetPacketPeer, data: int) -> void:
		if data != _confirm_code: return
		_enet_peer = peer
		confirmed = true
		print("confirmed new enet connection:", [peer.get_remote_address(), peer.get_remote_port()])

	func send_stream_data(packet: PackedByteArray) -> void:
		_outgoing_stream.append_array(packet)
		
		if _enet_peer.get_state() != ENetPacketPeer.PeerState.STATE_CONNECTED: 
			return
			
		_enet_peer.send(0, _outgoing_stream, ENetPacketPeer.FLAG_RELIABLE)
		_outgoing_stream.clear()

	func received_stream_data(packet: PackedByteArray) -> void:
		incoming_stream.append_array(packet)
		
	func received_unreliable_data(packet: PackedByteArray) -> void:
		pass
		
	func get_incoming_stream() -> PackedByteArray: 
		return incoming_stream
		
	func shift_incoming_stream(amount: int):
		incoming_stream = incoming_stream.slice(amount)

var _enet_con := ENetConnection.new()
var _bind_address: String
var _bind_port: int

func _ready() -> void:
	got_join_requests.connect(on_got_join_requests)

func start(bind_address: String, bind_port: int) -> void:
	_bind_address = bind_address
	_bind_port = bind_port
	_enet_con.create_host_bound("0.0.0.0", _bind_port, 128, 2)

func on_got_join_requests(data: Dictionary) -> void:
	print("got join request data:", data)
	
	for client_join_request_name in data:
		if data[client_join_request_name]["connection_type"] != "enet":
			printerr("client trying to connect with wrong protocol")
			continue
		
		var present := false
		for client: ClientConnectionENet in clients.values():
			if client.client_name == client_join_request_name:
				present = true
				break
		if present: continue
		
		var new_code := _generate_confirm_code()
		var new_id := _get_next_client_id()
		var new_client := ClientConnectionENet.new(new_id, client_join_request_name, new_code)
		clients[new_id] = new_client
		Http.request_post_json("join-responses/%s/%s" % [server_name, client_join_request_name], 
			JSON.stringify({
				"address": _bind_address,
				"port": _bind_port,
				"code": new_code,
				"client_id": new_id}), 
			func(code, data): pass)

func send(client_id: int, data: PackedByteArray) -> void:
	(clients[client_id] as ClientConnectionENet).send_stream_data(data)
	
func update(sgsi: ServerGameStateInterface) -> void:
	_parse_incoming_data(sgsi)
	
	while true:
		var res := _enet_con.service()
		var event_type: ENetConnection.EventType = res[0]
		var peer: ENetPacketPeer = res[1]
		var data: int = res[2]
		var channel: int = res[3]
		
		match event_type:
			ENetConnection.EventType.EVENT_ERROR:
				return
			ENetConnection.EventType.EVENT_NONE:
				return
			ENetConnection.EventType.EVENT_RECEIVE:
				for client: ClientConnectionENet in clients.values():
					if client.is_peer(peer):
						var packet = peer.get_packet()
						match channel:
							0:
								client.received_stream_data(packet)
							1:
								client.received_unreliable_data(packet)
						
			ENetConnection.EventType.EVENT_CONNECT:
				print("connection event with code ", data)
				for client: ClientConnectionENet in clients.values():
					client.confirm_new_connection(peer, data)
				
			ENetConnection.EventType.EVENT_DISCONNECT:
				#var remove_client: ClientConnectionENet
				#var remove_client_name: String
				#
				#for client_name: String in con:
					#if con[client_name].is_peer(peer):
						#remove_client = con[client_name]
						#remove_client_name = client_name
						#break
				#
				#print("client ", remove_client_name, " disconnected")
				#
				#remove_child(remove_client)
				#con.erase(remove_client)
				#remove_client.free()
				pass
				
