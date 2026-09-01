class_name ApiClient
extends Node

signal request_succeeded(data: Variant)
signal request_failed(message: String)

@export_range(1.0, 30.0, 0.5) var timeout_seconds := 10.0

@onready var http_request: HTTPRequest = $HTTPRequest

var is_busy := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	http_request.timeout = timeout_seconds
	http_request.request_completed.connect(_on_request_completed)


func get_json(
	url: String,
	headers: PackedStringArray = PackedStringArray(),
) -> void:
	if is_busy:
		request_failed.emit("Handling another API")
		return

	is_busy = true

	var error := http_request.request(
		url,
		headers,
		HTTPClient.METHOD_GET,
	)

	if error != OK:
		is_busy = false
		request_failed.emit(
			"Can not request: %s" % error_string(error)
		)


func _on_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
) -> void:
	is_busy = false

	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit("Can not connect to API.")
		return

	if response_code < 200 or response_code >= 300:
		request_failed.emit(
			"API return HTTP %d." % response_code
		)
		return

	var json := JSON.new()
	var parse_error := json.parse(body.get_string_from_utf8())

	if parse_error != OK:
		request_failed.emit(
			"Invalid JSON: %s" % json.get_error_message()
		)
		return

	request_succeeded.emit(json.data)
