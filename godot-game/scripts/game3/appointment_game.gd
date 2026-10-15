extends Control

# Clock-based appointment conversation and follow-up.
const CONTENT := preload("res://scripts/game3/appointment_content.gd")
const CLOCK := preload("res://scripts/game3/procedure_clock.gd")
const ENDING := preload("res://scripts/game3/appointment_ending.gd")
const CHOICE_ARROW := preload("res://assets/game3/dialogue_arrow.svg")
const SIMULATION_SECONDS := 120.0
const CLOCK_SPEED := 15.0

var stage := "intro"
var question_index := 0
var answers: Array[int] = []
var post_index := 0
var elapsed := 0.0
var room: OfficeEntrance
var activity: VBoxContainer
var speaker: Label
var text_label: Label
var choices: VBoxContainer
var typing: Tween
var clock_face: Control
var timer_label: Label
var reduced_motion := false
var ending: Control


func _ready() -> void:
	if OS.has_feature("web"):
		reduced_motion = bool(JavaScriptBridge.eval("window.matchMedia('(prefers-reduced-motion: reduce)').matches"))
	_build_scene()
	_say("LUNA'S APPOINTMENT", "Luna is meeting her healthcare professional. Let's talk about what feels right for you. There are no wrong answers.")
	_add_choice("Start conversation", _show_question)


func _build_scene() -> void:
	var background := ColorRect.new()
	background.color = Color("#f5dfdc")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	room = OfficeEntrance.new()
	room.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	room.anchor_bottom = 0.59
	room.clip_contents = true
	add_child(room)
	var status := Game3UI.make_label("LUNA'S APPOINTMENT", 19, Game3UI.INK, HORIZONTAL_ALIGNMENT_CENTER)
	status.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	status.offset_top = 38
	status.offset_bottom = 72
	add_child(status)
	var centre := CenterContainer.new()
	# Office characters use z-indices 2 and 3; activities must cover them.
	centre.z_index = 5
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.anchor_bottom = 0.59
	centre.offset_top = 72
	centre.offset_bottom = -8
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centre)
	activity = VBoxContainer.new()
	activity.add_theme_constant_override("separation", 12)
	activity.resized.connect(activity.queue_redraw)
	centre.add_child(activity)
	var box := PanelContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.anchor_top = 0.59
	box.offset_left = 22
	box.offset_right = -22
	box.offset_top = 10
	box.offset_bottom = -28
	var style := Game3UI.make_panel_style(Game3UI.CREAM, 4, Color("#263c58"), 6)
	style.shadow_color = Color("#b95486")
	style.shadow_size = 5
	box.add_theme_stylebox_override("panel", style)
	add_child(box)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var dialogue := VBoxContainer.new()
	dialogue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialogue.add_theme_constant_override("separation", 14)
	scroll.add_child(dialogue)
	speaker = Game3UI.make_label("", 19, Game3UI.ROSE_DARK)
	dialogue.add_child(speaker)
	text_label = Game3UI.make_label("", 27)
	text_label.custom_minimum_size.y = 130
	dialogue.add_child(text_label)
	choices = VBoxContainer.new()
	choices.add_theme_constant_override("separation", 10)
	dialogue.add_child(choices)


func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _say(who: String, words: String) -> void:
	_clear(choices)
	if typing:
		typing.kill()
	speaker.text = who
	if speaker.has_meta("localized_text"):
		speaker.remove_meta("localized_text")
	text_label.text = words
	text_label.visible_ratio = 1.0 if reduced_motion else 0.0
	if not reduced_motion:
		typing = create_tween()
		typing.tween_property(text_label, "visible_ratio", 1.0, minf(words.length() / 65.0, 2.5))


func _add_choice(words: String, action: Callable) -> Button:
	var button := Game3UI.make_button(words, false, 23)
	button.icon = CHOICE_ARROW
	button.add_theme_constant_override("h_separation", 12)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_stylebox_override("normal", Game3UI.make_panel_style(Game3UI.WHITE, 3, Game3UI.BORDER, 2))
	button.pressed.connect(action)
	choices.add_child(button)
	if choices.get_child_count() == 1:
		button.grab_focus()
	return button


func _show_question() -> void:
	stage = "question"
	var question: Dictionary = CONTENT.QUESTIONS[question_index]
	_say("", question.question)
	GameLanguage.bind_text(speaker, "HEALTHCARE PROFESSIONAL  /  %d OF 5", [question_index + 1])
	for index in question.options.size():
		_add_choice(question.options[index], _answer.bind(index))


func _answer(index: int) -> void:
	if stage != "question":
		return
	stage = "answer"
	answers.append(index)
	_say("HEALTHCARE PROFESSIONAL", CONTENT.QUESTIONS[question_index].responses[index])
	_add_choice("Continue", _next_question)


func _next_question() -> void:
	question_index += 1
	if question_index < CONTENT.QUESTIONS.size():
		_show_question()
	else:
		_show_procedure_intro()


func _show_procedure_intro() -> void:
	stage = "procedure_intro"
	var explanation := "Next, the clock shows time passing during sample collection. This part of screening usually takes only a few minutes."
	_say("BEFORE WE BEGIN", explanation)
	_add_choice("Continue", _show_timing_note)


func _show_timing_note() -> void:
	_say("HEALTHCARE PROFESSIONAL", "Two minutes is this simulation's limit, not a maximum for every procedure. Actual timing varies; the whole appointment takes longer. You can ask to pause or stop at any time.")
	_add_choice("Start clock", _start_clock)


func _start_clock() -> void:
	stage = "clock"
	elapsed = 0.0
	room.modulate = Color(1, 1, 1, 0.35)
	clock_face = CLOCK.new()
	clock_face.custom_minimum_size = Vector2(360, 360)
	clock_face.reduced_motion = reduced_motion
	activity.add_child(clock_face)
	timer_label = Game3UI.make_label("00:00 / 02:00", 42, Game3UI.INK, HORIZONTAL_ALIGNMENT_CENTER)
	activity.add_child(timer_label)
	activity.add_child(Game3UI.make_label("TIME PASSING", 22, Game3UI.ROSE_DARK, HORIZONTAL_ALIGNMENT_CENTER))
	_say("SAMPLE COLLECTION · TIME SIMULATION", "As time passes, your healthcare professional checks that you are comfortable. You can ask to pause or stop at any time.")
	_add_choice("Skip animation", _finish_activity)


func _process(delta: float) -> void:
	if stage != "clock":
		return
	elapsed = minf(elapsed + delta * CLOCK_SPEED, SIMULATION_SECONDS)
	timer_label.text = "%s / 02:00" % Game3UI.format_clock(int(elapsed))
	if stage == "clock":
		clock_face.seconds = elapsed
		clock_face.queue_redraw()
	if elapsed >= SIMULATION_SECONDS:
		_finish_activity()


func _finish_activity() -> void:
	if stage != "clock":
		return
	stage = "activity_complete"
	_say("TIME SIMULATION COMPLETE", "The sample collection part usually takes only a few minutes. This activity illustrates time passing; it does not predict how long your own test will take.")
	_add_choice("What happens next?", _show_post_information)


func _show_post_information() -> void:
	stage = "post_information"
	_clear(activity)
	activity.queue_redraw()
	room.modulate = Color.WHITE
	var info: Dictionary = CONTENT.AFTERCARE[post_index]
	_say(info.speaker, info.text)
	_add_choice("Continue" if post_index < CONTENT.AFTERCARE.size() - 1 else "Finish appointment", _next_post)


func _next_post() -> void:
	post_index += 1
	if post_index < CONTENT.AFTERCARE.size():
		_show_post_information()
	else:
		_show_ending()


func _show_ending() -> void:
	stage = "ending"
	room.hide()
	ending = ENDING.new()
	ending.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ending.anchor_bottom = 0.59
	ending.offset_left = 22
	ending.offset_right = -22
	ending.offset_top = 76
	ending.offset_bottom = -8
	ending.reduced_motion = reduced_motion
	ending.finished.connect(_complete_appointment)
	add_child(ending)
	_say("HEADING HOME", "With her sample collected and her next steps explained, Luna heads home as the sun sets.")
	_add_choice("Continue", ending.finish)


func _complete_appointment() -> void:
	if stage != "ending":
		return
	stage = "complete"
	_say("LUNA", "Now I know what to expect, what choices I have, and what happens after my sample is collected. Thanks for coming with me!")
	_add_choice("Play this version again", _restart)
	_add_choice("Return to Screening Journey", _return_to_journey)


func _restart() -> void:
	if is_instance_valid(ending):
		remove_child(ending)
		ending.queue_free()
	room.show()
	question_index = 0
	post_index = 0
	answers.clear()
	_show_question()


func _return_to_journey() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.parent.postMessage({type:'game3-complete'}, window.location.origin)")
	else:
		_restart()
