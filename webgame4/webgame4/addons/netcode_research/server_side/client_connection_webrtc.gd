class_name ClientConnectionWebRTC extends ServerReliable.ClientConnection

const MSG_API := "messages"

const WEBRTCSETUP := {
	"iceServers": [
		{ "urls": ["stun:stun.l.google.com:19302"] }
	]
}

var _server_name: String

var _ice_timer: Timer
var _wrtc_con: WebRTCPeerConnection
var _data_ch_rel: WebRTCDataChannel

var _already_added_ice: Array[String] = []
var _outgoing_ice: Array[String] = []

var _incoming_stream: PackedByteArray

func _init(client_id: int, client_name: String, server_name: String, client_sdp: String) -> void:
	super(client_id, client_name)
	_server_name = server_name
	
	_wrtc_con = WebRTCPeerConnection.new()
	_wrtc_con.session_description_created.connect(_on_sesh_desc_created)
	_wrtc_con.ice_candidate_created.connect(_on_ice_created)
	_wrtc_con.initialize(WEBRTCSETUP)
	
	_data_ch_rel = _wrtc_con.create_data_channel("rel", {"id":1, "negotiated":true})
	
	_wrtc_con.set_remote_description("offer", client_sdp)
	
	print("created new webrtc connection:", _wrtc_con)
	
func _on_sesh_desc_created(type: String, sdp: String):
	print("sesh desc created: {%s,%s}" % [type,sdp])
	_wrtc_con.set_local_description(type, sdp)

	Http.request_post_json("join-responses/%s/%s" % [_server_name, client_name], 
		JSON.stringify({
			"sdp": sdp,
			"client_id": client_id}), 
		func(code, data): pass)
	
	_ice_timer = Timer.new()
	add_child(_ice_timer)
	_ice_timer.wait_time = 3
	_ice_timer.timeout.connect(_on_ice_timer)
	_ice_timer.start()

func _on_ice_created(media: String, index: int, ice_name: String):
	print("ice created: {%s,%d,%s}" % [media, index, ice_name])
	_outgoing_ice.append(ice_name)
	Http.request_post_text("%s/%s/%s/server/ice%d" % [MSG_API, _server_name, client_name, len(_outgoing_ice) - 1], 
		ice_name, func(code, data): pass)

func _process(delta: float) -> void:
	if _wrtc_con == null or _data_ch_rel == null: return

	_wrtc_con.poll()
	while _data_ch_rel.get_ready_state() == _data_ch_rel.STATE_OPEN and _data_ch_rel.get_available_packet_count() > 0:
		print(client_name, " packet received")
		_incoming_stream.append_array(_data_ch_rel.get_packet())

func _on_ice_timer():
	if _data_ch_rel.get_ready_state() == _data_ch_rel.STATE_OPEN: 
		#_ice_timer.stop()
		if not confirmed: confirmed = true
		return
		
	print("player ice timeout and not open")
	Http.request_get("%s/%s/%s/server" % [MSG_API, _server_name, client_name], _on_get_messages)

func _on_get_messages(code: int, data: PackedByteArray) -> void:
	if code != 200: 
		printerr("failed to get ice messages!:", code)
		return
	print("got ice of ", client_name, ", code:", code)
	var data_string := data.get_string_from_utf8()
	var messages = JSON.parse_string(data_string)
	for ice: String in messages.values():
		if not ice in _already_added_ice:
			_already_added_ice.append(ice)
			print("ADDING ICE CANDIDATE to ", client_name, ": ", ice)
			_wrtc_con.add_ice_candidate("0", 0, ice)

func get_incoming_stream() -> PackedByteArray: 
	return _incoming_stream
	
func shift_incoming_stream(amount: int):
	_incoming_stream = _incoming_stream.slice(amount)

func send(data: PackedByteArray) -> void:
	_data_ch_rel.put_packet(data)
