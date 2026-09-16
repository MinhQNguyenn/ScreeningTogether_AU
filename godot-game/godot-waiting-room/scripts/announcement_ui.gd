extends PanelContainer

const GAME_COMPLETE_POPUP_SCENE := preload(
	"res://scenes/game_complete_popup.tscn"
)
const WEB_TTS_VOICE_RETRY_COUNT := 20
const WEB_TTS_VOICE_RETRY_DELAY := 0.25
const INTRO_UTTERANCE_ID := 1001
const INTRO_FALLBACK_SECONDS := 10.0
const INTRO_MESSAGE := (
	"Please have a seat"
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
@export_range(1, 10, 1) var minimum_calls_before_player := 2
@export_range(1, 10, 1) var maximum_calls_before_player := 5
@export_range(0.1, 2.0, 0.05) var slide_in_seconds := 2.0
@export_range(0.5, 10.0, 0.1) var call_duration_seconds := 1.0
@export_range(0.1, 2.0, 0.05) var slide_out_seconds := 2.0
@export_range(0.1, 5.0, 0.1) var pause_duration_seconds := 5.0
@export var correct_answer_points := 500

@export_group("Text to Speech")
@export var tts_enabled := true
@export var tts_language := "en_AU"
@export var tts_preferred_voice_name := "Catherine"
@export_range(0, 100, 1) var tts_volume := 80
@export_range(0.0, 2.0, 0.05) var tts_pitch := 1.0
@export_range(0.1, 10.0, 0.05) var tts_rate := 1.0

@export_group("Node Paths")
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
var _tts_voice_id := ""
var _tts_supported := false
var _tts_callbacks_registered := false
var _waiting_for_intro := false

@onready var announcement_label: Label = (
	$AnnouncementContent/AnnouncementTitle
)
@onready var that_me_button: BaseButton = get_node(that_me_button_path)
@onready var that_me_hint: Control = get_node(that_me_hint_path)
@onready var that_me_arrow: Control = get_node_or_null(that_me_arrow_path)
@onready var side_quest_ui: Control = get_node(side_quest_ui_path)

@onready var num_text:= [
	"one",
	"two",
	"three",
	"four",
	"five",
	"six",
	"seven",
	"eight"
]

func _ready() -> void:
	_rng.randomize()
	_setup_tts()
	_register_tts_callbacks()
	if OS.has_feature("web") and _tts_supported and _tts_voice_id.is_empty():
		call_deferred("_wait_for_web_tts_voice")
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	announcement_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	that_me_button.pressed.connect(_on_that_me_pressed)
	that_me_button.disabled = true
	that_me_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	that_me_button.tooltip_text = "Respond when your name is called"
	#that_me_hint.hide()
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
	_waiting_for_intro = true
	current_name = ""
	that_me_button.disabled = true
	that_me_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	#that_me_hint.hide()
	announcement_label.modulate = Color.WHITE
	announcement_label.text = ""

	# Retry during the user's button press. This also unlocks browser TTS.
	_setup_tts(false)
	_register_tts_callbacks()
	if _speak_text(INTRO_MESSAGE, INTRO_UTTERANCE_ID):
		call_deferred("_wait_for_intro_fallback")
	else:
		call_deferred("_begin_announcements")


func _begin_announcements() -> void:
	if not _waiting_for_intro or is_game_completed:
		return

	_waiting_for_intro = false
	that_me_button.disabled = false
	that_me_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	that_me_hint.show()
	announcement_label.modulate = Color.WHITE
	announcement_label.text = "Please listen..."
	call_deferred("_run_calling_loop")


func _wait_for_intro_fallback() -> void:
	await get_tree().create_timer(INTRO_FALLBACK_SECONDS).timeout
	_begin_announcements()


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
		_speak_name(current_name)

		await _play_name_animation()
		if is_game_completed:
			return

		current_name = ""
		announcement_label.modulate = Color.WHITE
		announcement_label.text = "Please listen..."
		await get_tree().create_timer(pause_duration_seconds).timeout


func _setup_tts(show_warning := true) -> void:
	if not tts_enabled:
		return
	_tts_supported = DisplayServer.has_feature(
		DisplayServer.FEATURE_TEXT_TO_SPEECH
	)
	if not _tts_supported:
		if show_warning:
			push_warning("Text-to-speech is not supported on this device.")
		return

	var available_voices := DisplayServer.tts_get_voices()
	var preferred_name := tts_preferred_voice_name.strip_edges().to_lower()
	if not preferred_name.is_empty():
		for voice_data in available_voices:
			var voice_name := str(voice_data.get("name", ""))
			if voice_name.to_lower().contains(preferred_name):
				_tts_voice_id = str(voice_data.get("id", ""))
				if not _tts_voice_id.is_empty():
					print("TTS voice selected: %s" % voice_name)
					return

	var voice_ids := DisplayServer.tts_get_voices_for_language(tts_language)
	if voice_ids.is_empty():
		voice_ids = DisplayServer.tts_get_voices_for_language("en")

	if not voice_ids.is_empty():
		_tts_voice_id = voice_ids[0]
		print("TTS voice selected: %s" % _tts_voice_id)
		return

	if not available_voices.is_empty():
		_tts_voice_id = str(available_voices[0].get("id", ""))
		print(
			"TTS fallback voice selected: %s"
			% str(available_voices[0].get("name", _tts_voice_id))
		)

	if _tts_voice_id.is_empty():
		if OS.has_feature("web"):
			if show_warning:
				print("Web TTS voices are still loading; using browser default.")
		elif show_warning:
			push_warning("No text-to-speech voice is installed on this device.")


func _register_tts_callbacks() -> void:
	if not _tts_supported or _tts_callbacks_registered:
		return

	DisplayServer.tts_set_utterance_callback(
		DisplayServer.TTS_UTTERANCE_ENDED,
		_on_tts_utterance_finished
	)
	DisplayServer.tts_set_utterance_callback(
		DisplayServer.TTS_UTTERANCE_CANCELED,
		_on_tts_utterance_finished
	)
	_tts_callbacks_registered = true


func _on_tts_utterance_finished(utterance_id: int) -> void:
	if utterance_id == INTRO_UTTERANCE_ID:
		_begin_announcements()


func _wait_for_web_tts_voice() -> void:
	for _attempt in range(WEB_TTS_VOICE_RETRY_COUNT):
		if not _tts_voice_id.is_empty() or not is_inside_tree():
			return
		await get_tree().create_timer(WEB_TTS_VOICE_RETRY_DELAY).timeout
		_setup_tts(false)


func _speak_name(name_to_speak: String) -> void:
	var clean_name := name_to_speak.strip_edges()
	if clean_name.is_empty():
		return
	var room_name = num_text[randi_range(0, num_text.size() - 1)]
	_speak_text("Calling %s to room %s" % [clean_name, room_name])

func _speak_text(text_to_speak: String, utterance_id := 0) -> bool:
	if not tts_enabled or not _tts_supported:
		return false

	if _tts_voice_id.is_empty():
		_setup_tts(false)
	if _tts_voice_id.is_empty() and not OS.has_feature("web"):
		return false

	DisplayServer.tts_speak(
		text_to_speak,
		_tts_voice_id,
		tts_volume,
		tts_pitch,
		tts_rate,
		utterance_id,
		true
	)
	return true


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
	if not _tts_voice_id.is_empty():
		DisplayServer.tts_stop()
	if is_instance_valid(_active_name_tween):
		_active_name_tween.kill()
	if _has_announcement_rest_x:
		announcement_label.position.x = _announcement_rest_x
	announcement_label.modulate = Color.WHITE


func _exit_tree() -> void:
	if not _tts_voice_id.is_empty():
		DisplayServer.tts_stop()


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
		if is_instance_valid(that_me_arrow):
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
