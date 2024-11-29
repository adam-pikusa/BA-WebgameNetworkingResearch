extends Control

enum SelectProtocol {
	WebSocket,
	WebRTC
}

@export var select_protocol_popup: Control
@export var game_scene: PackedScene
@export var debug_scene: PackedScene

@export var servers: ItemList
@export var client_name: LineEdit
@export var name_error: Label
@export var join_button: Button

var name_regex := RegEx.new()

func _ready() -> void:
	var api_url = "https://dev3.gasstationsoftware.net/api/"
	name_regex.compile(r"^[a-zA-Z0-9]*$")
	client_name.text = _generate_default_name()
	
	if not FileAccess.file_exists(Cfg.CONFIG_PATH):
		printerr("cfg file not found at [%s]"  % [Cfg.CONFIG_PATH])
		Http.init(api_url)
		select_protocol_popup.visible = true
		return
	
	Cfg.cfg = JSON.parse_string(FileAccess.get_file_as_string(Cfg.CONFIG_PATH))

	print('parsed config:')
	print(Cfg.cfg)
	
	if "api_url" in Cfg.cfg: 
		api_url = Cfg.cfg["api_url"]
	
	Http.init(api_url)
	
	if "protocol" in Cfg.cfg:
		_configure(Cfg.cfg["protcol"])
	else:
		select_protocol_popup.visible = true
	
	if "client_name" in Cfg.cfg: 
		client_name.text = Cfg.cfg["client_name"]
	
	if "auto_join" in Cfg.cfg:
		State.client.request_join(Cfg.cfg["auto_join"], client_name.text)

func _configure(protocol: String) -> void:
	State.game = GameState.new()
	
	match protocol:
		"websocket":
			State.client = ClientWebSocket.new()
		"webrtc":
			State.client = ClientWebRTC.new()
		"enet":
			State.client = ClientENet.new()
		"tcp":
			State.client = ClientTCP.new()
	
	State.client.got_servers.connect(_on_get_servers)
	State.client.join_request_result.connect(_on_join_request_result)
	
	State.add_child(State.client)
	State.client.init()

func _on_button_refresh_servers_pressed() -> void:
	State.client.get_servers()

func _on_button_join_pressed() -> void:
	if servers.get_selected_items().size() != 1: return
	var selected_server := servers.get_item_text(servers.get_selected_items()[0])
	
	if selected_server == "debug":
		get_tree().change_scene_to_packed(debug_scene)
		return
	
	if client_name.text.is_empty(): return
	if name_regex.search(client_name.text) == null: return
	
	join_button.disabled = true
	client_name.editable = false
	
	State.client.request_join(selected_server, client_name.text)

func _on_get_servers(server_list: Array[String]):
	servers.clear()
	servers.add_item("debug")
	for server in server_list: 
		servers.add_item(server)

func _on_join_request_result(success: bool, msg: String) -> void:
	if !success:
		name_error.text = msg
		name_error.visible = true
		join_button.disabled = false
		client_name.editable = true
		return
	
	get_tree().change_scene_to_packed(game_scene)

func _on_line_edit_client_name_text_changed(new_text: String) -> void:
	if client_name.text.is_empty():
		name_error.text = "name cannot be empty"
		name_error.visible = true
		return
		
	if name_regex.search(client_name.text) == null:
		name_error.text = "name must be alphanumeric"
		name_error.visible = true
		return
		
	name_error.visible = false

func _generate_default_name() -> String:
	return "player" + str(randi())

func _on_button_web_rtc_pressed() -> void:
	select_protocol_popup.visible = false
	_configure("webrtc")

func _on_button_web_socket_pressed() -> void:
	select_protocol_popup.visible = false
	_configure("websocket")

func _on_button_e_net_pressed() -> void:
	select_protocol_popup.visible = false
	_configure("enet")

func _on_button_tcp_pressed() -> void:
	select_protocol_popup.visible = false
	_configure("tcp")
