class_name PlayerNamePopup
extends ColorRect

signal name_submitted(full_name: String)

@onready var first_name_input: LineEdit = (
	$PanelContainer/Content/FirstNameInput
)
@onready var last_name_input: LineEdit = (
	$PanelContainer/Content/LastNameInput
)
@onready var date_of_birth_input: LineEdit = (
	$PanelContainer/Content/DateOfBirthInput
)
@onready var error_label: Label = $PanelContainer/Content/ErrorLabel
@onready var start_button: Button = $PanelContainer/Content/StartButton

var _input_placeholders: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_input_placeholders[first_name_input] = first_name_input.placeholder_text
	_input_placeholders[last_name_input] = last_name_input.placeholder_text
	_input_placeholders[date_of_birth_input] = date_of_birth_input.placeholder_text
	start_button.pressed.connect(_submit_name)
	first_name_input.text_submitted.connect(_on_first_name_submitted)
	last_name_input.text_submitted.connect(_on_last_name_submitted)
	date_of_birth_input.text_submitted.connect(_on_date_of_birth_submitted)
	first_name_input.focus_entered.connect(
		_on_name_input_focus_entered.bind(first_name_input)
	)
	first_name_input.focus_exited.connect(
		_on_name_input_focus_exited.bind(first_name_input)
	)
	last_name_input.focus_entered.connect(
		_on_name_input_focus_entered.bind(last_name_input)
	)
	last_name_input.focus_exited.connect(
		_on_name_input_focus_exited.bind(last_name_input)
	)
	date_of_birth_input.focus_entered.connect(
		_on_name_input_focus_entered.bind(date_of_birth_input)
	)
	date_of_birth_input.focus_exited.connect(
		_on_name_input_focus_exited.bind(date_of_birth_input)
	)


func open() -> void:
	show()
	error_label.text = ""
	start_button.disabled = false
	get_tree().paused = true
	first_name_input.release_focus()
	last_name_input.release_focus()
	date_of_birth_input.release_focus()


func _on_name_input_focus_entered(input: LineEdit) -> void:
	input.placeholder_text = ""


func _on_name_input_focus_exited(input: LineEdit) -> void:
	if input.text.is_empty():
		input.placeholder_text = str(_input_placeholders.get(input, ""))


func _on_first_name_submitted(_text: String) -> void:
	if _clean_name(first_name_input.text).is_empty():
		_show_error("Please enter your first name.")
		return
	last_name_input.grab_focus()


func _on_last_name_submitted(_text: String) -> void:
	if _clean_name(last_name_input.text).is_empty():
		_show_error("Please enter your last name.")
		return
	date_of_birth_input.grab_focus()


func _on_date_of_birth_submitted(_text: String) -> void:
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
	if date_of_birth_input.text.strip_edges().is_empty():
		_show_error("Please enter your date of birth.")
		date_of_birth_input.grab_focus()
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
