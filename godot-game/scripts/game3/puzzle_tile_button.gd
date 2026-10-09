class_name PuzzleTileButton
extends BaseButton

var slot_index: int = -1
var tile_index: int = -1
var source_texture: Texture2D


func _ready() -> void:
	custom_minimum_size = Vector2(164.0, 164.0)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	resized.connect(queue_redraw)


func configure(
	new_slot_index: int,
	new_tile_index: int,
	new_source_texture: Texture2D,
) -> void:
	slot_index = new_slot_index
	source_texture = new_source_texture
	set_tile(new_tile_index)


func set_tile(new_tile_index: int) -> void:
	tile_index = new_tile_index
	disabled = tile_index < 0
	GameLanguage.bind_text(self, "Empty space" if tile_index < 0 else "Move Luna puzzle piece %d", [] if tile_index < 0 else [tile_index + 1], "tooltip_text")
	queue_redraw()


func _draw() -> void:
	var background_color := Color("#f2e7e3")
	if tile_index >= 0:
		background_color = (
			Color("#fff4f1") if is_hovered() else Color("#ffffff")
		)
	var border_color := (
		Game3UI.GOLD if has_focus() else Game3UI.BORDER
	)
	var border_width := 4 if has_focus() else 2
	var style := Game3UI.make_panel_style(
		background_color, 13, border_color, border_width
	)
	draw_style_box(style, Rect2(Vector2.ZERO, size))
	if tile_index < 0 or source_texture == null:
		draw_circle(size / 2.0, 7.0, Color("#d6c7c4"))
		return

	var source_size := source_texture.get_size()
	var source_tile_size := source_size / 3.0
	var source_column: int = tile_index % 3
	var source_row: int = tile_index / 3
	var source_rect := Rect2(
		Vector2(source_column, source_row) * source_tile_size,
		source_tile_size,
	)
	var destination := Rect2(Vector2(5.0, 5.0), size - Vector2(10.0, 10.0))
	draw_texture_rect_region(
		source_texture,
		destination,
		source_rect,
		Color.WHITE,
		false,
		true,
	)
