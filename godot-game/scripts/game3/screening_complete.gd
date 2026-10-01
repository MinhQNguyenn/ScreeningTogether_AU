extends Control

signal journey_requested

const CHARACTER_TEXTURE := preload(
	"res://assets/sprout_lands/character.png"
)

var puzzle_time_seconds: int = 0
var puzzle_moves: int = 0
var screening_preference: String = ""
var stage_index: int = 0
var page: VBoxContainer


func configure(
	time_seconds: int,
	moves: int,
	preference: String,
) -> void:
	puzzle_time_seconds = time_seconds
	puzzle_moves = moves
	screening_preference = preference


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Game3UI.add_margins(margin, 34, 34, 34, 34)
	add_child(margin)
	page = VBoxContainer.new()
	page.add_theme_constant_override("separation", 20)
	margin.add_child(page)
	_show_stage(0)


func _show_stage(new_stage_index: int) -> void:
	stage_index = new_stage_index
	for child in page.get_children():
		child.free()
	if stage_index == 0:
		_build_final_information_popup()
	else:
		_build_positive_ending()


func _build_final_information_popup() -> void:
	var top_spacer := Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(top_spacer)

	var popup := PanelContainer.new()
	popup.custom_minimum_size = Vector2(0.0, 720.0)
	popup.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(
			Game3UI.WHITE,
			32,
			Game3UI.BORDER,
			3,
		),
	)
	page.add_child(popup)

	var popup_margin := MarginContainer.new()
	Game3UI.add_margins(popup_margin, 36, 36, 38, 38)
	popup.add_child(popup_margin)
	var popup_copy := VBoxContainer.new()
	popup_copy.alignment = BoxContainer.ALIGNMENT_CENTER
	popup_copy.add_theme_constant_override("separation", 22)
	popup_margin.add_child(popup_copy)

	popup_copy.add_child(
		Game3UI.make_label(
			"BEFORE LUNA HEADS HOME",
			18,
			Game3UI.ROSE,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	popup_copy.add_child(
		Game3UI.make_label(
			"What happens after screening?",
			38,
			Game3UI.INK,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)

	var result_panel := PanelContainer.new()
	result_panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(Game3UI.SAGE_LIGHT, 22),
	)
	popup_copy.add_child(result_panel)
	var result_text := Game3UI.make_label(
		"Your sample is sent to a laboratory for testing.\n"
		+ "You receive your result later.",
		26,
		Game3UI.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
	)
	result_text.custom_minimum_size.y = 130.0
	result_panel.add_child(result_text)

	var reminder_panel := PanelContainer.new()
	reminder_panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(Game3UI.BLUSH, 22),
	)
	popup_copy.add_child(reminder_panel)
	var reminder_text := Game3UI.make_label(
		"For most eligible people, routine cervical screening is every "
		+ "5 years when no earlier follow-up is needed.",
		25,
		Game3UI.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
	)
	reminder_text.custom_minimum_size.y = 155.0
	reminder_panel.add_child(reminder_text)

	popup_copy.add_child(
		Game3UI.make_label(
			"This is general information, not personal medical advice.",
			18,
			Game3UI.MUTED,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	var continue_button := Game3UI.make_button(
		"Continue with Luna",
		true,
		22,
	)
	continue_button.custom_minimum_size.y = 72.0
	continue_button.pressed.connect(_show_stage.bind(1))
	popup_copy.add_child(continue_button)

	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(bottom_spacer)


func _build_positive_ending() -> void:
	page.add_child(
		Game3UI.make_label(
			"HEADING HOME",
			20,
			Game3UI.SAGE,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	page.add_child(
		Game3UI.make_label(
			"Luna walks into the sunset",
			46,
			Game3UI.INK,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	var positive_message := Game3UI.make_label(
		"Watch Luna follow the path to the horizon.",
		25,
		Game3UI.MUTED,
		HORIZONTAL_ALIGNMENT_CENTER,
	)
	positive_message.custom_minimum_size.y = 72.0
	page.add_child(positive_message)

	var ending_panel := PanelContainer.new()
	ending_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ending_panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(Game3UI.BLUSH, 28, Game3UI.BORDER, 2),
	)
	page.add_child(ending_panel)
	var sunset_stage := Control.new()
	sunset_stage.custom_minimum_size = Vector2(560.0, 430.0)
	sunset_stage.clip_contents = true
	ending_panel.add_child(sunset_stage)

	var sunset_path := SunsetPathScene.new()
	sunset_path.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sunset_stage.add_child(sunset_path)

	var luna := AnimatedSprite2D.new()
	luna.sprite_frames = _make_luna_walk_frames()
	luna.animation = "walk_away"
	luna.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	luna.z_index = 2
	sunset_stage.add_child(luna)

	var completion_popup := _make_completion_popup()
	sunset_stage.add_child(completion_popup)
	_animate_sunset_walk(sunset_path, luna, completion_popup)


func _make_completion_popup() -> ColorRect:
	var overlay := ColorRect.new()
	overlay.name = "CompletionPopup"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.16, 0.12, 0.15, 0.78)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	overlay.z_index = 5
	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(centre)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(500.0, 330.0)
	panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(Game3UI.CREAM, 28, Game3UI.GOLD, 4),
	)
	centre.add_child(panel)
	var copy := VBoxContainer.new()
	copy.alignment = BoxContainer.ALIGNMENT_CENTER
	copy.add_theme_constant_override("separation", 18)
	panel.add_child(copy)
	copy.add_child(
		Game3UI.make_label(
			"SCREENING COMPLETE",
			18,
			Game3UI.ROSE,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	copy.add_child(
		Game3UI.make_label(
			"Screening process complete!",
			34,
			Game3UI.INK,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	copy.add_child(
		Game3UI.make_label(
			"Well done, Luna. You stayed informed and in control.",
			22,
			Game3UI.MUTED,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	var continue_button := Game3UI.make_button(
		"Return to Screening Journey",
		true,
		21,
	)
	continue_button.custom_minimum_size.y = 68.0
	continue_button.pressed.connect(func() -> void: journey_requested.emit())
	copy.add_child(continue_button)
	return overlay


func _make_luna_walk_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation("walk_away")
	frames.set_animation_speed("walk_away", 7.0)
	frames.set_animation_loop("walk_away", true)
	for frame_x in [16.0, 64.0, 112.0, 160.0]:
		var frame := AtlasTexture.new()
		frame.atlas = CHARACTER_TEXTURE
		frame.region = Rect2(frame_x, 64.0, 16.0, 16.0)
		frames.add_frame("walk_away", frame)
	return frames


func _animate_sunset_walk(
	sunset_path: SunsetPathScene,
	luna: AnimatedSprite2D,
	completion_popup: ColorRect,
) -> void:
	await get_tree().process_frame
	if not is_instance_valid(sunset_path) or not is_instance_valid(luna):
		return
	var path_points := sunset_path.get_walking_path()
	luna.scale = Vector2(5.5, 5.5)
	var foot_offset := Vector2(0.0, 8.0 * luna.scale.y)
	luna.position = path_points[0] - foot_offset
	luna.play("walk_away")
	var walk_tween := create_tween()
	walk_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for point_index in range(1, path_points.size()):
		walk_tween.tween_property(
			luna,
			"position",
			path_points[point_index] - foot_offset,
			1.15,
		)
	walk_tween.tween_property(luna, "modulate:a", 0.0, 0.55)
	await walk_tween.finished
	_show_completion_popup(luna, completion_popup)


func _show_completion_popup(
	luna: AnimatedSprite2D,
	completion_popup: ColorRect,
) -> void:
	if not is_instance_valid(completion_popup):
		return
	if is_instance_valid(luna):
		luna.visible = false
	completion_popup.visible = true
	completion_popup.modulate.a = 0.0
	var popup_tween := create_tween()
	popup_tween.tween_property(completion_popup, "modulate:a", 1.0, 0.35)
