extends Control

signal preference_selected(preference: String)
signal finished(preference: String)

const QUESTIONS := [
	{
		"topic": "YOUR EXPERIENCE",
		"question": "Have you had a cervical screening test before?",
		"options": ["Yes", "No", "I'm not sure"],
	},
	{
		"topic": "YOUR CHOICE",
		"question": "How would you prefer your sample to be collected?",
		"options": [
			"I'd like to collect the sample myself",
			"I'd prefer a healthcare professional to collect it",
			"I'd like to know more about my options",
		],
	},
	{
		"topic": "YOUR COMFORT",
		"question": "If you feel uncomfortable during the test, what can you do?",
		"options": [
			"Ask the healthcare professional to pause or stop",
			"Stay quiet and wait",
			"I'm not sure",
		],
	},
]

var question_index: int = 0
var selected_preference: String = ""
var luna_portrait: ImageTexture
var professional_portrait: ImageTexture
var question_content: VBoxContainer
var question_scroll: ScrollContainer
var progress_row: HBoxContainer
var response_panel: PanelContainer
var response_label: Label
var continue_button: Button
var option_buttons: Array[Button] = []


func _ready() -> void:
	luna_portrait = Game3UI.make_luna_portrait_texture()
	professional_portrait = Game3UI.make_healthcare_professional_texture()
	_build_interface()
	_show_question()


func _build_interface() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Game3UI.add_margins(margin, 28, 25, 28, 25)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 14)
	margin.add_child(page)

	var kicker := Game3UI.make_label(
		"A SHORT CONVERSATION", 17, Game3UI.ROSE,
		HORIZONTAL_ALIGNMENT_CENTER
	)
	page.add_child(kicker)
	page.add_child(
		Game3UI.make_label(
			"Talk with your healthcare professional",
			34,
			Game3UI.INK,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	var reassurance := Game3UI.make_label(
		"Choose what feels right for you. There are no wrong answers.",
		20,
		Game3UI.MUTED,
		HORIZONTAL_ALIGNMENT_CENTER,
	)
	reassurance.custom_minimum_size.y = 44.0
	page.add_child(reassurance)

	var conversation_panel := PanelContainer.new()
	conversation_panel.custom_minimum_size.y = 190.0
	conversation_panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(Game3UI.SAGE_LIGHT, 25, Game3UI.BORDER, 2),
	)
	page.add_child(conversation_panel)
	var people_row := HBoxContainer.new()
	people_row.add_theme_constant_override("separation", 12)
	conversation_panel.add_child(people_row)

	people_row.add_child(_make_character_card(luna_portrait, "LUNA", 112.0))

	var speech := VBoxContainer.new()
	speech.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speech.alignment = BoxContainer.ALIGNMENT_CENTER
	speech.add_theme_constant_override("separation", 6)
	people_row.add_child(speech)
	speech.add_child(
		Game3UI.make_label(
			"HEALTHCARE PROFESSIONAL",
			15,
			Game3UI.SAGE,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	speech.add_child(
		Game3UI.make_label(
			"Let's talk about what feels right for you.",
			22,
			Game3UI.INK,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)

	people_row.add_child(
		_make_character_card(
			professional_portrait,
			"HEALTH PROFESSIONAL",
			112.0,
		)
	)

	progress_row = HBoxContainer.new()
	progress_row.alignment = BoxContainer.ALIGNMENT_CENTER
	progress_row.add_theme_constant_override("separation", 10)
	page.add_child(progress_row)

	var question_panel := PanelContainer.new()
	question_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	question_panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(Game3UI.WHITE, 28, Game3UI.BORDER, 2),
	)
	page.add_child(question_panel)

	question_scroll = ScrollContainer.new()
	question_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	question_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	question_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	question_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	question_panel.add_child(question_scroll)

	question_content = VBoxContainer.new()
	question_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	question_content.add_theme_constant_override("separation", 13)
	question_scroll.add_child(question_content)


func _make_character_card(
	texture: Texture2D,
	character_name: String,
	width: float,
) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(width, 154.0)
	card.add_theme_stylebox_override(
		"panel", Game3UI.make_panel_style(Game3UI.CREAM, 18)
	)
	var card_copy := VBoxContainer.new()
	card_copy.add_theme_constant_override("separation", 4)
	card.add_child(card_copy)
	var portrait := TextureRect.new()
	portrait.texture = texture
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portrait.custom_minimum_size.y = 112.0
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_copy.add_child(portrait)
	card_copy.add_child(
		Game3UI.make_label(
			character_name,
			12,
			Game3UI.MUTED,
			HORIZONTAL_ALIGNMENT_CENTER,
			false,
		)
	)
	return card


func _show_question() -> void:
	for child in question_content.get_children():
		question_content.remove_child(child)
		child.queue_free()
	option_buttons.clear()
	_update_progress()

	var question_data: Dictionary = QUESTIONS[question_index]
	var topic_label := Game3UI.make_label(
		str(question_data["topic"]),
		16,
		Game3UI.ROSE,
	)
	topic_label.custom_minimum_size.y = 28.0
	question_content.add_child(topic_label)

	var question_label := Game3UI.make_label(
		str(question_data["question"]), 29, Game3UI.INK
	)
	question_label.custom_minimum_size.y = 88.0
	question_content.add_child(question_label)

	for option_text in question_data["options"]:
		var option := Game3UI.make_button(str(option_text), false, 20)
		option.custom_minimum_size.y = 72.0
		option.alignment = HORIZONTAL_ALIGNMENT_LEFT
		option.pressed.connect(_on_option_selected.bind(str(option_text)))
		question_content.add_child(option)
		option_buttons.append(option)

	response_panel = PanelContainer.new()
	response_panel.visible = false
	response_panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(Game3UI.BLUSH, 18, Game3UI.ROSE, 2),
	)
	question_content.add_child(response_panel)
	var response_copy := VBoxContainer.new()
	response_copy.add_theme_constant_override("separation", 3)
	response_panel.add_child(response_copy)
	response_copy.add_child(
		Game3UI.make_label(
			"YOUR HEALTHCARE PROFESSIONAL SAYS",
			14,
			Game3UI.ROSE_DARK,
		)
	)
	response_label = Game3UI.make_label("", 20, Game3UI.INK)
	response_label.custom_minimum_size.y = 70.0
	response_copy.add_child(response_label)

	continue_button = Game3UI.make_button(
		"Continue" if question_index < 2 else "Start the puzzle",
		true,
		22,
	)
	continue_button.visible = false
	continue_button.custom_minimum_size.y = 66.0
	continue_button.pressed.connect(_on_continue_pressed)
	question_content.add_child(continue_button)


func _update_progress() -> void:
	for child in progress_row.get_children():
		progress_row.remove_child(child)
		child.queue_free()
	for index in QUESTIONS.size():
		var step := Label.new()
		step.text = str(index + 1)
		Game3UI.apply_readable_font(step)
		step.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		step.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		step.custom_minimum_size = Vector2(42.0, 42.0)
		step.add_theme_font_size_override("font_size", 18)
		step.add_theme_color_override(
			"font_color",
			Game3UI.CREAM if index == question_index else Game3UI.MUTED,
		)
		step.add_theme_stylebox_override(
			"normal",
			Game3UI.make_panel_style(
				Game3UI.ROSE if index == question_index else Game3UI.BLUSH,
				21,
			),
		)
		progress_row.add_child(step)


func _on_option_selected(option_text: String) -> void:
	for option in option_buttons:
		option.disabled = true
		if option.text == option_text:
			Game3UI.style_selected_button(option)

	if question_index == 0:
		if option_text == "Yes":
			response_label.text = (
				"Thanks for sharing. Tell me what worked well - or what you "
				+ "would like to be different this time."
			)
		elif option_text == "No":
			response_label.text = (
				"That's okay. I'll explain each step before we begin, and "
				+ "you can ask questions."
			)
		else:
			response_label.text = (
				"That's okay. We can check together, and I'll explain what "
				+ "happens before we begin."
			)
	elif question_index == 1:
		selected_preference = option_text
		preference_selected.emit(selected_preference)
		if option_text == "I'd like to collect the sample myself":
			response_label.text = (
				"If self-collection is suitable for you, I can explain how "
				+ "and give you privacy."
			)
		elif option_text == "I'd prefer a healthcare professional to collect it":
			response_label.text = (
				"Of course. I can explain each step and check that you are "
				+ "comfortable."
			)
		else:
			response_label.text = (
				"Depending on your circumstances, you may be able to collect "
				+ "your own sample or have a healthcare professional collect it."
			)
	else:
		if option_text == "Ask the healthcare professional to pause or stop":
			response_label.text = (
				"Exactly. You are in control. You can ask to pause or stop "
				+ "at any time."
			)
		elif option_text == "Stay quiet and wait":
			response_label.text = (
				"You do not need to stay quiet. You are in control and can "
				+ "ask to pause or stop."
			)
		else:
			response_label.text = (
				"You can ask to pause or stop. You are in control throughout "
				+ "the test."
			)

	response_panel.visible = true
	continue_button.visible = true
	continue_button.grab_focus()
	call_deferred("_reveal_continue_button")


func _reveal_continue_button() -> void:
	await get_tree().process_frame
	if is_instance_valid(question_scroll) and is_instance_valid(continue_button):
		question_scroll.ensure_control_visible(continue_button)


func _on_continue_pressed() -> void:
	if question_index >= QUESTIONS.size() - 1:
		finished.emit(selected_preference)
		return
	question_index += 1
	_show_question()
