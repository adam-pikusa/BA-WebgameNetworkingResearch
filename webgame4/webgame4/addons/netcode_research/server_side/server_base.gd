class_name ServerBase extends Node

const DEBUG_STATE_INTERVAL := 30 * 10

signal got_join_requests(data: Dictionary)

var server_name: String

var _register_timer := Timer.new()
var _join_requests_timer := Timer.new()

var _next_client_id := 0

func init(server_name: String) -> void:
	self.server_name = server_name
	
	_register_timer = _create_timer(_on_register_timer)
	_join_requests_timer = _create_timer(_on_join_requests_timer)
	
	_register_timer.start()

func _on_register_timer() -> void:
	Http.request_post("servers/" + server_name, 
		func(code, data): 
			if code == 200:
				print("succesfully registered server")
				_register_timer.stop()
				_join_requests_timer.start())

func _on_join_requests_timer() -> void:
	Http.request_get(
		"join-requests/" + server_name, 
		_on_get_join_requests)

func _on_get_join_requests(code: int, data: PackedByteArray) -> void:
	if code != 200:
		printerr("failed to get join requests!:", code)
		return
	var data_json := JSON.parse_string(data.get_string_from_utf8())
	var res := {}
	for client in data_json:
		res[client] = JSON.parse_string(data_json[client])
	got_join_requests.emit(res)

func debug_state(tick: int, state: String) -> void:
	Http.request_post_json("debug/state/%s" % [server_name], 
	JSON.stringify({
		"client": server_name,
		"tick": tick, 
		"state": state}), func(code, data): pass)

func _generate_confirm_code() -> int:
	return randi()

func _get_next_client_id() -> int:
	_next_client_id += 1
	return _next_client_id - 1

func _create_timer(call_function: Callable, time: int = 3) -> Timer:
	var new_timer := Timer.new()
	add_child(new_timer)
	new_timer.wait_time = time
	new_timer.timeout.connect(call_function)
	return new_timer
