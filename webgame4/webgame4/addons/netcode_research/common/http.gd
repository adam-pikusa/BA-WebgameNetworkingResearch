extends Node

var _req := HTTPRequest.new()
var _api_url: String

var _queue: Array = []

var requesting := false

func init(api_url: String):
	_api_url = api_url
	
func _ready():
	_req.set_tls_options(TLSOptions.client_unsafe())
	_req.request_completed.connect(_request_completed)
	add_child(_req)
	
func _process(delta):
	if _queue.is_empty(): return
	if requesting: return
	
	var next_request: Array = _queue[0]
	var url: String = _api_url + next_request[0]
	var headers: PackedStringArray = next_request[1]
	var method: HTTPClient.Method = next_request[2]
	var data = next_request[3]
	
	print("executing %s request to: [%s]" % [method, url])
	_req.request(url, headers, method, data)
	requesting = true

func _request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var completed_request = _queue.pop_front()
	var callback: Callable = completed_request[4]
	#print("request to ", completed_request[0], " complete:", result)
	callback.call(response_code, body)
	requesting = false
	
func request(url: String, headers: PackedStringArray, method: HTTPClient.Method, data: String, callback: Callable) -> void:
	#print("queued new request to:", url)
	_queue.append([url, headers, method, data, callback])

func request_get(url: String, callback: Callable) -> void:
	request(url, [], HTTPClient.METHOD_GET, "", callback)

func request_post(url: String, callback: Callable) -> void:
	request(url, [], HTTPClient.METHOD_POST, "", callback)

func request_post_text(url: String, data: String, callback: Callable) -> void:
	request(url, ["Content-Type: text/plain"], HTTPClient.METHOD_POST, data, callback)

func request_post_json(url: String, data: String, callback: Callable) -> void:
	request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, data, callback)
