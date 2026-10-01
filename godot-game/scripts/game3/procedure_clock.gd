extends Control

var seconds := 0.0
var reduced_motion := false


func _draw() -> void:
	var centre := size / 2.0
	var radius := minf(size.x, size.y) / 2.0 - 12.0
	draw_circle(centre, radius, Game3UI.CREAM)
	draw_arc(centre, radius, 0, TAU, 96, Color("#263c58"), 7, true)
	for tick in 12:
		var direction := Vector2.from_angle(tick * TAU / 12.0 - PI / 2)
		draw_line(centre + direction * (radius - 22), centre + direction * (radius - 9), Game3UI.INK, 5, true)
	# Reduced motion retains a static clock and the numeric elapsed time.
	var angle := -PI / 2 if reduced_motion else seconds / 60.0 * TAU - PI / 2
	draw_line(centre, centre + Vector2.from_angle(angle) * (radius - 35), Game3UI.ROSE_DARK, 7, true)
	var short_angle := -PI / 2 if reduced_motion else -PI / 2 + seconds / 3600.0 * TAU
	draw_line(centre, centre + Vector2.from_angle(short_angle) * radius * 0.48, Game3UI.INK, 9, true)
	draw_circle(centre, 9, Game3UI.GOLD)
