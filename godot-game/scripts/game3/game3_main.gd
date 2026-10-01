extends Control

const DOCTOR_CONVERSATION := preload(
	"res://scenes/doctor_conversation.tscn"
)
const SLIDING_PUZZLE := preload("res://scenes/sliding_puzzle.tscn")
const SCREENING_COMPLETE := preload(
	"res://scenes/screening_complete.tscn"
)

var active_screen: Control
var screening_preference: String = ""
var puzzle_time_seconds: int = 0
var puzzle_moves: int = 0
var procedure_intro_button: Button
var puzzle_instruction_button: Button


func _ready() -> void:
	_build_background()
	_show_office_entrance()


func _build_background() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Game3UI.CREAM
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)


func _show_office_entrance() -> void:
	var screen := MarginContainer.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Game3UI.add_margins(screen, 34, 34, 34, 34)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	screen.add_child(content)

	var kicker := Game3UI.make_label(
		"SCREENING JOURNEY  |  GAME 3", 18, Game3UI.ROSE
	)
	content.add_child(kicker)

	var title := Game3UI.make_label(
		"Luna's screening appointment", 40, Game3UI.INK
	)
	title.custom_minimum_size.y = 56.0
	content.add_child(title)

	var intro := Game3UI.make_label(
		"Luna's name has been called. She walks straight into the "
		+ "doctor's office for the first time.",
		24,
		Game3UI.MUTED,
	)
	intro.custom_minimum_size.y = 78.0
	content.add_child(intro)

	var room_panel := PanelContainer.new()
	room_panel.custom_minimum_size.y = 450.0
	room_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	room_panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(Game3UI.BLUSH, 28, Game3UI.BORDER, 2),
	)
	content.add_child(room_panel)

	var illustration := OfficeEntrance.new()
	illustration.custom_minimum_size = Vector2(0.0, 450.0)
	room_panel.add_child(illustration)

	var note := Game3UI.make_label(
		"A short conversation comes first.",
		22,
		Game3UI.MUTED,
		HORIZONTAL_ALIGNMENT_CENTER,
	)
	note.custom_minimum_size.y = 42.0
	content.add_child(note)

	var start_button := Game3UI.make_button(
		"Luna is walking in...", true, 23
	)
	start_button.disabled = true
	start_button.custom_minimum_size.y = 70.0
	content.add_child(start_button)
	illustration.arrived.connect(
		func() -> void:
			start_button.disabled = false
			start_button.text = "Start conversation"
	)
	start_button.pressed.connect(_show_conversation)
	_set_screen(screen)


func _show_conversation() -> void:
	var conversation := DOCTOR_CONVERSATION.instantiate()
	conversation.preference_selected.connect(
		func(preference: String) -> void:
			screening_preference = preference
	)
	conversation.finished.connect(_on_conversation_finished)
	_transition_to(conversation)


func _on_conversation_finished(preference: String) -> void:
	screening_preference = preference
	_show_procedure_intro()


func _show_procedure_intro() -> void:
	var screen := MarginContainer.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Game3UI.add_margins(screen, 42, 42, 42, 42)
	var centre := CenterContainer.new()
	screen.add_child(centre)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 650.0)
	panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(
			Game3UI.WHITE,
			30,
			Game3UI.BORDER,
			3,
		),
	)
	centre.add_child(panel)
	var panel_margin := MarginContainer.new()
	Game3UI.add_margins(panel_margin, 38, 38, 42, 42)
	panel.add_child(panel_margin)
	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 24)
	panel_margin.add_child(content)

	content.add_child(
		Game3UI.make_label(
			"READY TO BEGIN",
			18,
			Game3UI.ROSE,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	var doctor := TextureRect.new()
	doctor.custom_minimum_size = Vector2(112.0, 112.0)
	doctor.texture = Game3UI.make_healthcare_professional_texture()
	doctor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	doctor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	doctor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	content.add_child(doctor)
	content.add_child(
		Game3UI.make_label(
			"Let's begin. The sample collection itself can take only a "
			+ "couple of minutes.",
			30,
			Game3UI.INK,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	content.add_child(
		Game3UI.make_label(
			"You are in control and can ask to pause at any time.",
			21,
			Game3UI.MUTED,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	procedure_intro_button = Game3UI.make_button(
		"Begin the puzzle",
		true,
		23,
	)
	procedure_intro_button.custom_minimum_size.y = 72.0
	procedure_intro_button.pressed.connect(_show_puzzle_instructions)
	content.add_child(procedure_intro_button)
	_transition_to(screen)


func _show_puzzle_instructions() -> void:
	var screen := MarginContainer.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Game3UI.add_margins(screen, 42, 42, 42, 42)
	var centre := CenterContainer.new()
	screen.add_child(centre)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 700.0)
	panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(
			Game3UI.WHITE,
			30,
			Game3UI.BORDER,
			3,
		),
	)
	centre.add_child(panel)
	var panel_margin := MarginContainer.new()
	Game3UI.add_margins(panel_margin, 38, 38, 42, 42)
	panel.add_child(panel_margin)
	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 22)
	panel_margin.add_child(content)

	content.add_child(
		Game3UI.make_label(
			"HOW TO PLAY",
			18,
			Game3UI.ROSE,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	content.add_child(
		Game3UI.make_label(
			"Put Luna's picture together",
			36,
			Game3UI.INK,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	var luna_preview := TextureRect.new()
	luna_preview.custom_minimum_size = Vector2(180.0, 180.0)
	luna_preview.texture = Game3UI.make_luna_portrait_texture()
	luna_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	luna_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	luna_preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	content.add_child(luna_preview)
	for instruction in [
		"1. Look at the completed Luna picture.",
		"2. Tap a tile beside the empty space.",
		"3. Move the tiles until the pictures match.",
	]:
		content.add_child(
			Game3UI.make_label(
				instruction,
				22,
				Game3UI.INK,
				HORIZONTAL_ALIGNMENT_LEFT,
			)
		)
	content.add_child(
		Game3UI.make_label(
			"The timer starts after a quick picture preview.",
			19,
			Game3UI.MUTED,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	puzzle_instruction_button = Game3UI.make_button(
		"Show me the puzzle",
		true,
		23,
	)
	puzzle_instruction_button.custom_minimum_size.y = 72.0
	puzzle_instruction_button.pressed.connect(_start_puzzle)
	content.add_child(puzzle_instruction_button)
	_transition_to(screen)


func _start_puzzle() -> void:
	var puzzle := SLIDING_PUZZLE.instantiate()
	puzzle.finished.connect(_on_puzzle_finished)
	_transition_to(puzzle)


func _on_puzzle_finished(time_seconds: int, moves: int) -> void:
	puzzle_time_seconds = time_seconds
	puzzle_moves = moves
	var completion := SCREENING_COMPLETE.instantiate()
	completion.configure(
		puzzle_time_seconds,
		puzzle_moves,
		screening_preference,
	)
	completion.journey_requested.connect(_on_journey_requested)
	_transition_to(completion)


func _on_journey_requested() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval(
			"window.parent.postMessage({type:'game3-complete'}, "
			+ "window.location.origin);"
		)
	else:
		get_tree().reload_current_scene()


func _set_screen(screen: Control) -> void:
	active_screen = screen
	active_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(active_screen)


func _transition_to(next_screen: Control) -> void:
	next_screen.modulate.a = 0.0
	next_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(next_screen)
	var old_screen := active_screen
	active_screen = next_screen
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(next_screen, "modulate:a", 1.0, 0.28)
	if is_instance_valid(old_screen):
		tween.tween_property(old_screen, "modulate:a", 0.0, 0.22)
	await tween.finished
	if is_instance_valid(old_screen):
		old_screen.queue_free()
