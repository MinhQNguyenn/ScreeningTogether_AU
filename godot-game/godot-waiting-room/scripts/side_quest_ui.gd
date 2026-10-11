extends PanelContainer

signal quest_completed(quest_id: StringName, points: int)
signal all_quests_completed(total_points: int)

const SUPPORT_POPUP_SCENE := preload("res://scenes/support_popup.tscn")
const QUEST_COUNT := 6
const SCREENING_QUEST_COUNT := 4
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
@export_node_path("BaseButton") var screening_info_3_button_path := NodePath("../ScreeningInfo3")
@export_node_path("BaseButton") var screening_info_4_button_path := NodePath("../ScreeningInfo4")
@export var points_per_quest := 50

var completed_quests: Dictionary[StringName, bool] = {}
var side_quest_score := 0
var _active_popup: SupportPopup
var _pending_quest_id: StringName
var _pending_quest_text := ""

@onready var water_button: BaseButton = get_node(water_button_path)
@onready var information_button: BaseButton = get_node(information_button_path)
@onready var screening_info_1_button: BaseButton = get_node(
	screening_info_1_button_path
)
@onready var screening_info_2_button: BaseButton = get_node(
	screening_info_2_button_path
)
@onready var screening_info_3_button: BaseButton = get_node(
	screening_info_3_button_path
)
@onready var screening_info_4_button: BaseButton = get_node(
	screening_info_4_button_path
)
@onready var progress_label: Label = $QuestContent/QuestProgress
@onready var water_quest_label: Label = $QuestContent/WaterQuestLabel
@onready var information_quest_label: Label = (
	$QuestContent/InformationQuestLabel
)
@onready var screening_info_quest_label: Label = (
	$QuestContent/ScreeningInfoQuestLabel
)
@onready var feedback_label: Label = $QuestContent/QuestFeedback

var fact_indices: Array[int] = []


func _ready() -> void:
	_pick_random_facts()

	water_button.pressed.connect(_on_water_clicked)
	information_button.pressed.connect(_on_information_clicked)
	screening_info_1_button.pressed.connect(_on_screening_info_1_clicked)
	screening_info_2_button.pressed.connect(_on_screening_info_2_clicked)
	screening_info_3_button.pressed.connect(_on_screening_info_3_clicked)
	screening_info_4_button.pressed.connect(_on_screening_info_4_clicked)
	_refresh_hotspot_states()
	_refresh_quest_ui()


func _pick_random_facts() -> void:
	var fact_count := SupportPopup.SCREENING_FACTS.size()
	assert(
		fact_count >= SCREENING_QUEST_COUNT,
		"At least four screening facts are required."
	)

	var available_indices: Array[int] = []
	for index in range(fact_count):
		available_indices.append(index)
	available_indices.shuffle()

	fact_indices.clear()
	for index in range(SCREENING_QUEST_COUNT):
		fact_indices.append(available_indices[index])


func _on_water_clicked() -> void:
	_show_quest_popup(
		&"water_fountain",
		"Stay hydrated",
		"WATER FOUNTAIN",
		"TAKE CARE OF YOURSELF",
		WATER_SUPPORT_TEXT
	)


func _on_information_clicked() -> void:
	_show_quest_popup(
		&"general_information",
		"Get general help/information",
		"GENERAL INFORMATION",
		"ASK FOR SUPPORT",
		INFORMATION_SUPPORT_TEXT
	)


func _on_screening_info_1_clicked() -> void:
	_show_quest_popup(
		&"screening_information_1",
		"See screening fact 1",
		"SCREENING FACT",
		"DID YOU KNOW?",
		SupportPopup.SCREENING_FACTS[fact_indices[0]]
	)


func _on_screening_info_2_clicked() -> void:
	_show_quest_popup(
		&"screening_information_2",
		"See screening fact 2",
		"SCREENING FACT",
		"DID YOU KNOW?",
		SupportPopup.SCREENING_FACTS[fact_indices[1]]
	)


func _on_screening_info_3_clicked() -> void:
	_show_quest_popup(
		&"screening_information_3",
		"See screening fact 3",
		"SCREENING FACT",
		"DID YOU KNOW?",
		SupportPopup.SCREENING_FACTS[fact_indices[2]]
	)


func _on_screening_info_4_clicked() -> void:
	_show_quest_popup(
		&"screening_information_4",
		"See screening fact 4",
		"SCREENING FACT",
		"DID YOU KNOW?",
		SupportPopup.SCREENING_FACTS[fact_indices[3]]
	)


func _show_quest_popup(
	quest_id: StringName,
	quest_text: String,
	popup_title: String,
	popup_status: String,
	popup_message: String
) -> void:
	if is_instance_valid(_active_popup):
		return

	_pending_quest_id = quest_id
	_pending_quest_text = quest_text

	# Block every hotspot until the player has read and closed the popup.
	_set_all_hotspots_enabled(false)

	_active_popup = SUPPORT_POPUP_SCENE.instantiate() as SupportPopup
	get_parent().add_child(_active_popup)
	_active_popup.closed.connect(_on_support_popup_closed, CONNECT_ONE_SHOT)
	_active_popup.show_message(popup_title, popup_status, popup_message)
	GameLanguage.bind_text(feedback_label, "Read the information, then press Continue.")


func _on_support_popup_closed() -> void:
	_active_popup = null
	_complete_quest(
		_pending_quest_id,
		_pending_quest_text
	)
	_clear_pending_quest()
	_refresh_hotspot_states()


func _clear_pending_quest() -> void:
	_pending_quest_id = &""
	_pending_quest_text = ""


func _complete_quest(
	quest_id: StringName,
	quest_text: String
) -> void:
	if completed_quests.get(quest_id, false):
		GameLanguage.bind_text(feedback_label, "Reviewed: %s", [quest_text])
		return

	completed_quests[quest_id] = true
	side_quest_score += points_per_quest
	GameLanguage.bind_text(feedback_label, "Completed: %s", [quest_text])
	quest_completed.emit(quest_id, points_per_quest)
	_refresh_quest_ui()

	if completed_quests.size() == QUEST_COUNT:
		GameLanguage.bind_text(feedback_label, "All side quests completed!  +%d points", [side_quest_score])
		all_quests_completed.emit(side_quest_score)


func _refresh_quest_ui() -> void:
	GameLanguage.bind_text(progress_label, "%d / %d completed", [completed_quests.size(), QUEST_COUNT])
	if completed_quests.get(&"water_fountain", false):
		GameLanguage.bind_text(water_quest_label, "[DONE]  Stay hydrated   +%d", [points_per_quest])
		water_quest_label.modulate = Color("#D8FFD5")
	else:
		GameLanguage.bind_text(water_quest_label, "[ ]  Stay hydrated")
		water_quest_label.modulate = Color.WHITE

	if completed_quests.get(&"general_information", false):
		GameLanguage.bind_text(information_quest_label, "[DONE]  Get general support   +%d", [points_per_quest])
		information_quest_label.modulate = Color("#D8FFD5")
	else:
		GameLanguage.bind_text(information_quest_label, "[ ]  Get general support(Information)")
		information_quest_label.modulate = Color.WHITE

	var screening_found := _get_screening_completed_count()
	if screening_found == SCREENING_QUEST_COUNT:
		GameLanguage.bind_text(screening_info_quest_label, "[DONE]  Screening facts: %d / %d   +%d", [screening_found, SCREENING_QUEST_COUNT, points_per_quest * SCREENING_QUEST_COUNT])
		screening_info_quest_label.modulate = Color("#D8FFD5")
	else:
		GameLanguage.bind_text(screening_info_quest_label, "[ ]  Screening facts found: %d / %d", [screening_found, SCREENING_QUEST_COUNT])
		screening_info_quest_label.modulate = Color.WHITE


func _get_screening_completed_count() -> int:
	var completed_count := 0
	for quest_number in range(1, SCREENING_QUEST_COUNT + 1):
		var quest_id := StringName("screening_information_%d" % quest_number)
		if completed_quests.get(quest_id, false):
			completed_count += 1
	return completed_count


func _refresh_hotspot_states() -> void:
	_set_all_hotspots_enabled(not is_instance_valid(_active_popup))


func _set_all_hotspots_enabled(enabled: bool) -> void:
	var buttons: Array[BaseButton] = [
		water_button,
		information_button,
		screening_info_1_button,
		screening_info_2_button,
		screening_info_3_button,
		screening_info_4_button,
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
	_pick_random_facts()
	_refresh_hotspot_states()
	GameLanguage.bind_text(feedback_label, "Hover over objects to investigate.")
	_refresh_quest_ui()
