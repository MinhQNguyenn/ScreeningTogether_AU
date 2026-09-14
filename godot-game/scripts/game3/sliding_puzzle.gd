extends Control

signal finished(time_seconds: int, moves: int)

const SOLVED := [0, 1, 2, 3, 4, 5, 6, 7, -1]
const SHUFFLE_STEPS := 45
const MINIMUM_MANHATTAN_DISTANCE := 12
const TWO_MINUTE_LIMIT_SECONDS: int = 120

var board: Array = []
var starting_board: Array = []
var tile_buttons: Array[PuzzleTileButton] = []
var elapsed_seconds: float = 0.0
var move_count: int = 0
var timer_running: bool = false
var puzzle_complete: bool = false
var time_limit_reached: bool = false
var rng := RandomNumberGenerator.new()
var message_revision: int = 0
var picture_preview_revision: int = 0
var luna_portrait: ImageTexture

var timer_label: Label
var moves_label: Label
var instruction_label: Label
var grid: GridContainer
var full_image: TextureRect
var target_image: TextureRect
var control_row: HBoxContainer
var finish_after_timeout_button: Button
var feedback_panel: PanelContainer
var feedback_label: Label
var completion_panel: PanelContainer
var completion_title_label: Label
var completion_time_label: Label
var two_minute_overlay: ColorRect
var two_minute_continue_button: Button
var two_minute_resume_button: Button


func _ready() -> void:
	rng.randomize()
	luna_portrait = Game3UI.make_luna_portrait_texture()
	_build_interface()
	_start_new_puzzle()


func _process(delta: float) -> void:
	if not timer_running:
		return
	elapsed_seconds = minf(
		elapsed_seconds + delta,
		TWO_MINUTE_LIMIT_SECONDS,
	)
	timer_label.text = "SCREENING TIMER  |  %s" % Game3UI.format_clock(
		int(elapsed_seconds)
	)
	if elapsed_seconds >= TWO_MINUTE_LIMIT_SECONDS:
		_show_two_minute_fact()


func _build_interface() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Game3UI.add_margins(margin, 28, 26, 28, 26)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 14)
	margin.add_child(page)

	var kicker := Game3UI.make_label(
		"THE QUICK SAMPLE CHALLENGE", 17, Game3UI.ROSE
	)
	page.add_child(kicker)

	var heading_row := HBoxContainer.new()
	heading_row.add_theme_constant_override("separation", 12)
	page.add_child(heading_row)
	var title := Game3UI.make_label("Put Luna together", 37, Game3UI.INK)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_row.add_child(title)
	moves_label = Game3UI.make_label(
		"Moves: 0",
		20,
		Game3UI.ROSE_DARK,
		HORIZONTAL_ALIGNMENT_RIGHT,
		false,
	)
	heading_row.add_child(moves_label)

	var timer_panel := PanelContainer.new()
	timer_panel.custom_minimum_size.y = 86.0
	timer_panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(Game3UI.INK, 22, Game3UI.GOLD, 3),
	)
	page.add_child(timer_panel)
	timer_label = Game3UI.make_label(
		"SCREENING TIMER  |  00:00",
		34,
		Game3UI.CREAM,
		HORIZONTAL_ALIGNMENT_CENTER,
		false,
	)
	timer_panel.add_child(timer_label)

	instruction_label = Game3UI.make_label(
		"Tap a picture piece next to the empty space.",
		22,
		Game3UI.MUTED,
		HORIZONTAL_ALIGNMENT_CENTER,
	)
	instruction_label.custom_minimum_size.y = 54.0
	page.add_child(instruction_label)
	_build_target_reference(page)

	var board_center := CenterContainer.new()
	board_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(board_center)
	var board_stack := Control.new()
	board_stack.custom_minimum_size = Vector2(526.0, 526.0)
	board_center.add_child(board_stack)

	var board_background := Panel.new()
	board_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	board_background.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(Game3UI.BLUSH, 22, Game3UI.BORDER, 2),
	)
	board_stack.add_child(board_background)

	grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid.offset_left = 8.0
	grid.offset_top = 8.0
	grid.offset_right = -8.0
	grid.offset_bottom = -8.0
	board_stack.add_child(grid)
	for slot_index in 9:
		var tile_button := PuzzleTileButton.new()
		tile_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tile_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tile_button.pressed.connect(_on_tile_pressed.bind(slot_index))
		grid.add_child(tile_button)
		tile_buttons.append(tile_button)

	full_image = TextureRect.new()
	full_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	full_image.offset_left = 8.0
	full_image.offset_top = 8.0
	full_image.offset_right = -8.0
	full_image.offset_bottom = -8.0
	full_image.texture = luna_portrait
	full_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	full_image.stretch_mode = TextureRect.STRETCH_SCALE
	full_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	full_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	full_image.visible = false
	board_stack.add_child(full_image)

	control_row = HBoxContainer.new()
	control_row.add_theme_constant_override("separation", 12)
	page.add_child(control_row)
	var reset_button := Game3UI.make_button("Reset", false, 21)
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset_button.pressed.connect(_reset_puzzle)
	control_row.add_child(reset_button)
	var shuffle_button := Game3UI.make_button("New puzzle", false, 21)
	shuffle_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shuffle_button.pressed.connect(_start_new_puzzle)
	control_row.add_child(shuffle_button)
	finish_after_timeout_button = Game3UI.make_button("Finish now", true, 19)
	finish_after_timeout_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	finish_after_timeout_button.visible = false
	finish_after_timeout_button.pressed.connect(
		_on_two_minute_continue_pressed
	)
	control_row.add_child(finish_after_timeout_button)

	feedback_panel = PanelContainer.new()
	feedback_panel.visible = false
	feedback_panel.add_theme_stylebox_override(
		"panel", Game3UI.make_panel_style(Game3UI.SAGE_LIGHT, 17)
	)
	page.add_child(feedback_panel)
	feedback_label = Game3UI.make_label(
		"",
		20,
		Game3UI.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
	)
	feedback_label.custom_minimum_size.y = 58.0
	feedback_panel.add_child(feedback_label)

	completion_panel = PanelContainer.new()
	completion_panel.visible = false
	completion_panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(Game3UI.WHITE, 23, Game3UI.ROSE, 3),
	)
	page.add_child(completion_panel)
	var completion_copy := VBoxContainer.new()
	completion_copy.add_theme_constant_override("separation", 9)
	completion_panel.add_child(completion_copy)
	completion_title_label = Game3UI.make_label(
		"Puzzle complete!",
		31,
		Game3UI.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
	)
	completion_copy.add_child(completion_title_label)
	completion_time_label = Game3UI.make_label(
		"Your time: 0 seconds",
		27,
		Game3UI.ROSE_DARK,
		HORIZONTAL_ALIGNMENT_CENTER,
	)
	completion_copy.add_child(completion_time_label)
	completion_copy.add_child(
		Game3UI.make_label(
			"Finished already?", 26, Game3UI.INK,
			HORIZONTAL_ALIGNMENT_CENTER
		)
	)
	completion_copy.add_child(
		Game3UI.make_label(
			"The sample collection part of cervical screening can take "
			+ "only a few minutes.",
			21,
			Game3UI.MUTED,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	var continue_button := Game3UI.make_button("What happens next?", true, 22)
	continue_button.pressed.connect(_on_completion_continue)
	completion_copy.add_child(continue_button)

	_build_two_minute_overlay()


func _build_target_reference(page: VBoxContainer) -> void:
	var reference_center := CenterContainer.new()
	page.add_child(reference_center)
	var reference_panel := PanelContainer.new()
	reference_panel.custom_minimum_size = Vector2(430.0, 148.0)
	reference_panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(
			Game3UI.SAGE_LIGHT,
			20,
			Game3UI.BORDER,
			2,
		),
	)
	reference_center.add_child(reference_panel)
	var reference_margin := MarginContainer.new()
	Game3UI.add_margins(reference_margin, 18, 18, 14, 14)
	reference_panel.add_child(reference_margin)
	var reference_row := HBoxContainer.new()
	reference_row.alignment = BoxContainer.ALIGNMENT_CENTER
	reference_row.add_theme_constant_override("separation", 20)
	reference_margin.add_child(reference_row)
	var reference_copy := VBoxContainer.new()
	reference_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reference_copy.alignment = BoxContainer.ALIGNMENT_CENTER
	reference_row.add_child(reference_copy)
	reference_copy.add_child(
		Game3UI.make_label(
			"PICTURE TO MAKE",
			16,
			Game3UI.ROSE_DARK,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	reference_copy.add_child(
		Game3UI.make_label(
			"Match Luna's face",
			21,
			Game3UI.INK,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	target_image = TextureRect.new()
	target_image.custom_minimum_size = Vector2(112.0, 112.0)
	target_image.texture = luna_portrait
	target_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	target_image.stretch_mode = TextureRect.STRETCH_SCALE
	target_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	target_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reference_row.add_child(target_image)


func _build_two_minute_overlay() -> void:
	two_minute_overlay = ColorRect.new()
	two_minute_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	two_minute_overlay.color = Color(0.19, 0.16, 0.18, 0.82)
	two_minute_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	two_minute_overlay.visible = false
	add_child(two_minute_overlay)

	var overlay_center := CenterContainer.new()
	overlay_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	two_minute_overlay.add_child(overlay_center)

	var fact_panel := PanelContainer.new()
	fact_panel.custom_minimum_size = Vector2(560.0, 430.0)
	fact_panel.add_theme_stylebox_override(
		"panel",
		Game3UI.make_panel_style(
			Game3UI.CREAM,
			28,
			Game3UI.GOLD,
			4,
		),
	)
	overlay_center.add_child(fact_panel)

	var fact_copy := VBoxContainer.new()
	fact_copy.alignment = BoxContainer.ALIGNMENT_CENTER
	fact_copy.add_theme_constant_override("separation", 14)
	fact_panel.add_child(fact_copy)
	fact_copy.add_child(
		Game3UI.make_label(
			"02:00",
			42,
			Game3UI.ROSE_DARK,
			HORIZONTAL_ALIGNMENT_CENTER,
			false,
		)
	)
	fact_copy.add_child(
		Game3UI.make_label(
			"Two minutes already!",
			34,
			Game3UI.INK,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	var fact := Game3UI.make_label(
		"You just spent two minutes playing Luna's puzzle. The sample "
		+ "collection part of cervical screening can take only a few minutes.",
		23,
		Game3UI.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
	)
	fact.custom_minimum_size.y = 118.0
	fact_copy.add_child(fact)
	fact_copy.add_child(
		Game3UI.make_label(
			"This does not include the whole appointment.",
			19,
			Game3UI.MUTED,
			HORIZONTAL_ALIGNMENT_CENTER,
		)
	)
	two_minute_resume_button = Game3UI.make_button(
		"Continue this puzzle",
		false,
		22,
	)
	two_minute_resume_button.custom_minimum_size.y = 66.0
	two_minute_resume_button.pressed.connect(
		_on_two_minute_resume_pressed
	)
	fact_copy.add_child(two_minute_resume_button)
	two_minute_continue_button = Game3UI.make_button(
		"Finish puzzle",
		true,
		23,
	)
	two_minute_continue_button.custom_minimum_size.y = 70.0
	two_minute_continue_button.pressed.connect(
		_on_two_minute_continue_pressed
	)
	fact_copy.add_child(two_minute_continue_button)


func _start_new_puzzle() -> void:
	board = _generate_solvable_board()
	starting_board = board.duplicate()
	_restart_timer_and_ui()
	_show_picture_preview()


func _reset_puzzle() -> void:
	board = starting_board.duplicate()
	_restart_timer_and_ui()


func _restart_timer_and_ui() -> void:
	picture_preview_revision += 1
	elapsed_seconds = 0.0
	move_count = 0
	puzzle_complete = false
	time_limit_reached = false
	timer_running = true
	message_revision += 1
	timer_label.text = "SCREENING TIMER  |  00:00"
	moves_label.text = "Moves: 0"
	feedback_label.text = ""
	feedback_label.modulate.a = 1.0
	feedback_panel.visible = false
	control_row.visible = true
	finish_after_timeout_button.visible = false
	completion_panel.visible = false
	completion_title_label.text = "Puzzle complete!"
	two_minute_overlay.visible = false
	full_image.visible = false
	grid.visible = true
	if is_instance_valid(instruction_label):
		instruction_label.text = "Tap a picture piece next to the empty space."
	_render_board()


func _show_picture_preview() -> void:
	picture_preview_revision += 1
	var current_revision := picture_preview_revision
	timer_running = false
	grid.visible = false
	full_image.visible = true
	full_image.modulate.a = 1.0
	control_row.visible = false
	instruction_label.text = "Take a quick look at Luna before the pieces move."
	await get_tree().create_timer(1.4).timeout
	_finish_picture_preview(current_revision)


func _finish_picture_preview(expected_revision: int = -1) -> void:
	if expected_revision >= 0 and expected_revision != picture_preview_revision:
		return
	if expected_revision < 0:
		picture_preview_revision += 1
	if puzzle_complete or time_limit_reached:
		return
	full_image.visible = false
	grid.visible = true
	control_row.visible = true
	instruction_label.text = "Tap a picture piece next to the empty space."
	timer_running = true
	_render_board()


func _generate_solvable_board() -> Array:
	var candidate: Array = SOLVED.duplicate()
	for attempt in 30:
		candidate = SOLVED.duplicate()
		var empty_index: int = 8
		var previous_empty_index: int = -1
		for step in SHUFFLE_STEPS:
			var neighbours := _neighbour_indices(empty_index)
			if neighbours.size() > 1:
				neighbours.erase(previous_empty_index)
			var chosen_index: int = neighbours[rng.randi_range(0, neighbours.size() - 1)]
			candidate[empty_index] = candidate[chosen_index]
			candidate[chosen_index] = -1
			previous_empty_index = empty_index
			empty_index = chosen_index
		if (
			candidate != SOLVED
			and _manhattan_distance(candidate) >= MINIMUM_MANHATTAN_DISTANCE
			and is_board_solvable(candidate)
		):
			return candidate
	# Deterministic, solvable fallback with a useful distance from completion.
	return [7, 6, 5, 4, 3, 2, 1, 0, -1]


func _neighbour_indices(index: int) -> Array[int]:
	var neighbours: Array[int] = []
	var row: int = index / 3
	var column: int = index % 3
	if row > 0:
		neighbours.append(index - 3)
	if row < 2:
		neighbours.append(index + 3)
	if column > 0:
		neighbours.append(index - 1)
	if column < 2:
		neighbours.append(index + 1)
	return neighbours


func _on_tile_pressed(slot_index: int) -> void:
	if puzzle_complete or (not timer_running and not time_limit_reached):
		return
	var empty_index: int = board.find(-1)
	if slot_index not in _neighbour_indices(empty_index):
		return
	board[empty_index] = board[slot_index]
	board[slot_index] = -1
	move_count += 1
	moves_label.text = "Moves: %d" % move_count
	_render_board()
	_pulse_tile(empty_index)
	_show_move_message_if_needed()
	if board == SOLVED:
		_complete_puzzle()


func _render_board() -> void:
	for slot_index in 9:
		tile_buttons[slot_index].configure(
			slot_index,
			int(board[slot_index]),
			luna_portrait,
		)


func _pulse_tile(slot_index: int) -> void:
	var tile := tile_buttons[slot_index]
	tile.pivot_offset = tile.size / 2.0
	tile.scale = Vector2(0.95, 0.95)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(tile, "scale", Vector2.ONE, 0.16)


func _show_move_message_if_needed() -> void:
	var message := ""
	if move_count == 6:
		message = "You are in control. You can ask your healthcare professional to pause."
	elif move_count == 16:
		message = "Screening doesn't have to take long."
	elif move_count == 30:
		message = "After the sample is collected, it is sent for testing."
	if message.is_empty():
		return
	_show_temporary_message(message)


func _show_temporary_message(message: String) -> void:
	message_revision += 1
	var current_revision := message_revision
	feedback_panel.visible = true
	feedback_label.modulate.a = 1.0
	feedback_label.text = message
	await get_tree().create_timer(4.0).timeout
	if current_revision != message_revision or puzzle_complete:
		return
	var tween := create_tween()
	tween.tween_property(feedback_label, "modulate:a", 0.0, 0.3)
	await tween.finished
	if current_revision == message_revision:
		feedback_label.text = ""
		feedback_panel.visible = false


func _complete_puzzle() -> void:
	puzzle_complete = true
	timer_running = false
	message_revision += 1
	var final_seconds := maxi(1, int(ceil(elapsed_seconds)))
	timer_label.text = "SCREENING TIMER  |  %s" % Game3UI.format_clock(
		final_seconds
	)
	completion_time_label.text = (
		"Your time: %s" % Game3UI.format_duration(final_seconds)
	)
	for tile in tile_buttons:
		tile.disabled = true
	grid.visible = false
	full_image.visible = true
	full_image.modulate.a = 0.0
	control_row.visible = false
	feedback_panel.visible = false
	completion_panel.visible = true
	completion_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(full_image, "modulate:a", 1.0, 0.35)
	tween.tween_property(completion_panel, "modulate:a", 1.0, 0.35)


func _show_two_minute_fact() -> void:
	if puzzle_complete or time_limit_reached:
		return
	time_limit_reached = true
	timer_running = false
	elapsed_seconds = TWO_MINUTE_LIMIT_SECONDS
	timer_label.text = "SCREENING TIMER  |  02:00"
	two_minute_overlay.visible = true
	two_minute_resume_button.disabled = false
	two_minute_continue_button.disabled = false
	two_minute_resume_button.grab_focus()


func _on_two_minute_resume_pressed() -> void:
	if puzzle_complete:
		return
	two_minute_overlay.visible = false
	two_minute_resume_button.disabled = true
	instruction_label.text = "Continue from where you were. The timer is paused."
	finish_after_timeout_button.visible = true


func _on_two_minute_continue_pressed() -> void:
	if puzzle_complete:
		return
	two_minute_continue_button.disabled = true
	two_minute_overlay.visible = false
	puzzle_complete = true
	timer_running = false
	message_revision += 1
	for tile in tile_buttons:
		tile.disabled = true
	call_deferred("_finish_timed_puzzle")


func _finish_timed_puzzle() -> void:
	if not is_inside_tree():
		return
	finished.emit(TWO_MINUTE_LIMIT_SECONDS, move_count)


func _on_completion_continue() -> void:
	var final_seconds := maxi(1, int(ceil(elapsed_seconds)))
	finished.emit(final_seconds, move_count)


func _manhattan_distance(candidate: Array) -> int:
	var total := 0
	for position in candidate.size():
		var tile_value: int = int(candidate[position])
		if tile_value < 0:
			continue
		var target_row: int = tile_value / 3
		var target_column: int = tile_value % 3
		var current_row: int = position / 3
		var current_column: int = position % 3
		total += absi(target_row - current_row)
		total += absi(target_column - current_column)
	return total


func is_board_solvable(candidate: Array) -> bool:
	var inversions := 0
	for first_index in candidate.size():
		if int(candidate[first_index]) < 0:
			continue
		for second_index in range(first_index + 1, candidate.size()):
			if int(candidate[second_index]) < 0:
				continue
			if int(candidate[first_index]) > int(candidate[second_index]):
				inversions += 1
	return inversions % 2 == 0


func get_board_snapshot() -> Array:
	return board.duplicate()


func is_solved() -> bool:
	return board == SOLVED
