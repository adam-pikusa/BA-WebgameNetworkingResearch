class_name ServerWebSocket extends ServerReliable

class ConnectionWebSocket:
	var con := WebSocketPeer.new()
	var confirmed := false
	var incoming_stream: PackedByteArray

	func init(peer: StreamPeerTCP) -> void:
		con.accept_stream(peer)
		
	func update(server: ServerWebSocket):
		con.poll()
		
		var ready_state := con.get_ready_state()
		if ready_state != WebSocketPeer.STATE_OPEN: return
		con.set_no_delay(true)
		
		while true:
			var recv_packets := con.get_available_packet_count()
			if recv_packets == 0: break
			
			incoming_stream.append_array(con.get_packet())

		if not confirmed and incoming_stream.size() >= 4:
			var recv_code := incoming_stream.decode_u32(0)
			shift_incoming_stream(4)
			print("recv confirm code:", recv_code)
			server.confirm(self, recv_code)

	func send(data: PackedByteArray) -> void:
		con.put_packet(data)

	func shift_incoming_stream(amount: int):
		incoming_stream = incoming_stream.slice(amount)

class ClientConnectionWebSocket extends ServerReliable.ClientConnection:
	var con: ConnectionWebSocket = null
	var confirm_code: int
	
	func _init(client_id: int, client_name: String, confirm_code: int) -> void:
		super(client_id, client_name)
		self.confirm_code = confirm_code
		
	func finalize_connection(con: ConnectionWebSocket) -> void:
		self.con = con
		self.confirmed = true
		con.confirmed = true
	
	func get_incoming_stream() -> PackedByteArray: 
		return con.incoming_stream
	
	func shift_incoming_stream(amount: int):
		con.shift_incoming_stream(amount)

var connections: Array[ConnectionWebSocket] = []

var _tcp_server := TCPServer.new()
var _bind_url: String

func _ready() -> void:
	got_join_requests.connect(on_got_join_requests)

func start(bind_port: int, bind_url: String) -> void:
	_bind_url = bind_url
	_tcp_server.listen(bind_port)

func update(sgsi: ServerGameStateInterface) -> void:
	for c: ConnectionWebSocket in connections: c.update(self)
	
	_parse_incoming_data(sgsi)
	
	if _tcp_server.is_connection_available():
		var peer := _tcp_server.take_connection()
		
		print("new WebSocketPeer connecting: %s:%s" % [peer.get_connected_host(), peer.get_connected_port()])
		
		var new_connection := ConnectionWebSocket.new()
		new_connection.init(peer)
		connections.append(new_connection)

func confirm(confirm_connection: ConnectionWebSocket, confirm_code: int) -> void:
	for client: ClientConnectionWebSocket in clients.values():
		if client.confirm_code != confirm_code: continue
		
		print("registered new client: ", client.client_name)
		client.finalize_connection(confirm_connection)
		
		Http.request_post("clients/%s/%s/%d" % [server_name, client.client_name, client.client_id], 
			func(code, data): 
				print("post new player result:", code))
				
		return
		
	connections.erase(confirm_connection)
	print("connection %s:%d failed confirm test, removing..." % [confirm_connection.con.get_connected_host(), confirm_connection.con.get_connected_port()])

func on_got_join_requests(data: Dictionary) -> void:
	print("got join request data:", data)
	
	for client_join_request_name in data:
		if data[client_join_request_name]["connection_type"] != "websocket":
			printerr("client trying to connect with wrong protocol")
			continue
		
		var present := false
		for client: ClientConnectionWebSocket in clients.values():
			if client.client_name == client_join_request_name:
				present = true
				break
		if present: continue
		
		var new_code := _generate_confirm_code()
		var new_id := _get_next_client_id()
		var new_client := ClientConnectionWebSocket.new(new_id, client_join_request_name, new_code)
		clients[new_id] = new_client
		Http.request_post_json("join-responses/%s/%s" % [server_name, client_join_request_name], 
			JSON.stringify({
				"url": _bind_url,
				"code": new_code,
				"client_id": new_id}), 
			func(code, data): pass)

func send(client_id: int, data: PackedByteArray) -> void:
	clients[client_id].con.send(data)
