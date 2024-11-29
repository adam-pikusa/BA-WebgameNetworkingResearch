class_name ServerTCP extends ServerReliable

class ConnectionTCP:
	var _tcp_peer := StreamPeerTCP.new()
	var confirmed := false
	var incoming_stream: PackedByteArray

	func init(peer: StreamPeerTCP) -> void:
		_tcp_peer = peer
		
	func update(server: ServerTCP):
		_tcp_peer.poll()
		
		var status := _tcp_peer.get_status()
		if status != StreamPeerTCP.STATUS_CONNECTED: return
		_tcp_peer.set_no_delay(true)
		
		while true:
			var avail_bytes := _tcp_peer.get_available_bytes()
			if avail_bytes == 0: break
			incoming_stream.append_array(_tcp_peer.get_data(avail_bytes)[1])

		if not confirmed and incoming_stream.size() >= 4:
			var recv_code := incoming_stream.decode_u32(0)
			shift_incoming_stream(4)
			print("recv confirm code:", recv_code)
			server.confirm(self, recv_code)

	func send(data: PackedByteArray) -> void:
		_tcp_peer.put_data(data)

	func shift_incoming_stream(amount: int):
		incoming_stream = incoming_stream.slice(amount)

class ClientConnectionTCP extends ServerReliable.ClientConnection:
	var con: ConnectionTCP = null
	var confirm_code: int
	
	func _init(client_id: int, client_name: String, confirm_code: int) -> void:
		super(client_id, client_name)
		self.confirm_code = confirm_code
		
	func finalize_connection(con: ConnectionTCP) -> void:
		self.con = con
		self.confirmed = true
		con.confirmed = true
	
	func get_incoming_stream() -> PackedByteArray: 
		return con.incoming_stream
	
	func shift_incoming_stream(amount: int):
		con.shift_incoming_stream(amount)

var connections: Array[ConnectionTCP] = []

var _tcp_server := TCPServer.new()
var _bind_address: String
var _bind_port: int

func _ready() -> void:
	got_join_requests.connect(on_got_join_requests)

func start(bind_address: String, bind_port: int) -> void:
	_bind_address = bind_address
	_bind_port = bind_port
	_tcp_server.listen(bind_port)

func update(sgsi: ServerGameStateInterface) -> void:
	for c: ConnectionTCP in connections: c.update(self)
	
	_parse_incoming_data(sgsi)
	
	if _tcp_server.is_connection_available():
		var peer := _tcp_server.take_connection()
		
		print("new WebSocketPeer connecting: %s:%s" % [peer.get_connected_host(), peer.get_connected_port()])
		
		var new_connection := ConnectionTCP.new()
		new_connection.init(peer)
		connections.append(new_connection)
		

func confirm(confirm_connection: ConnectionTCP, confirm_code: int) -> void:
	for client: ClientConnectionTCP in clients.values():
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
		if data[client_join_request_name]["connection_type"] != "tcp":
			printerr("client trying to connect with wrong protocol")
			continue
		
		var present := false
		for client: ClientConnectionTCP in clients.values():
			if client.client_name == client_join_request_name:
				present = true
				break
		if present: continue
		
		var new_code := _generate_confirm_code()
		var new_id := _get_next_client_id()
		var new_client := ClientConnectionTCP.new(new_id, client_join_request_name, new_code)
		clients[new_id] = new_client
		Http.request_post_json("join-responses/%s/%s" % [server_name, client_join_request_name], 
			JSON.stringify({
				"address": _bind_address,
				"port": _bind_port,
				"code": new_code,
				"client_id": new_id}), 
			func(code, data): pass)

func send(client_id: int, data: PackedByteArray) -> void:
	clients[client_id].con.send(data)
