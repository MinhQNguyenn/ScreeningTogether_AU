class_name OfficeEntrance
extends Control

signal arrived

const CHARACTER_TEXTURE := preload(
	"res://assets/sprout_lands/character.png"
)
const ARMCHAIR_TEXTURE := preload(
	"res://assets/topdown_hospital/room_armchair.png"
)
const BEDSIDE_TABLE_TEXTURE := preload(
	"res://assets/topdown_hospital/room_bedside_table.png"
)
const CARPET_TEXTURE := preload(
	"res://assets/topdown_hospital/maternity_carpet.png"
)
const MATERNITY_BALL_TEXTURE := preload(
	"res://assets/topdown_hospital/maternity_ball.png"
)
const MATERNITY_BED_TEXTURE := preload(
	"res://assets/topdown_hospital/maternity_bed.png"
)
const MATERNITY_LIGHT_TEXTURE := preload(
	"res://assets/topdown_hospital/maternity_light.png"
)
const FLOWER_TEXTURE := preload(
	"res://assets/topdown_hospital/room_flower.png"
)
const HAND_SANITIZER_TEXTURE := preload(
	"res://assets/topdown_hospital/room_hand_sanitizer.png"
)
const TABLE_TEXTURE := preload(
	"res://assets/topdown_hospital/maternity_table.png"
)
const WORK_CABINET_TEXTURE := preload(
	"res://assets/topdown_hospital/maternity_work_cabinet.png"
)
const FLOOR_COLUMNS := 7
const FLOOR_ROWS := 4
const FLOOR_TILE_SIZE := 72.0
const BACK_WALL_HEIGHT := 78.0
const FRONT_WALL_HEIGHT := 58.0

var luna: AnimatedSprite2D
var healthcare_professional: TextureRect
var walk_tween: Tween
var has_arrived := false
var walk_started := false
var walk_restart_pending := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	resized.connect(_on_resized)
	_create_healthcare_professional()
	_create_luna()
	call_deferred("_start_walk")


func _draw() -> void:
	var room_rect := _get_room_rect()
	var floor_area := _get_floor_area()
	_draw_room(room_rect, floor_area)
	_draw_hospital_furniture(floor_area)


func _draw_room(
	room_rect: Rect2,
	floor_area: Rect2,
) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#f5dfdc"))
	draw_rect(room_rect.grow(9.0), Color("#263c58"))
	draw_rect(
		Rect2(
			room_rect.position,
			Vector2(room_rect.size.x, BACK_WALL_HEIGHT),
		),
		Color("#eda7b3"),
	)
	draw_rect(floor_area, Color("#c8d5e5"))
	draw_rect(
		Rect2(
			floor_area.end.x - floor_area.size.x,
			floor_area.end.y,
			room_rect.size.x,
			FRONT_WALL_HEIGHT,
		),
		Color("#eda7b3"),
	)
	_draw_wall_pattern(
		room_rect.position.x,
		room_rect.position.y,
		room_rect.size.x,
		BACK_WALL_HEIGHT,
	)
	_draw_wall_pattern(
		room_rect.position.x,
		floor_area.end.y,
		room_rect.size.x,
		FRONT_WALL_HEIGHT,
	)
	_draw_floor_tiles(floor_area)
	_draw_wall_trim(
		room_rect.position.x,
		room_rect.position.y + BACK_WALL_HEIGHT - 26.0,
		room_rect.size.x,
	)
	_draw_wall_trim(
		room_rect.position.x,
		floor_area.end.y,
		room_rect.size.x,
	)
	_draw_doorway(room_rect, floor_area.end.y)


func _draw_wall_pattern(
	wall_x: float,
	wall_y: float,
	wall_width: float,
	wall_height: float,
) -> void:
	var pattern_color := Color("#b95486")
	for row_y in range(
		floori(wall_y + 16.0),
		floori(wall_y + wall_height - 12.0),
		34,
	):
		for motif_index in range(floori(wall_width / 96.0)):
			var start_x := wall_x + 6.0 + motif_index * 96.0
			var motif := PackedVector2Array(
				[
					Vector2(start_x, row_y),
					Vector2(start_x + 20.0, row_y),
					Vector2(start_x + 20.0, row_y + 9.0),
					Vector2(start_x + 42.0, row_y + 9.0),
					Vector2(start_x + 42.0, row_y),
					Vector2(start_x + 66.0, row_y),
					Vector2(start_x + 66.0, row_y + 9.0),
					Vector2(start_x + 88.0, row_y + 9.0),
				]
			)
			draw_polyline(motif, pattern_color, 7.0)


func _draw_wall_trim(
	trim_x: float,
	trim_y: float,
	trim_width: float,
) -> void:
	draw_rect(Rect2(trim_x, trim_y, trim_width, 9.0), Color("#388c8d"))
	draw_rect(
		Rect2(trim_x, trim_y + 9.0, trim_width, 8.0),
		Color("#ef6979"),
	)
	draw_rect(
		Rect2(trim_x, trim_y + 17.0, trim_width, 9.0),
		Color("#388c8d"),
	)


func _draw_floor_tiles(floor_area: Rect2) -> void:
	for tile_x in range(1, FLOOR_COLUMNS):
		var line_x := floor_area.position.x + tile_x * FLOOR_TILE_SIZE
		draw_line(
			Vector2(line_x, floor_area.position.y),
			Vector2(line_x, floor_area.end.y),
			Color("#8fa5bf"),
			4.0,
		)
	for tile_y in range(1, FLOOR_ROWS):
		var line_y := floor_area.position.y + tile_y * FLOOR_TILE_SIZE
		draw_line(
			Vector2(floor_area.position.x, line_y),
			Vector2(floor_area.end.x, line_y),
			Color("#8fa5bf"),
			4.0,
		)


func _draw_doorway(room_rect: Rect2, front_wall_y: float) -> void:
	var door_width := 82.0
	var doorway := Rect2(
		room_rect.get_center().x - door_width * 0.5,
		front_wall_y - 5.0,
		door_width,
		room_rect.end.y - front_wall_y + 5.0,
	)
	draw_rect(doorway.grow(8.0), Color("#263c58"))
	draw_rect(doorway, Color("#f2aab5"))
	draw_rect(
		Rect2(doorway.position + Vector2(18.0, 22.0), Vector2(40.0, 32.0)),
		Color("#b9dce1"),
	)
	draw_rect(
		Rect2(doorway.end.x - 23.0, doorway.position.y + 50.0, 10.0, 7.0),
		Color("#263c58"),
	)


func _draw_hospital_furniture(floor_area: Rect2) -> void:
	# This arrangement follows the supplied pack's example consultation room.
	_draw_asset(
		MATERNITY_LIGHT_TEXTURE,
		Rect2(floor_area.position + Vector2(18.0, 12.0), Vector2(56.0, 102.0)),
	)
	_draw_asset(
		MATERNITY_BED_TEXTURE,
		Rect2(floor_area.position + Vector2(190.0, 10.0), Vector2(84.0, 110.0)),
	)
	_draw_asset(
		WORK_CABINET_TEXTURE,
		Rect2(floor_area.end.x - 60.0, floor_area.position.y + 96.0, 52.0, 104.0),
	)
	_draw_asset(
		HAND_SANITIZER_TEXTURE,
		Rect2(floor_area.end.x - 53.0, floor_area.position.y + 66.0, 30.0, 30.0),
	)
	_draw_waiting_corner(floor_area)
	_draw_centre_details(floor_area)


func _draw_waiting_corner(floor_area: Rect2) -> void:
	_draw_asset(
		ARMCHAIR_TEXTURE,
		Rect2(floor_area.position + Vector2(8.0, 122.0), Vector2(46.0, 92.0)),
	)
	_draw_asset(
		TABLE_TEXTURE,
		Rect2(floor_area.position + Vector2(10.0, 216.0), Vector2(60.0, 40.0)),
	)
	_draw_asset(
		BEDSIDE_TABLE_TEXTURE,
		Rect2(floor_area.position + Vector2(56.0, 152.0), Vector2(52.0, 52.0)),
	)
	_draw_asset(
		FLOWER_TEXTURE,
		Rect2(floor_area.position + Vector2(60.0, 124.0), Vector2(34.0, 34.0)),
	)


func _draw_centre_details(floor_area: Rect2) -> void:
	_draw_asset(
		CARPET_TEXTURE,
		Rect2(floor_area.position + Vector2(116.0, 196.0), Vector2(150.0, 60.0)),
	)
	_draw_asset(
		MATERNITY_BALL_TEXTURE,
		Rect2(floor_area.position + Vector2(286.0, 200.0), Vector2(48.0, 44.0)),
	)


func _get_room_rect() -> Rect2:
	var room_size := Vector2(
		FLOOR_COLUMNS * FLOOR_TILE_SIZE,
		BACK_WALL_HEIGHT
		+ FLOOR_ROWS * FLOOR_TILE_SIZE
		+ FRONT_WALL_HEIGHT,
	)
	return Rect2((size - room_size) * 0.5, room_size)


func _get_floor_area() -> Rect2:
	var room_rect := _get_room_rect()
	return Rect2(
		room_rect.position + Vector2(0.0, BACK_WALL_HEIGHT),
		Vector2(
			FLOOR_COLUMNS * FLOOR_TILE_SIZE,
			FLOOR_ROWS * FLOOR_TILE_SIZE,
		),
	)


func _draw_asset(texture: Texture2D, destination: Rect2) -> void:
	draw_texture_rect(texture, destination, false)


func _create_healthcare_professional() -> void:
	healthcare_professional = TextureRect.new()
	healthcare_professional.texture = (
		Game3UI.make_healthcare_professional_texture()
	)
	healthcare_professional.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	healthcare_professional.stretch_mode = (
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	)
	healthcare_professional.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)
	healthcare_professional.mouse_filter = Control.MOUSE_FILTER_IGNORE
	healthcare_professional.z_index = 2
	add_child(healthcare_professional)
	_position_healthcare_professional()


func _create_luna() -> void:
	luna = AnimatedSprite2D.new()
	luna.sprite_frames = _make_luna_frames()
	luna.animation = "walk_right"
	luna.scale = Vector2(5.5, 5.5)
	luna.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	luna.z_index = 3
	add_child(luna)


func _make_luna_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation("walk_right")
	frames.set_animation_speed("walk_right", 7.0)
	frames.set_animation_loop("walk_right", true)
	for frame_x in [16.0, 64.0, 112.0, 160.0]:
		frames.add_frame(
			"walk_right",
			_make_luna_atlas_frame(frame_x, 160.0),
		)
	frames.add_animation("front")
	frames.add_frame("front", _make_luna_atlas_frame(16.0, 16.0))
	return frames


func _make_luna_atlas_frame(
	frame_x: float,
	frame_y: float,
) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = CHARACTER_TEXTURE
	frame.region = Rect2(frame_x, frame_y, 16.0, 16.0)
	return frame


func _on_resized() -> void:
	queue_redraw()
	_position_healthcare_professional()
	_reposition_luna_after_resize()


func _reposition_luna_after_resize() -> void:
	if not is_instance_valid(luna):
		return
	var sprite_half_height := 8.0 * luna.scale.y
	var foot_path := get_luna_entry_path()
	if has_arrived:
		luna.position = foot_path[-1] - Vector2(0.0, sprite_half_height)
		return
	if walk_started and not walk_restart_pending:
		walk_restart_pending = true
		call_deferred("_restart_walk_after_resize")
	else:
		luna.position = foot_path[0] - Vector2(0.0, sprite_half_height)


func _restart_walk_after_resize() -> void:
	walk_restart_pending = false
	if walk_started and not has_arrived:
		_start_walk()


func _position_healthcare_professional() -> void:
	if not is_instance_valid(healthcare_professional):
		return
	var doctor_size := Vector2(88.0, 88.0)
	var floor_area := _get_floor_area()
	healthcare_professional.size = doctor_size
	healthcare_professional.position = Vector2(
		floor_area.position.x + 338.0,
		floor_area.position.y + 108.0,
	)


func get_luna_entry_path() -> PackedVector2Array:
	var room_rect := _get_room_rect()
	var floor_area := _get_floor_area()
	return PackedVector2Array(
		[
			Vector2(room_rect.get_center().x, room_rect.end.y - 12.0),
			Vector2(room_rect.get_center().x, floor_area.end.y - 22.0),
			Vector2(floor_area.position.x + 272.0, floor_area.end.y - 92.0),
		]
	)


func _start_walk() -> void:
	if has_arrived:
		return
	walk_started = true
	if is_instance_valid(walk_tween):
		walk_tween.kill()
	var sprite_half_height := 8.0 * luna.scale.y
	var foot_path := get_luna_entry_path()
	luna.position = foot_path[0] - Vector2(0.0, sprite_half_height)
	luna.animation = "walk_right"
	luna.play()
	var active_tween := create_tween()
	walk_tween = active_tween
	active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for point_index in range(1, foot_path.size()):
		var destination := (
			foot_path[point_index]
			- Vector2(0.0, sprite_half_height)
		)
		active_tween.tween_property(luna, "position", destination, 0.85)
	await active_tween.finished
	if active_tween != walk_tween:
		return
	walk_tween = null
	has_arrived = true
	luna.stop()
	luna.animation = "front"
	luna.frame = 0
	arrived.emit()
