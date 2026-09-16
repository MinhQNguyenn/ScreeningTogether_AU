extends Control

signal finished

const CHARACTER := preload("res://assets/sprout_lands/character.png")
const SCENERY := preload("res://assets/sprout_lands/basic_grass_biome.png")
const DURATION := 6.0
const HORIZON := 76.0
var progress := 0.0
var reduced_motion := false
var completed := false


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	resized.connect(queue_redraw)


func _process(delta: float) -> void:
	if completed:
		return
	if reduced_motion:
		# Keep the scene still until the player continues.
		return
	progress = minf(progress + delta / DURATION, 1.0)
	queue_redraw()
	if progress >= 1.0:
		finish()


func finish() -> void:
	if completed:
		return
	completed = true
	progress = 1.0
	queue_redraw()
	finished.emit()


func luna_rect() -> Rect2:
	# Normalised path position is recomputed at every draw, including resize.
	# Centre the actual 16x16 sprite crop, not its source sheet or old viewport.
	var depth := pow(1.0 - progress, 1.45)
	var side := lerpf(2.0, 30.0, depth)
	var feet_y := lerpf(HORIZON, 224.0, depth)
	return Rect2(160.0 - side / 2.0, feet_y - side, side, side)


func _draw() -> void:
	# A small logical canvas keeps the shapes and existing Sprout Lands sprites
	# in one pixel-art style. The path and character share the same centre.
	var zoom := minf(size.x / 320.0, size.y / 240.0)
	var origin := (size - Vector2(320, 240) * zoom) / 2.0
	draw_rect(Rect2(origin - Vector2(4, 4), Vector2(320, 240) * zoom + Vector2(8, 8)), Color("#263c58"))
	draw_set_transform(origin, 0.0, Vector2.ONE * zoom)
	var sky := [Color("#946682"), Color("#bd7d8c"), Color("#dfa08f"), Color("#efbd98")]
	for band in 4:
		draw_rect(Rect2(0, band * 20, 320, 20), sky[band])
	# Stepped sun and clouds avoid smooth shapes against pixel artwork.
	draw_rect(Rect2(222, 33, 32, 36), Color("#ffe6ad"))
	draw_rect(Rect2(216, 40, 44, 22), Color("#ffe6ad"))
	for cloud in [Rect2(29, 27, 49, 4), Rect2(38, 23, 24, 4), Rect2(112, 42, 38, 4)]:
		draw_rect(cloud, Color("#edc2b0"))
	draw_rect(Rect2(0, HORIZON, 320, 164), Color("#8fa681"))
	# Distant stepped hedges leave a clear opening at the path's vanishing point.
	for ridge in [Rect2(0, 65, 48, 15), Rect2(34, 60, 44, 20), Rect2(70, 69, 66, 11), Rect2(190, 67, 70, 13), Rect2(248, 62, 72, 18)]:
		draw_rect(ridge, Color("#737f78"))
	for row in 4:
		var y := 92.0 + row * 40.0
		for column in 8:
			var x := 12.0 + column * 43.0 + (8 if row % 2 else 0)
			if absf(x - 160) > 36 + row * 9:
				draw_rect(Rect2(x, y, 3, 2), Color("#a7b68c"))
	var edge := PackedVector2Array([Vector2(156, HORIZON), Vector2(164, HORIZON), Vector2(221, 240), Vector2(99, 240)])
	var path := PackedVector2Array([Vector2(158, HORIZON), Vector2(162, HORIZON), Vector2(214, 240), Vector2(106, 240)])
	draw_colored_polygon(edge, Color("#ac896b"))
	draw_colored_polygon(path, Color("#e0bf94"))
	for mark in 5:
		var y := 105.0 + mark * 28
		draw_rect(Rect2(153 + (mark % 2) * 9, y, 3 + mark, 2), Color("#c7a780"))
	# Correct whole-tree regions from the same atlas used by the other games.
	for tree in [Rect2(72, 77, 26, 26), Rect2(232, 78, 26, 26), Rect2(33, 111, 43, 43), Rect2(248, 121, 43, 43), Rect2(0, 173, 64, 64), Rect2(265, 179, 64, 64)]:
		draw_texture_rect_region(SCENERY, tree, Rect2(16, 0, 32, 32), Color("#f3dac4"))
	for flower in [Vector2(94, 150), Vector2(225, 183), Vector2(71, 211), Vector2(242, 105)]:
		draw_texture_rect_region(SCENERY, Rect2(flower, Vector2(12, 12)), Rect2(96, 48, 16, 16), Color("#ffe3d2"))
	if progress < 1.0:
		var rect := luna_rect()
		var frame := 0 if reduced_motion else int(progress * DURATION * 7) % 4
		var opacity := 1.0 - smoothstep(0.86, 1.0, progress)
		draw_texture_rect_region(CHARACTER, rect, Rect2(16 + frame * 48, 64, 16, 16), Color(1, 1, 1, opacity))
