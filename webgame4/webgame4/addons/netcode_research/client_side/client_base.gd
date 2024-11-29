class_name ClientBase extends Node

signal got_servers(servers: Array[String])
signal join_request_result(success: bool, msg: String)
signal got_join_response(join_data)

var client_name: String
var server_name: String

var this_id := 0

var client_tick := 0

var clients := {}
var _all_clients_known := false

var p_buffer: PredictionBuffer

var err_buf := ErrorBuffer.new()
var _adjust_clock_timer := 0

var _latency_logger := LatencyLogger.new()
var _latency_timer := 0
const _LATENCY_LOG_INTERVAL := 5 * 30

var _join_response_timer := Timer.new()
var _client_timer := Timer.new()

func init() -> void:
	_join_response_timer = _create_timer(func(): 
		Http.request_get(
			"join-responses/%s/%s" % [server_name, client_name], 
			_on_get_join_response))
	_client_timer = _create_timer(_on_client_timer)

func _request_join(server_name: String, client_name: String, join_data: String) -> void:
	Http.request_post_json("join-requests/%s/%s" % [server_name, client_name], 
		join_data, 
		_on_post_join_request)
	
func _on_post_join_request(code: int, data: PackedByteArray):
	if code != 200:
		join_request_result.emit(false, data.get_string_from_utf8())
		return
	
	var response = JSON.parse_string(data.get_string_from_utf8())
	
	server_name = response["server_name"]
	client_name = response["client_name"]
	
	_join_response_timer.start()
	_client_timer.start()
	
	join_request_result.emit(true, "")
	
func get_client_name(client_id: int) -> String:
	if not client_id in clients:
		_all_clients_known = false
		return "?"
		
	return clients[client_id]

func _on_get_clients(code: int, data: PackedByteArray) -> void:
	if code != 200:
		printerr("failed to retrieve clients:", code)
		return
	
	var recv_clients = JSON.parse_string(data.get_string_from_utf8())
	
	print("got clients:")
	print(recv_clients)
	
	for c: String in recv_clients:
		clients[int(recv_clients[c]["id"])] = c
		
	print("client array:", clients)
	
func _on_client_timer() -> void:
	if not _all_clients_known:
		Http.request_get("clients/" + server_name, _on_get_clients)
		_all_clients_known = true
		
func _on_get_join_response(code: int, data: PackedByteArray) -> void:
	if code != 200:
		printerr("failed to retrieve join-response:", code)
		return
	
	_join_response_timer.stop()
	
	var join_data = JSON.parse_string(data.get_string_from_utf8())
	this_id = join_data["client_id"]
	print("received this id: ", this_id)
	got_join_response.emit(join_data)

func debug_state(tick: int, state: String) -> void:
	Http.request_post_json("debug/state/%s" % [server_name], 
		JSON.stringify({
			"client":client_name,
			"tick":tick,
			"state":state}), func(code, data): pass)

func _debug_latency() -> void:
	Http.request_post_json("debug/state/%s" % [server_name],
		JSON.stringify({
			"client": client_name,
			"latency_data": _latency_logger.dump_b64()
		}), func(code, data): pass)

func get_servers() -> void:
	Http.request_get("servers", 
		func(code: int, data: PackedByteArray):
			if code != 200:
				printerr("failed to retrieve server list:", code)
				return
			var result = JSON.parse_string(data.get_string_from_utf8())
			var servers: Array[String]
			servers.assign(result)
			print("got server list:")
			print(servers)
			got_servers.emit(servers))

func update(gsi: GameStateInterface, input_sample: int) -> void:
	printerr("update func not implemented on client!")

func _base_update(state_tick: int):
	_adjust_clock_timer += 1
	_latency_timer += 1
	
	if state_tick > client_tick:
		var temp := client_tick
		client_tick = state_tick + 2
		print("adjusted client_tick from %d to %d" % [temp, client_tick])
	
	var stable_error := err_buf.get_avg()
	
	_latency_logger.log_latency(Time.get_unix_time_from_system(), stable_error)
	
	if _adjust_clock_timer > 30 * 3:
		_adjust_clock_timer = 0
		
		var adj := 0
		
		if stable_error > 3: adj = -1  
		if stable_error < 2: adj = stable_error + 2
			
		print("adjusting client_tick by ", adj)
		client_tick += adj
		
	if _latency_timer > _LATENCY_LOG_INTERVAL:
		_latency_timer = 0
		_debug_latency()

func _create_timer(call_function: Callable, time: int = 3) -> Timer:
	var new_timer := Timer.new()
	add_child(new_timer)
	new_timer.wait_time = time
	new_timer.timeout.connect(call_function)
	return new_timer
