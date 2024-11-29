class_name ServerWebRTC extends ServerReliable

func _ready() -> void:
	got_join_requests.connect(on_got_join_requests)
	
func on_got_join_requests(data: Dictionary) -> void:
	print("got join request data:", data)
	
	for client_join_request_name in data:
		if data[client_join_request_name]["connection_type"] != "webrtc":
			printerr("client trying to connect with wrong protocol")
			continue
		
		var present := false
		for client: ClientConnectionWebRTC in clients.values():
			if client.client_name == client_join_request_name:
				present = true
				break
		if present: continue
		
		var new_id := _get_next_client_id()
		var new_client := ClientConnectionWebRTC.new(
			new_id, 
			client_join_request_name, 
			server_name, 
			data[client_join_request_name]["sdp"])
		add_child(new_client)
		clients[new_id] = new_client

func update(sgsi: ServerGameStateInterface) -> void:
	_parse_incoming_data(sgsi)
	
func send(client_id: int, data: PackedByteArray) -> void:
	clients[client_id].send(data)
