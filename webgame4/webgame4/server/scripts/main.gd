extends Control

func _ready() -> void: 
	print("reading cfg...")
	
	if not FileAccess.file_exists(Cfg.CONFIG_PATH): 
		printerr("cfg file at [%s] not found"  % [Cfg.CONFIG_PATH])
		get_tree().quit()
		return
	
	Cfg.cfg = JSON.parse_string(FileAccess.get_file_as_string(Cfg.CONFIG_PATH))

	print('parsed config:')
	print(Cfg.cfg)
	
	Http.init(Cfg.cfg["api_url"])
	
	match Cfg.cfg["protocol"]:
		"websocket":
			State.server = ServerWebSocket.new()
			State.add_child(State.server)
			State.server.init(Cfg.cfg["server_name"])
			State.server.start(
				Cfg.cfg["bind_port"], 
				Cfg.cfg["bind_url"])
		
		"webrtc":
			State.server = ServerWebRTC.new()
			State.add_child(State.server)
			State.server.init(Cfg.cfg["server_name"])
		
		"enet":
			State.server = ServerENet.new()
			State.add_child(State.server)
			State.server.init(Cfg.cfg["server_name"])
			State.server.start(
				Cfg.cfg["bind_address"],
				Cfg.cfg["bind_port"])
	
		"tcp":
			State.server = ServerTCP.new()
			State.add_child(State.server)
			State.server.init(Cfg.cfg["server_name"])
			State.server.start(
				Cfg.cfg["bind_address"],
				Cfg.cfg["bind_port"])
	
	get_tree().change_scene_to_file("res://server/scenes/game.tscn")
