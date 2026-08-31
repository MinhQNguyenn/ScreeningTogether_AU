class_name SupportPopup
extends ColorRect

signal closed

@onready var title_label: Label = $PanelContainer/VBoxContainer/title_label
@onready var status_label: Label = $PanelContainer/VBoxContainer/status_label
@onready var data_label: RichTextLabel = $PanelContainer/VBoxContainer/data_label
@onready var close_button: Button = $PanelContainer/VBoxContainer/close_button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(_on_close_pressed)


func show_loading(item_name: String) -> void:
	title_label.text = "%s collected" % item_name.capitalize()
	status_label.text = "Finding a nearby health service..."
	data_label.text = "Trusted information can help you make an informed choice."


func show_data(data: Variant) -> void:
	if not data is Dictionary:
		show_error("The response could not be read.")
		return

	var response: Dictionary = data as Dictionary
	var features_value: Variant = response.get("features", [])
	if not features_value is Array or features_value.is_empty():
		status_label.text = "No service found for this postcode"
		data_label.text = "You can still ask a trusted healthcare professional about screening."
		return

	# The demo only needs the first nearby practice from the API response.
	var first_feature: Dictionary = features_value[0] as Dictionary
	var details: Dictionary = first_feature.get("attributes", {}) as Dictionary
	var practice_name: String = str(details.get("organisation_name", "Health service"))
	var address: String = str(details.get("address", "Address not provided"))
	var suburb: String = str(details.get("suburb", ""))
	var state: String = str(details.get("state", ""))
	var postcode: String = str(details.get("postcode", ""))

	status_label.text = "Nearby general practice"
	data_label.text = (
		"%s\n\nAddress\n%s\n%s %s %s\n\n"
		+ "Contact the practice to check if cervical screening is available."
	) % [practice_name, address, suburb, state, postcode]


func show_error(_message: String) -> void:
	status_label.text = "Information unavailable"
	data_label.text = "The health service information could not be loaded right now."


func _on_close_pressed() -> void:
	closed.emit()
	queue_free()
