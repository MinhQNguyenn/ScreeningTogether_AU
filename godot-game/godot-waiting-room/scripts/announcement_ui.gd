extends PanelContainer

const GAME_COMPLETE_POPUP_SCENE := preload(
	"res://scenes/game_complete_popup.tscn"
)

signal game_completed(score: int)

@export var player_name := "Emily Nguyen"
@export var other_names: Array[String] = [
	"Olivia Tran",
	"Sophia Patel",
	"Amelia Nguyen",
	"Charlotte Lee",
	"Grace Wilson",
	"Emma Taylor",
	"Noah Williams",
	"Liam Chen",
]
@export_range(1, 10, 1) var minimum_calls_before_player := 3
@export_range(1, 10, 1) var maximum_calls_before_player := 6
@export_range(0.1, 2.0, 0.05) var slide_in_seconds := 2.0
@export_range(0.5, 10.0, 0.1) var call_duration_seconds := 1.0
@export_range(0.1, 2.0, 0.05) var slide_out_seconds := 2.0
@export_range(0.1, 5.0, 0.1) var pause_duration_seconds := 4.0
@export var correct_answer_points := 500
@export_node_path("BaseButton") var that_me_button_path := NodePath("../ThatMeButton")
@export_node_path("Control") var that_me_hint_path := NodePath("../ThatMeHint")
@export_node_path("Control") var that_me_arrow_path := NodePath("../Arrow")
@export_node_path("Control") var side_quest_ui_path := NodePath("../SideQuestUI")

var current_name := ""
var score := 0
var is_game_completed := false
var _calling_started := false

var _calls_until_player := 0
var _last_called_name := ""
var _rng := RandomNumberGenerator.new()
var _completion_popup: GameCompletePopup
var _active_name_tween: Tween
var _announcement_rest_x := 0.0
var _has_announcement_rest_x := false

@onready var announcement_label: Label = (
	$AnnouncementContent/AnnouncementTitle
)
@onready var that_me_button: BaseButton = get_node(that_me_button_path)
@onready var that_me_hint: Control = get_node(that_me_hint_path)
@onready var that_me_arrow: Control = get_node(that_me_arrow_path)
@onready var side_quest_ui: Control = get_node(side_quest_ui_path)


func _ready() -> void:
	_rng.randomize()
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	announcement_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	that_me_button.pressed.connect(_on_that_me_pressed)
	that_me_button.disabled = true
	that_me_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	that_me_button.tooltip_text = "Respond when your name is called"
	that_me_hint.hide()
	that_me_arrow.hide()
	announcement_label.text = "Enter your name\nto begin"


func start_calling(full_name: String) -> void:
	if _calling_started:
		return

	var clean_name := " ".join(full_name.strip_edges().split(" ", false))
	if clean_name.is_empty():
		return

	player_name = clean_name
	_calls_until_player = _new_player_countdown()
	_calling_started = true
	current_name = ""
	that_me_button.disabled = false
	that_me_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	that_me_hint.show()
	that_me_arrow.show()
	announcement_label.modulate = Color.WHITE
	announcement_label.text = "Please listen..."
	call_deferred("_run_calling_loop")


func _on_that_me_pressed() -> void:
	if _calling_started and not is_game_completed:
		_check_current_name()


func _run_calling_loop() -> void:
	await get_tree().create_timer(1.0).timeout

	while _calling_started and not is_game_completed:
		current_name = _pick_next_name()
		_last_called_name = current_name
		announcement_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
		announcement_label.text = "Calling:\n%s" % current_name

		await _play_name_animation()
		if is_game_completed:
			return

		current_name = ""
		announcement_label.modulate = Color.WHITE
		announcement_label.text = "Please listen..."
		await get_tree().create_timer(pause_duration_seconds).timeout


func _play_name_animation() -> void:
	# Wait for the container to calculate the label's final centred position.
	await get_tree().process_frame
	if is_game_completed:
		return

	_announcement_rest_x = announcement_label.position.x
	_has_announcement_rest_x = true
	var travel_distance := maxf(announcement_label.size.x, size.x)
	announcement_label.position.x = _announcement_rest_x + travel_distance
	announcement_label.modulate = Color.WHITE

	_active_name_tween = create_tween()
	_active_name_tween.set_trans(Tween.TRANS_QUAD)
	_active_name_tween.set_ease(Tween.EASE_OUT)
	_active_name_tween.tween_property(
		announcement_label,
		"position:x",
		_announcement_rest_x,
		slide_in_seconds
	)
	await _active_name_tween.finished
	if is_game_completed:
		return

	await get_tree().create_timer(call_duration_seconds).timeout
	if is_game_completed:
		return

	_active_name_tween = create_tween()
	_active_name_tween.set_trans(Tween.TRANS_QUAD)
	_active_name_tween.set_ease(Tween.EASE_IN)
	_active_name_tween.tween_property(
		announcement_label,
		"position:x",
		_announcement_rest_x - travel_distance,
		slide_out_seconds
	)
	await _active_name_tween.finished
	if is_game_completed:
		return

	announcement_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	announcement_label.position.x = _announcement_rest_x


func _stop_name_animation_at_center() -> void:
	if is_instance_valid(_active_name_tween):
		_active_name_tween.kill()
	if _has_announcement_rest_x:
		announcement_label.position.x = _announcement_rest_x
	announcement_label.modulate = Color.WHITE


func _pick_next_name() -> String:
	if _calls_until_player <= 0 or other_names.is_empty():
		_calls_until_player = _new_player_countdown()
		return player_name

	_calls_until_player -= 1
	var selected_name := other_names[_rng.randi_range(0, other_names.size() - 1)]
	var attempts := 0
	while selected_name == _last_called_name and attempts < 10:
		selected_name = other_names[_rng.randi_range(0, other_names.size() - 1)]
		attempts += 1
	return selected_name


func _new_player_countdown() -> int:
	var lower_bound := mini(
		minimum_calls_before_player,
		maximum_calls_before_player
	)
	var upper_bound := maxi(
		minimum_calls_before_player,
		maximum_calls_before_player
	)
	return _rng.randi_range(lower_bound, upper_bound)


func _check_current_name() -> void:
	if current_name.is_empty():
		_show_temporary_feedback("Wait for a name...", Color("#FFD166"))
		return

	if current_name == player_name:
		var side_quest_points := int(side_quest_ui.get("side_quest_score"))
		score = correct_answer_points + side_quest_points
		is_game_completed = true
		_stop_name_animation_at_center()
		announcement_label.text = "Calling:\n%s" % current_name
		that_me_button.disabled = true
		that_me_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
		that_me_hint.hide()
		that_me_arrow.hide()
		game_completed.emit(score)
		_show_game_complete_popup(side_quest_points)
	else:
		_show_temporary_feedback("Not you yet!", Color("#FF8A80"))


func _show_game_complete_popup(side_quest_points: int) -> void:
	if is_instance_valid(_completion_popup):
		return
	_completion_popup = (
		GAME_COMPLETE_POPUP_SCENE.instantiate() as GameCompletePopup
	)
	get_parent().add_child(_completion_popup)
	_completion_popup.continue_requested.connect(_on_continue_requested)
	_completion_popup.show_result(
		player_name,
		correct_answer_points,
		side_quest_points
	)


func _on_continue_requested() -> void:
	if OS.has_feature("web"):
		var payload := JSON.stringify({
			"type": "game2-complete",
			"score": score,
		})
		JavaScriptBridge.eval(
			"window.parent.postMessage(%s, window.location.origin);" % payload
		)
	else:
		get_tree().reload_current_scene()


func _show_temporary_feedback(message: String, color: Color) -> void:
	var name_when_clicked := current_name
	announcement_label.modulate = color
	announcement_label.text = message
	await get_tree().create_timer(0.65).timeout

	if is_game_completed or current_name != name_when_clicked:
		return
	announcement_label.modulate = Color.WHITE
	if current_name.is_empty():
		announcement_label.text = "Please listen..."
	else:
		announcement_label.text = "Calling:\n%s" % current_name
