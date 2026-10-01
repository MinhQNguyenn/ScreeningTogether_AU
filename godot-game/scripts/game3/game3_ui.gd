class_name Game3UI
extends RefCounted

const LUNA_SPRITE_SHEET := preload(
	"res://assets/sprout_lands/character.png"
)
const HEALTHCARE_PROFESSIONAL_SOURCE := preload(
	"res://assets/game3/luna_doctor.png"
)
const UI_FONT := preload("res://assets/fonts/NotoSans-Variable.ttf")

const INK := Color("#302a2d")
const MUTED := Color("#74676a")
const ROSE := Color("#b45f69")
const ROSE_DARK := Color("#8e4f59")
const BLUSH := Color("#f8e9e9")
const CREAM := Color("#fffaf8")
const WHITE := Color("#ffffff")
const SAGE := Color("#6d9b83")
const SAGE_LIGHT := Color("#e5f0e8")
const GOLD := Color("#d5a653")
const BORDER := Color("#eadedb")


static func make_label(
	text_value: String,
	font_size: int = 24,
	font_color: Color = INK,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT,
	wrap: bool = true,
) -> Label:
	var label := Label.new()
	label.text = text_value
	apply_readable_font(label)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	)
	return label


static func make_button(
	text_value: String,
	primary: bool = false,
	font_size: int = 22,
) -> Button:
	var button := Button.new()
	button.text = text_value
	apply_readable_font(button)
	button.custom_minimum_size = Vector2(0.0, 62.0)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override(
		"font_color", CREAM if primary else INK
	)
	button.add_theme_color_override(
		"font_hover_color", CREAM if primary else ROSE_DARK
	)
	button.add_theme_color_override(
		"font_pressed_color", CREAM if primary else ROSE_DARK
	)
	button.add_theme_color_override(
		"font_focus_color", CREAM if primary else INK
	)
	var normal_color: Color = INK if primary else WHITE
	var hover_color: Color = ROSE_DARK if primary else BLUSH
	button.add_theme_stylebox_override(
		"normal", make_panel_style(normal_color, 18, BORDER, 2)
	)
	button.add_theme_stylebox_override(
		"hover", make_panel_style(hover_color, 18, ROSE, 2)
	)
	button.add_theme_stylebox_override(
		"pressed", make_panel_style(ROSE if primary else BLUSH, 18, ROSE, 2)
	)
	button.add_theme_stylebox_override(
		"focus", make_panel_style(Color.TRANSPARENT, 18, GOLD, 4)
	)
	return button


static func apply_readable_font(control: Control) -> void:
	control.add_theme_font_override("font", UI_FONT)


static func style_selected_button(button: Button) -> void:
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_disabled_color", CREAM)
	button.add_theme_stylebox_override(
		"normal", make_panel_style(ROSE_DARK, 18, GOLD, 3)
	)
	button.add_theme_stylebox_override(
		"disabled", make_panel_style(ROSE_DARK, 18, GOLD, 3)
	)


static func make_luna_portrait_texture() -> ImageTexture:
	# Luna is the white cat in the existing Sprout Lands character sheet.
	# A one-pixel transparent margin makes an 18x18 crop, so the enlarged
	# image divides cleanly into a 3x3 puzzle without inventing new artwork.
	var source_image := LUNA_SPRITE_SHEET.get_image()
	var luna_image := source_image.get_region(Rect2i(15, 15, 18, 18))
	luna_image.resize(720, 720, Image.INTERPOLATE_NEAREST)
	var background := Image.create_empty(720, 720, false, Image.FORMAT_RGBA8)
	background.fill(SAGE_LIGHT)
	background.blend_rect(luna_image, Rect2i(0, 0, 720, 720), Vector2i.ZERO)
	return ImageTexture.create_from_image(background)


static func make_healthcare_professional_texture() -> ImageTexture:
	# The approved doctor is a front-facing Luna frame with a white coat and
	# glasses, prepared at the final 32x48 gameplay resolution.
	var professional_image := HEALTHCARE_PROFESSIONAL_SOURCE.get_image()
	professional_image.convert(Image.FORMAT_RGBA8)
	return ImageTexture.create_from_image(professional_image)


static func make_panel_style(
	color: Color,
	radius: int = 22,
	border_color: Color = Color.TRANSPARENT,
	border_width: int = 0,
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.content_margin_left = 20.0
	style.content_margin_top = 16.0
	style.content_margin_right = 20.0
	style.content_margin_bottom = 16.0
	return style


static func add_margins(
	container: MarginContainer,
	left: int,
	top: int,
	right: int,
	bottom: int,
) -> void:
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_bottom", bottom)


static func make_progress_dots(active_index: int, total: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	for index in total:
		var dot := Label.new()
		apply_readable_font(dot)
		dot.text = "[%d]" % (index + 1) if index == active_index else str(index + 1)
		dot.add_theme_font_size_override("font_size", 22)
		dot.add_theme_color_override(
			"font_color", ROSE if index == active_index else MUTED
		)
		row.add_child(dot)
	return row


static func format_duration(total_seconds: int) -> String:
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	if minutes == 0:
		return "%d second%s" % [seconds, "" if seconds == 1 else "s"]
	return "%d minute%s %d second%s" % [
		minutes,
		"" if minutes == 1 else "s",
		seconds,
		"" if seconds == 1 else "s",
	]


static func format_clock(total_seconds: int) -> String:
	return "%02d:%02d" % [total_seconds / 60, total_seconds % 60]
