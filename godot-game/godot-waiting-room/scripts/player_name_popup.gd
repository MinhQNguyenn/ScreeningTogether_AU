class_name PlayerNamePopup
extends ColorRect

signal name_submitted(full_name: String)

@onready var first_name_input: LineEdit = (
	$PanelContainer/Content/FirstNameInput
)
@onready var last_name_input: LineEdit = (
	$PanelContainer/Content/LastNameInput
)
@onready var error_label: Label = $PanelContainer/Content/ErrorLabel
@onready var start_button: Button = $PanelContainer/Content/StartButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.pressed.connect(_submit_name)
	first_name_input.text_submitted.connect(_on_first_name_submitted)
	last_name_input.text_submitted.connect(_on_last_name_submitted)


func open() -> void:
	show()
	error_label.text = ""
	start_button.disabled = false
	get_tree().paused = true
	first_name_input.grab_focus()


func _on_first_name_submitted(_text: String) -> void:
	if _clean_name(first_name_input.text).is_empty():
		_show_error("Please enter your first name.")
		return
	last_name_input.grab_focus()


func _on_last_name_submitted(_text: String) -> void:
	_submit_name()


func _submit_name() -> void:
	var first_name := _clean_name(first_name_input.text)
	var last_name := _clean_name(last_name_input.text)
	if first_name.is_empty():
		_show_error("Please enter your first name.")
		first_name_input.grab_focus()
		return
	if last_name.is_empty():
		_show_error("Please enter your last name.")
		last_name_input.grab_focus()
		return

	var full_name := "%s %s" % [first_name, last_name]
	start_button.disabled = true
	get_tree().paused = false
	name_submitted.emit(full_name)
	queue_free()


func _clean_name(value: String) -> String:
	return " ".join(value.strip_edges().split(" ", false))


func _show_error(message: String) -> void:
	error_label.text = message
