extends PanelContainer

signal quest_completed(quest_id: StringName, points: int)
signal all_quests_completed(total_points: int)

const SUPPORT_POPUP_SCENE := preload("res://scenes/support_popup.tscn")
const QUEST_COUNT := 4
const WATER_SUPPORT_TEXT := (
	"Staying hydrated can make a clinic visit more comfortable. "
	+ "The water fountain is available for patients and visitors."
)
const INFORMATION_SUPPORT_TEXT := (
	"If you are unsure where to go, or need accessibility, language, "
	+ "or appointment support, ask the reception team for help."
)

@export_node_path("BaseButton") var water_button_path := NodePath("../WaterClick")
@export_node_path("BaseButton") var information_button_path := NodePath("../ReceptionClick")
@export_node_path("BaseButton") var screening_info_1_button_path := NodePath("../ScreeningInfo")
@export_node_path("BaseButton") var screening_info_2_button_path := NodePath("../ScreeningInfo2")
@export var points_per_quest := 50

var completed_quests: Dictionary[StringName, bool] = {}
var side_quest_score := 0
var _active_popup: SupportPopup
var _pending_quest_id: StringName
var _pending_button: BaseButton
var _pending_label: Label
var _pending_quest_text := ""

@onready var water_button: BaseButton = get_node(water_button_path)
@onready var information_button: BaseButton = get_node(information_button_path)
@onready var screening_info_1_button: BaseButton = get_node(
	screening_info_1_button_path
)
@onready var screening_info_2_button: BaseButton = get_node(
	screening_info_2_button_path
)
@onready var progress_label: Label = $QuestContent/QuestProgress
@onready var water_quest_label: Label = $QuestContent/WaterQuestLabel
@onready var information_quest_label: Label = (
	$QuestContent/InformationQuestLabel
)
@onready var screening_info_1_quest_label: Label = (
	$QuestContent/ScreeningInfo1QuestLabel
)
@onready var screening_info_2_quest_label: Label = (
	$QuestContent/ScreeningInfo2QuestLabel
)
@onready var feedback_label: Label = $QuestContent/QuestFeedback


func _ready() -> void:
	water_button.pressed.connect(_on_water_clicked)
	information_button.pressed.connect(_on_information_clicked)
	screening_info_1_button.pressed.connect(_on_screening_info_1_clicked)
	screening_info_2_button.pressed.connect(_on_screening_info_2_clicked)
	_refresh_hotspot_states()
	_refresh_quest_ui()


func _on_water_clicked() -> void:
	_show_quest_popup(
		&"water_fountain",
		water_button,
		water_quest_label,
		"Stay hydrated",
		"WATER FOUNTAIN",
		"TAKE CARE OF YOURSELF",
		WATER_SUPPORT_TEXT
	)


func _on_information_clicked() -> void:
	_show_quest_popup(
		&"general_information",
		information_button,
		information_quest_label,
		"Get general help/information",
		"GENERAL INFORMATION",
		"ASK FOR SUPPORT",
		INFORMATION_SUPPORT_TEXT
	)


func _on_screening_info_1_clicked() -> void:
	_show_quest_popup(
		&"screening_information_1",
		screening_info_1_button,
		screening_info_1_quest_label,
		"See screening fact 1",
		"SCREENING FACT",
		"DID YOU KNOW?",
		SupportPopup.SCREENING_FACTS[0]
	)


func _on_screening_info_2_clicked() -> void:
	_show_quest_popup(
		&"screening_information_2",
		screening_info_2_button,
		screening_info_2_quest_label,
		"See screening fact 2",
		"SCREENING FACT",
		"DID YOU KNOW?",
		SupportPopup.SCREENING_FACTS[1]
	)


func _show_quest_popup(
	quest_id: StringName,
	button: BaseButton,
	quest_label: Label,
	quest_text: String,
	popup_title: String,
	popup_status: String,
	popup_message: String
) -> void:
	if completed_quests.get(quest_id, false) or is_instance_valid(_active_popup):
		return

	_pending_quest_id = quest_id
	_pending_button = button
	_pending_label = quest_label
	_pending_quest_text = quest_text

	# Block every hotspot until the player has read and closed the popup.
	_set_all_hotspots_enabled(false)

	_active_popup = SUPPORT_POPUP_SCENE.instantiate() as SupportPopup
	get_parent().add_child(_active_popup)
	_active_popup.closed.connect(_on_support_popup_closed, CONNECT_ONE_SHOT)
	_active_popup.show_message(popup_title, popup_status, popup_message)
	feedback_label.text = "Read the information, then press Continue."


func _on_support_popup_closed() -> void:
	_active_popup = null
	_complete_quest(
		_pending_quest_id,
		_pending_button,
		_pending_label,
		_pending_quest_text
	)
	_clear_pending_quest()
	_refresh_hotspot_states()


func _clear_pending_quest() -> void:
	_pending_quest_id = &""
	_pending_button = null
	_pending_label = null
	_pending_quest_text = ""


func _complete_quest(
	quest_id: StringName,
	button: BaseButton,
	quest_label: Label,
	quest_text: String
) -> void:
	if completed_quests.get(quest_id, false):
		return

	completed_quests[quest_id] = true
	side_quest_score += points_per_quest
	button.disabled = true
	button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	quest_label.text = "[DONE]  %s   +%d" % [quest_text, points_per_quest]
	quest_label.modulate = Color("#D8FFD5")
	feedback_label.text = "Completed: %s" % quest_text
	quest_completed.emit(quest_id, points_per_quest)
	_refresh_quest_ui()

	if completed_quests.size() == QUEST_COUNT:
		feedback_label.text = "All side quests completed!  +%d points" % side_quest_score
		all_quests_completed.emit(side_quest_score)


func _refresh_quest_ui() -> void:
	progress_label.text = "%d / %d completed" % [
		completed_quests.size(), QUEST_COUNT
	]
	if not completed_quests.get(&"water_fountain", false):
		water_quest_label.text = "[ ]  Stay hydrated"
		water_quest_label.modulate = Color.WHITE
	if not completed_quests.get(&"general_information", false):
		information_quest_label.text = "[ ]  Get general help/information"
		information_quest_label.modulate = Color.WHITE
	if not completed_quests.get(&"screening_information_1", false):
		screening_info_1_quest_label.text = "[ ]  See fact about screening (1)"
		screening_info_1_quest_label.modulate = Color.WHITE
	if not completed_quests.get(&"screening_information_2", false):
		screening_info_2_quest_label.text = "[ ]  See fact about screening (2)"
		screening_info_2_quest_label.modulate = Color.WHITE


func _refresh_hotspot_states() -> void:
	_refresh_hotspot(water_button, &"water_fountain")
	_refresh_hotspot(information_button, &"general_information")
	_refresh_hotspot(screening_info_1_button, &"screening_information_1")
	_refresh_hotspot(screening_info_2_button, &"screening_information_2")


func _refresh_hotspot(button: BaseButton, quest_id: StringName) -> void:
	button.disabled = completed_quests.get(quest_id, false)
	button.mouse_default_cursor_shape = (
		Control.CURSOR_ARROW
		if button.disabled
		else Control.CURSOR_POINTING_HAND
	)


func _set_all_hotspots_enabled(enabled: bool) -> void:
	var buttons: Array[BaseButton] = [
		water_button,
		information_button,
		screening_info_1_button,
		screening_info_2_button,
	]
	for button in buttons:
		button.disabled = not enabled
		button.mouse_default_cursor_shape = (
			Control.CURSOR_POINTING_HAND
			if enabled
			else Control.CURSOR_ARROW
		)


func reset_quests() -> void:
	if is_instance_valid(_active_popup):
		_active_popup.queue_free()
	_active_popup = null
	_clear_pending_quest()
	completed_quests.clear()
	side_quest_score = 0
	_refresh_hotspot_states()
	feedback_label.text = "Hover over objects to investigate."
	_refresh_quest_ui()
