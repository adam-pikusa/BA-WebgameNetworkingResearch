class_name ClientWebRTC extends ClientReliable

const MSG_API := "messages"

const WEBRTCSETUP := {
	"iceServers": [
		{ "urls": ["stun:stun.l.google.com:19302"] }
	]
}

var _ice_timer: Timer

var _wrtc_con: WebRTCPeerConnection
var _data_ch_rel: WebRTCDataChannel 

var _already_added_ice: Array[String] = []
var _outgoing_ice_queue: Array[String] = []
var _sent_ice: Array[String] = []
var _client_sdp: String = ""

func _ready() -> void:
	got_join_response.connect(_on_got_join_response)
	_wrtc_con = WebRTCPeerConnection.new()
	_wrtc_con.initialize(WEBRTCSETUP)
	_wrtc_con.session_description_created.connect(_on_sesh_desc_created)
	_wrtc_con.ice_candidate_created.connect(_on_ice_created)
	
	_data_ch_rel = _wrtc_con.create_data_channel("rel", {"id":1, "negotiated": true})

	_wrtc_con.create_offer()

func _on_sesh_desc_created(type: String, sdp: String):
	print("sesh desc created: {%s,%s}" % [type,sdp])
	_wrtc_con.set_local_description(type, sdp)
	_client_sdp = sdp
	
func request_join(server_name: String, client_name: String) -> void:
	if _client_sdp == "":
		printerr("client not yet ready to join any server")
		return
		
	_request_join(server_name, client_name, JSON.stringify({ 
		"connection_type": "webrtc",
		"sdp": _client_sdp
	}))

func _on_got_join_response(join_data: Dictionary) -> void:
	_ice_timer = _create_timer(_on_ice_timer)
	_ice_timer.start()
	_wrtc_con.set_remote_description("answer", join_data["sdp"])

func _send_ice() -> void:
	for i in _outgoing_ice_queue.size():
		var ice := _outgoing_ice_queue[i]
		if not ice in _sent_ice:
			Http.request_post_text(
				"%s/%s/%s/client/ice%d" % [MSG_API, server_name, client_name, i], 
				ice, 
				func(code, data):
					if code == 200:
						_sent_ice.append(ice))

func _on_ice_created(media: String, index: int, ice_name: String):
	print("ice created: {%s,%d,%s}" % [media, index, ice_name])
	_outgoing_ice_queue.append(ice_name)
	_send_ice()
	
func _on_ice_timer() -> void:
	# if open: _ice_timer.stop()
	_send_ice()
	Http.request_get("%s/%s/%s/client" % [MSG_API, server_name, client_name], _on_get_messages)
	
func _on_get_messages(code: int, data: PackedByteArray) -> void:
	if code != 200: 
		printerr("failed to get ice messages!:", code)
		return
	var messages = JSON.parse_string(data.get_string_from_utf8())
	for ice in messages.values():
		if not ice in _already_added_ice:
			_already_added_ice.append(ice)
			print("ADDING ICE CANDIDATE: ", ice)
			_wrtc_con.add_ice_candidate("0", 0, ice)

func data_ch_ready() -> bool: return _data_ch_rel.get_ready_state() == WebRTCDataChannel.STATE_OPEN

func _process(delta: float) -> void:
	if _wrtc_con == null or _data_ch_rel == null: return
	
	_wrtc_con.poll()
	while data_ch_ready() and _data_ch_rel.get_available_packet_count() > 0:
		print("packet received")
		incoming_stream.append_array(_data_ch_rel.get_packet())

func update(gsi: GameStateInterface, input_sample: int) -> void:
	_parse_incoming_stream(gsi, input_sample)

func send(data: PackedByteArray) -> void:
	_data_ch_rel.put_packet(data)
