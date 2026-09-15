extends CharacterBody2D

signal action_changed(action_name: StringName)

@export_enum("Random", "NPC 1", "NPC 2", "NPC 3", "NPC 4")
var model_selection := 0

@export_group("Behaviour")
@export var movement_enabled := true
@export_range(10.0, 200.0, 1.0) var move_speed := 38.0
@export_range(20.0, 500.0, 1.0) var movement_acceleration := 130.0
@export var roam_half_extents := Vector2(65.0, 30.0)
@export_range(10.0, 200.0, 1.0) var min_walk_distance := 36.0
@export_range(0.0, 1.0, 0.05) var walk_chance := 0.7
@export_range(0.0, 1.0, 0.05) var distraction_chance := 0.45

@export_group("Timing")
@export_range(0.5, 20.0, 0.1) var min_idle_time := 2.0
@export_range(0.5, 20.0, 0.1) var max_idle_time := 5.0
@export_range(0.5, 20.0, 0.1) var min_action_time := 3.0
@export_range(0.5, 20.0, 0.1) var max_action_time := 6.0

const NPC_MODELS := [
	preload("res://resources/npcs/npc1_frames.tres"),
	preload("res://resources/npcs/npc2_frames.tres"),
	preload("res://resources/npcs/npc3_frames.tres"),
	preload("res://resources/npcs/npc4_frames.tres"),
]

enum NpcState {
	IDLE,
	WALKING,
	DISTRACTED,
}

var active_model_index := -1
var behaviour_role: StringName = &"full"
var _state := NpcState.IDLE
var _home_position := Vector2.ZERO
var _target_position := Vector2.ZERO
var _facing: StringName = &"down"
var _current_action: StringName = &"idle"
var _blocked_time := 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var action_timer: Timer = $ActionTimer


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	select_model()
	_home_position = position
	action_timer.timeout.connect(_on_action_timer_timeout)
	_start_idle()


func select_model() -> void:
	active_model_index = model_selection - 1
	if model_selection == 0:
		active_model_index = randi_range(0, NPC_MODELS.size() - 1)

	animated_sprite.sprite_frames = NPC_MODELS[active_model_index]


func configure_stationary_behaviour() -> void:
	behaviour_role = &"stationary"
	movement_enabled = false
	_home_position = position
	_start_random_stationary_action(false)


func configure_full_behaviour(
	walk_center: Vector2,
	walk_extents: Vector2,
	walking_speed: float
) -> void:
	behaviour_role = &"full"
	movement_enabled = true
	position = walk_center
	_home_position = walk_center
	roam_half_extents = walk_extents
	move_speed = walking_speed
	min_walk_distance = 90.0
	_start_idle()


func _physics_process(delta: float) -> void:
	if _state != NpcState.WALKING:
		return

	var distance_to_target := position.distance_to(_target_position)
	if distance_to_target <= 1.5:
		velocity = Vector2.ZERO
		set_physics_process(false)
		_on_walk_finished()
		return

	var direction := position.direction_to(_target_position)
	var desired_speed := move_speed
	if distance_to_target < 24.0:
		desired_speed = lerpf(8.0, move_speed, distance_to_target / 24.0)
	var desired_velocity := direction * desired_speed
	velocity = velocity.move_toward(
		desired_velocity, movement_acceleration * delta
	)
	_update_facing(direction)
	_play_directional_animation(&"walk")

	var position_before_move := position
	move_and_slide()
	var moved_distance := position.distance_to(position_before_move)
	if get_slide_collision_count() > 0 and moved_distance < move_speed * delta * 0.2:
		_blocked_time += delta
	else:
		_blocked_time = 0.0

	if _blocked_time >= 0.35:
		_blocked_time = 0.0
		if not _choose_walk_target():
			_start_idle()


func _on_action_timer_timeout() -> void:
	if not movement_enabled:
		_start_random_stationary_action()
		return

	match _state:
		NpcState.IDLE:
			if randf() < walk_chance:
				_start_walk()
			else:
				_start_distraction()
		NpcState.DISTRACTED:
			_start_idle()


func _start_idle() -> void:
	_state = NpcState.IDLE
	_current_action = &"idle"
	velocity = Vector2.ZERO
	set_physics_process(false)
	_play_directional_animation(&"idle")
	_start_timer(min_idle_time, max_idle_time)
	action_changed.emit(&"idle")


func _start_walk() -> void:
	if not _choose_walk_target():
		_start_idle()
		return

	action_timer.stop()
	_state = NpcState.WALKING
	_blocked_time = 0.0
	var direction := position.direction_to(_target_position)
	_update_facing(direction)
	_play_directional_animation(&"walk")
	set_physics_process(true)
	action_changed.emit(&"walk")


func _choose_walk_target() -> bool:
	for attempt in 8:
		var offset := Vector2(
			randf_range(-roam_half_extents.x, roam_half_extents.x),
			randf_range(-roam_half_extents.y, roam_half_extents.y)
		)
		var candidate := _home_position + offset
		if position.distance_to(candidate) >= min_walk_distance:
			_target_position = candidate
			return true
	return false


func _on_walk_finished() -> void:
	if randf() < distraction_chance:
		_start_distraction()
	else:
		_start_idle()


func _start_distraction(forced_action: StringName = &"") -> void:
	_state = NpcState.DISTRACTED
	velocity = Vector2.ZERO
	set_physics_process(false)
	_facing = &"down"
	var action := forced_action
	if action.is_empty():
		action = &"phone" if randf() < 0.5 else &"read"
	_current_action = action
	_play_animation(StringName("%s_down" % action))
	_start_timer(min_action_time, max_action_time)
	action_changed.emit(action)


func _start_random_stationary_action(avoid_repeat := true) -> void:
	var actions: Array[StringName] = [&"idle", &"phone", &"read"]
	if avoid_repeat:
		actions.erase(_current_action)
	var next_action: StringName = actions.pick_random()
	if next_action == &"idle":
		_start_idle()
	else:
		_start_distraction(next_action)


func _update_facing(direction: Vector2) -> void:
	if absf(direction.x) > absf(direction.y):
		_facing = &"right" if direction.x > 0.0 else &"left"
	else:
		_facing = &"down" if direction.y > 0.0 else &"up"


func _play_directional_animation(action: StringName) -> void:
	_play_animation(StringName("%s_%s" % [action, _facing]))


func _play_animation(animation_name: StringName) -> void:
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		push_warning("NPC animation not found: %s" % animation_name)
		return
	if animated_sprite.animation != animation_name or not animated_sprite.is_playing():
		animated_sprite.play(animation_name)


func _start_timer(minimum: float, maximum: float) -> void:
	var lower_bound := minf(minimum, maximum)
	var upper_bound := maxf(minimum, maximum)
	action_timer.start(randf_range(lower_bound, upper_bound))
