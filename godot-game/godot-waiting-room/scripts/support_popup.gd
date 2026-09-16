class_name SupportPopup
extends ColorRect

signal closed

const SCREENING_FACTS := [
	(
		"In Australia, more than 70% of cervical cancers occurred in women "
		+ "who had never screened or were overdue for screening."
	),
	(
		"Cervical cancer can take 10-15 years to develop. Regular screening "
		+ "can detect early changes before they become cancer, giving you more "
		+ "time to take action."
	),
	(
		"4 in 5 Australians get HPV at some point, it's common, "
		+ "not hereditary"
	),
	(
		"Screening-detected cancers have an 87% lower risk of death "
		+ "than unscreened cases."
	),
	(
		"No face-to-face talk needed. Self-collection lets you "
		+ "take the swab yourself, in private."
	),
	(
		"Going for a test doesn't mean something's already wrong. "
		+ "Most results come back normal."
	),
	(
		"Your visit is confidential, protected the same as any other "
		+ "medical appointment."
	)
]

var _is_closing := false

@onready var title_label: Label = $PanelContainer/VBoxContainer/title_label
@onready var status_label: Label = $PanelContainer/VBoxContainer/status_label
@onready var data_label: RichTextLabel = $PanelContainer/VBoxContainer/data_label
@onready var close_button: Button = $PanelContainer/VBoxContainer/close_button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(_on_close_pressed)


func show_fact(fact_index: int) -> void:
	show_message(
		"SCREENING FACT",
		"DID YOU KNOW?",
		SCREENING_FACTS[fact_index]
	)


func show_message(title: String, status: String, message: String) -> void:
	title_label.text = title
	status_label.text = status
	data_label.text = message
	close_button.grab_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			get_viewport().set_input_as_handled()
			close_popup()


func _on_close_pressed() -> void:
	close_popup()


func close_popup() -> void:
	if _is_closing:
		return
	_is_closing = true
	closed.emit()
	queue_free()
