extends Node2D

@export_group("NPC Roles")
@export_range(0, 4, 1) var moving_npc_count := 2
@export var walker_centers := PackedVector2Array([
	Vector2(610.0, 330.0),
	Vector2(610.0, 525.0),
])
@export var walker_roam_half_extents := Vector2(215.0, 5.0)
@export_range(10.0, 100.0, 1.0) var min_walker_speed := 34.0
@export_range(10.0, 100.0, 1.0) var max_walker_speed := 43.0


func _ready() -> void:
	queue_redraw()
	_assign_npc_roles()
	_setup_player_name_entry()


func _setup_player_name_entry() -> void:
	var name_popup := get_node_or_null("Canvas/PlayerNamePopup") as PlayerNamePopup
	var announcement_ui := get_node_or_null("Canvas/AnnouncementUI")
	if name_popup == null or announcement_ui == null:
		return

	name_popup.name_submitted.connect(announcement_ui.start_calling)
	name_popup.open()


func _assign_npc_roles() -> void:
	var npc_container := get_node_or_null("NPCs")
	if npc_container == null:
		return

	var npcs := npc_container.get_children()
	npcs.shuffle()
	var walker_count: int = mini(moving_npc_count, npcs.size())

	for index in npcs.size():
		var npc := npcs[index]
		if index < walker_count and not walker_centers.is_empty():
			var center := walker_centers[index % walker_centers.size()]
			npc.configure_full_behaviour(
				center,
				walker_roam_half_extents,
				randf_range(min_walker_speed, max_walker_speed)
			)
		else:
			npc.configure_stationary_behaviour()
