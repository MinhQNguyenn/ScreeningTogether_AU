class_name SunsetPathScene
extends Control

const GRASS_TEXTURE := preload(
	"res://assets/sprout_lands/grass_tileset.png"
)
const PATH_TEXTURE := preload(
	"res://assets/sprout_lands/paths.png"
)
const SCENERY_TEXTURE := preload(
	"res://assets/sprout_lands/basic_grass_biome.png"
)
const FENCE_TEXTURE := preload(
	"res://assets/sprout_lands/fences.png"
)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	resized.connect(queue_redraw)


func _draw() -> void:
	_draw_grass_map()
	_draw_sunset_horizon()
	_draw_game_path()
	_draw_map_scenery()
	draw_rect(
		Rect2(Vector2.ZERO, size),
		Color(0.93, 0.38, 0.34, 0.13),
	)


func _draw_sunset_horizon() -> void:
	var horizon_height := size.y * 0.25
	draw_rect(
		Rect2(0.0, 0.0, size.x, horizon_height),
		Color("#ad6171"),
	)
	draw_rect(
		Rect2(0.0, horizon_height * 0.24, size.x, horizon_height * 0.76),
		Color("#d97872"),
	)
	draw_rect(
		Rect2(0.0, horizon_height * 0.48, size.x, horizon_height * 0.52),
		Color("#efa06f"),
	)
	draw_rect(
		Rect2(0.0, horizon_height * 0.76, size.x, horizon_height * 0.24),
		Color("#f5c477"),
	)
	_draw_sunset_clouds(horizon_height)
	# Keep the sun beside the path so Luna disappears at the horizon, not in it.
	var sun_position := Vector2(size.x * 0.72, horizon_height * 0.59)
	draw_circle(sun_position, 74.0, Color(1.0, 0.77, 0.32, 0.13))
	draw_circle(sun_position, 54.0, Color(1.0, 0.84, 0.40, 0.22))
	draw_circle(sun_position, 36.0, Color("#ffe49a"))
	_draw_horizon_silhouette(horizon_height)
	draw_line(
		Vector2(0.0, horizon_height),
		Vector2(size.x, horizon_height),
		Color("#8f5758"),
		7.0,
	)


func _draw_sunset_clouds(horizon_height: float) -> void:
	var cloud_color := Color(1.0, 0.78, 0.69, 0.42)
	draw_rect(
		Rect2(size.x * 0.07, horizon_height * 0.28, 116.0, 12.0),
		cloud_color,
	)
	draw_rect(
		Rect2(size.x * 0.14, horizon_height * 0.20, 72.0, 12.0),
		cloud_color,
	)
	draw_rect(
		Rect2(size.x * 0.72, horizon_height * 0.35, 126.0, 12.0),
		cloud_color,
	)


func _draw_horizon_silhouette(horizon_height: float) -> void:
	var silhouette := PackedVector2Array(
		[
			Vector2(0.0, horizon_height),
			Vector2(0.0, horizon_height * 0.86),
			Vector2(size.x * 0.13, horizon_height * 0.69),
			Vector2(size.x * 0.25, horizon_height * 0.87),
			Vector2(size.x * 0.36, horizon_height * 0.75),
			Vector2(size.x * 0.50, horizon_height * 0.91),
			Vector2(size.x * 0.66, horizon_height * 0.74),
			Vector2(size.x * 0.81, horizon_height * 0.88),
			Vector2(size.x, horizon_height * 0.70),
			Vector2(size.x, horizon_height),
		]
	)
	draw_colored_polygon(silhouette, Color("#78535c"))


func _draw_grass_map() -> void:
	var tile_size := 64.0
	for tile_y in range(0, ceili(size.y / tile_size)):
		for tile_x in range(0, ceili(size.x / tile_size)):
			var source_column := float((tile_x + tile_y) % 3)
			draw_texture_rect_region(
				GRASS_TEXTURE,
				Rect2(
					tile_x * tile_size,
					tile_y * tile_size,
					tile_size,
					tile_size,
				),
				Rect2(source_column * 16.0, 80.0, 16.0, 16.0),
			)


func _draw_game_path() -> void:
	var centre_x := size.x * 0.5
	var top_y := size.y * 0.2275
	var bottom_y := size.y + 12.0
	var border_shape := _make_path_shape(
		centre_x,
		top_y,
		bottom_y,
		35.0,
		70.0,
	)
	var path_shape := _make_path_shape(
		centre_x,
		top_y,
		bottom_y,
		27.0,
		58.0,
	)
	draw_colored_polygon(border_shape, Color("#9f6453"))
	draw_colored_polygon(path_shape, Color("#d99a70"))
	_draw_path_edge_details(centre_x, top_y, bottom_y)

	# Small track marks come from the Sprout Lands path sheet.
	for mark_index in 6:
		var mark_y := top_y + 70.0 + mark_index * (bottom_y - top_y) / 7.0
		var mark_x := centre_x + (-15.0 if mark_index % 2 == 0 else 12.0)
		draw_texture_rect_region(
			PATH_TEXTURE,
			Rect2(mark_x - 20.0, mark_y - 20.0, 40.0, 40.0),
			Rect2(0.0, 0.0, 16.0, 16.0),
		)


func _make_path_shape(
	centre_x: float,
	top_y: float,
	bottom_y: float,
	top_half_width: float,
	bottom_half_width: float,
) -> PackedVector2Array:
	var width_38 := lerpf(top_half_width, bottom_half_width, 0.20)
	var width_52 := lerpf(top_half_width, bottom_half_width, 0.41)
	var width_67 := lerpf(top_half_width, bottom_half_width, 0.63)
	var width_82 := lerpf(top_half_width, bottom_half_width, 0.84)
	var horizon_y := size.y * 0.25
	return PackedVector2Array(
		[
			Vector2(centre_x - 7.0, top_y),
			Vector2(centre_x - top_half_width, horizon_y),
			Vector2(centre_x - width_38 - 2.0, size.y * 0.38),
			Vector2(centre_x - width_52 + 3.0, size.y * 0.52),
			Vector2(centre_x - width_67 - 4.0, size.y * 0.67),
			Vector2(centre_x - width_82 + 2.0, size.y * 0.82),
			Vector2(centre_x - bottom_half_width, bottom_y),
			Vector2(centre_x + bottom_half_width, bottom_y),
			Vector2(centre_x + width_82 - 2.0, size.y * 0.82),
			Vector2(centre_x + width_67 + 4.0, size.y * 0.67),
			Vector2(centre_x + width_52 - 3.0, size.y * 0.52),
			Vector2(centre_x + width_38 + 2.0, size.y * 0.38),
			Vector2(centre_x + top_half_width, horizon_y),
			Vector2(centre_x + 7.0, top_y),
		]
	)


func _draw_path_edge_details(
	centre_x: float,
	top_y: float,
	bottom_y: float,
) -> void:
	for detail_index in 9:
		var detail_y := top_y + detail_index * (bottom_y - top_y) / 8.0
		var progress := float(detail_index) / 8.0
		var offset := lerpf(31.0, 64.0, progress)
		draw_rect(
			Rect2(centre_x - offset - 3.0, detail_y, 7.0, 18.0),
			Color("#b9785d"),
		)
		draw_rect(
			Rect2(centre_x + offset - 3.0, detail_y + 13.0, 7.0, 18.0),
			Color("#b9785d"),
		)


func _draw_map_scenery() -> void:
	# Fence runs sit behind complete trees so the borders remain orderly.
	_draw_hedges_and_fences()
	_draw_tree_groves()
	_draw_flower_and_rock_clusters()

func _draw_tree_groves() -> void:
	var tree_source := Rect2(16.0, 0.0, 32.0, 32.0)
	var flowering_tree_source := Rect2(48.0, 0.0, 32.0, 32.0)
	var tree_size := Vector2(104.0, 104.0)
	var tree_positions := [
		Vector2(size.x * 0.14, size.y * 0.28),
		Vector2(size.x * 0.69, size.y * 0.30),
		Vector2(size.x * 0.13, size.y * 0.45),
		Vector2(size.x * 0.70, size.y * 0.47),
		Vector2(size.x * 0.14, size.y * 0.63),
		Vector2(size.x * 0.69, size.y * 0.65),
		Vector2(size.x * 0.13, size.y - 112.0),
		Vector2(size.x * 0.70, size.y - 112.0),
	]
	for tree_index in tree_positions.size():
		_draw_scenery(
			flowering_tree_source if tree_index % 3 == 1 else tree_source,
			Rect2(tree_positions[tree_index], tree_size),
		)


func _draw_hedges_and_fences() -> void:
	_draw_fence_run(Vector2(size.x * 0.12, size.y * 0.55))
	_draw_fence_run(Vector2(size.x * 0.66, size.y * 0.72))


func _draw_flower_and_rock_clusters() -> void:
	var pink_flower := Rect2(96.0, 48.0, 16.0, 16.0)
	var purple_flower := Rect2(112.0, 48.0, 16.0, 16.0)
	var flower_positions := [
		Vector2(size.x * 0.31, size.y * 0.35),
		Vector2(size.x * 0.64, size.y * 0.41),
		Vector2(size.x * 0.30, size.y * 0.74),
		Vector2(size.x * 0.64, size.y * 0.84),
	]
	for flower_index in flower_positions.size():
		_draw_scenery(
			pink_flower if flower_index % 2 == 0 else purple_flower,
			Rect2(flower_positions[flower_index], Vector2(32.0, 32.0)),
		)

	var rock_source := Rect2(112.0, 16.0, 32.0, 16.0)
	for rock_position in [
		Vector2(size.x * 0.18, size.y * 0.37),
		Vector2(size.x * 0.68, size.y * 0.58),
	]:
		_draw_scenery(
			rock_source,
			Rect2(rock_position, Vector2(70.0, 35.0)),
		)


func _draw_fence_run(position: Vector2) -> void:
	draw_texture_rect_region(
		FENCE_TEXTURE,
		Rect2(position, Vector2(142.0, 36.0)),
		Rect2(0.0, 0.0, 64.0, 16.0),
	)


func _draw_scenery(source: Rect2, destination: Rect2) -> void:
	draw_texture_rect_region(
		SCENERY_TEXTURE,
		destination,
		source,
	)


func get_walking_path() -> PackedVector2Array:
	return PackedVector2Array(
		[
			Vector2(size.x * 0.50, size.y * 0.92),
			Vector2(size.x * 0.50, size.y * 0.70),
			Vector2(size.x * 0.50, size.y * 0.47),
			Vector2(size.x * 0.50, size.y * 0.25),
		]
	)
