class_name SupportPopup
extends ColorRect

signal closed

const SCREENING_FACTS := [
	(
		"In Australia, more than 70% of cervical cancers occurred in women "
		+ "who had never screened or were overdue for screening."
	),
	(
		"Cervical cancer can take 10–15 years to develop. Regular screening "
		+ "can detect early changes before they become cancer, giving you more "
		+ "time to take action."
	),
]

@onready var title_label: Label = $PanelContainer/VBoxContainer/title_label
@onready var status_label: Label = $PanelContainer/VBoxContainer/status_label
@onready var data_label: RichTextLabel = $PanelContainer/VBoxContainer/data_label
@onready var close_button: Button = $PanelContainer/VBoxContainer/close_button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(_on_close_pressed)


func show_fact(fact_index: int) -> void:
	title_label.text = "SCREENING FACT"
	status_label.text = "DID YOU KNOW?"
	data_label.text = SCREENING_FACTS[fact_index]


func _on_close_pressed() -> void:
	close_popup()


func close_popup() -> void:
	closed.emit()
	queue_free()
