class_name RunnerPlayer
extends CharacterBody2D

# player movement, jumping and input are all in here

# tell main that a barrier actually hit the player
signal obstacle_hit(barrier_name: String)

# x positions for left, middle and right lanes
const LANE_X := [-144.0, 0.0, 144.0]
const SWIPE_THRESHOLD := 45.0
const JUMP_DURATION := 0.72
const JUMP_HEIGHT := 105.0
const INVULNERABILITY_DURATION := 1.5

@export var forward_speed: float = 285.0
@export var lane_change_speed: float = 900.0

var is_running: bool = false
var is_jumping: bool = false
var lane_index: int = 1
var jump_elapsed: float = 0.0
var touch_start: Vector2 = Vector2.ZERO
var touch_active: bool = false
var swipe_used: bool = false
var is_invulnerable: bool = false
var invulnerability_elapsed: float = 0.0

@onready var character: AnimatedSprite2D = $Character
@onready var shadow: Polygon2D = $Shadow


func _ready() -> void:
	# dont run in the background on the start screen
	character.stop()


func start_run() -> void:
	is_running = true
	character.play("run")


func reset_player() -> void:
	# reset everything for another run
	position = Vector2.ZERO
	velocity = Vector2.ZERO
	lane_index = 1
	is_running = false
	is_jumping = false
	jump_elapsed = 0.0
	is_invulnerable = false
	invulnerability_elapsed = 0.0
	character.position.y = -34.0
	character.modulate = Color.WHITE
	character.frame = 0
	shadow.scale = Vector2.ONE
	collision_layer = 1
	$Camera2D.reset_smoothing()


func stop_run() -> void:
	is_running = false
	velocity = Vector2.ZERO
	character.stop()


func crash(barrier_name: String) -> bool:
	# no hit if jumping or still flashing from the last hit
	if not is_running or is_jumping or is_invulnerable:
		return false
	is_invulnerable = true
	invulnerability_elapsed = 0.0
	obstacle_hit.emit(barrier_name)
	return true


func _physics_process(delta: float) -> void:
	# move forward every physics frame
	_update_invulnerability(delta)
	if not is_running:
		return

	_read_keyboard_input()
	var target_x: float = LANE_X[lane_index]
	position.x = move_toward(position.x, target_x, lane_change_speed * delta)
	velocity = Vector2(0.0, -forward_speed)
	move_and_slide()
	_update_jump(delta)


func _read_keyboard_input() -> void:
	# keyboard controls (arrows and WASD are in the input map)
	if Input.is_action_just_pressed("move_left"):
		change_lane(-1)
	if Input.is_action_just_pressed("move_right"):
		change_lane(1)
	if Input.is_action_just_pressed("jump"):
		jump()


func change_lane(direction: int) -> void:
	# keep lane number between 0 and 2
	lane_index = clampi(lane_index + direction, 0, LANE_X.size() - 1)


func jump() -> void:
	# cant start another jump in the middle of one
	if is_jumping or not is_running:
		return
	is_jumping = true
	jump_elapsed = 0.0


func _update_jump(delta: float) -> void:
	# sine makes the jump go up and back down smoothly
	if not is_jumping:
		return
	jump_elapsed += delta
	var progress: float = minf(jump_elapsed / JUMP_DURATION, 1.0)
	var height: float = sin(progress * PI) * JUMP_HEIGHT
	character.position.y = -34.0 - height
	var shadow_scale: float = 1.0 - (height / JUMP_HEIGHT) * 0.38
	shadow.scale = Vector2(shadow_scale, shadow_scale)
	if progress >= 1.0:
		is_jumping = false
		character.position.y = -34.0
		shadow.scale = Vector2.ONE


func _update_invulnerability(delta: float) -> void:
	# flash while the player cant be hit again
	if not is_invulnerable:
		return
	invulnerability_elapsed += delta
	var flash_phase: int = int(invulnerability_elapsed * 12.0)
	character.modulate.a = 0.35 if flash_phase % 2 == 0 else 1.0
	if invulnerability_elapsed >= INVULNERABILITY_DURATION:
		is_invulnerable = false
		invulnerability_elapsed = 0.0
		character.modulate = Color.WHITE


func _unhandled_input(event: InputEvent) -> void:
	# work out swipe direction from where the touch started
	if not is_running:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			touch_active = true
			swipe_used = false
		else:
			touch_active = false
	elif event is InputEventScreenDrag and touch_active and not swipe_used:
		var swipe: Vector2 = event.position - touch_start
		if swipe.length() < SWIPE_THRESHOLD:
			return
		if absf(swipe.x) > absf(swipe.y):
			change_lane(1 if swipe.x > 0.0 else -1)
		elif swipe.y < 0.0:
			jump()
		swipe_used = true
