class_name TrackSegment
extends Node2D

# one reusable chunk of the track

const SEGMENT_HEIGHT := 640.0
const TRACK_HALF_WIDTH := 240.0
const SCENERY_TEXTURE := preload("res://assets/sprout_lands/grass_scenery.png")


func _ready() -> void:
	# draw the track and add the plants when this piece loads
	queue_redraw()
	_add_scenery()


func _draw() -> void:
	# draw grass, the dirt path and lane lines
	var segment_top: float = -SEGMENT_HEIGHT / 2.0
	var segment_bottom: float = SEGMENT_HEIGHT / 2.0
	var grass_rect: Rect2 = Rect2(
		-520.0,
		segment_top,
		1040.0,
		SEGMENT_HEIGHT,
	)
	var path_rect: Rect2 = Rect2(
		-TRACK_HALF_WIDTH,
		segment_top,
		TRACK_HALF_WIDTH * 2.0,
		SEGMENT_HEIGHT,
	)
	draw_rect(grass_rect, Color("#74a84f"))
	draw_rect(path_rect, Color("#d8c783"))
	draw_line(
		Vector2(-TRACK_HALF_WIDTH, segment_top),
		Vector2(-TRACK_HALF_WIDTH, segment_bottom),
		Color("#537d43"),
		10.0,
	)
	draw_line(
		Vector2(TRACK_HALF_WIDTH, segment_top),
		Vector2(TRACK_HALF_WIDTH, segment_bottom),
		Color("#537d43"),
		10.0,
	)
	for lane_edge in [-72.0, 72.0]:
		for y in range(-300, 321, 80):
			draw_line(
				Vector2(lane_edge, y),
				Vector2(lane_edge, y + 34),
				Color(1.0, 0.96, 0.76, 0.65),
				5.0,
			)


func _add_scenery() -> void:
	# random plants on both sides so every piece isnt exactly the same
	for side in [-1.0, 1.0]:
		for y in [-230.0, 40.0, 250.0]:
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = SCENERY_TEXTURE
			atlas.region = Rect2(0.0, 0.0, 48.0, 48.0)
			var sprite: Sprite2D = Sprite2D.new()
			sprite.texture = atlas
			var scenery_x: float = (
				float(side) * (300.0 + randf_range(-18.0, 30.0))
			)
			var scenery_y: float = float(y) + randf_range(-24.0, 24.0)
			sprite.position = Vector2(scenery_x, scenery_y)
			sprite.scale = Vector2(2.0, 2.0)
			sprite.flip_h = side > 0.0
			sprite.z_index = 1
			add_child(sprite)
