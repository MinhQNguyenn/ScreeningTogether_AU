extends Node2D

# main game script, most of the level stuff is controlled here

# load these scenes here so I can spawn them below
const TRACK_SEGMENT := preload("res://scenes/track_segment.tscn")
const OBSTACLE := preload("res://scenes/obstacle.tscn")
const NPC := preload("res://scenes/npc.tscn")
const SUPPORT_PICKUP := preload("res://scenes/support_pickup.tscn")

const SUPPORT_POPUP := preload("res://scenes/support_popup.tscn")

# basic level settings
const SEGMENT_HEIGHT := 640.0
const SEGMENTS_AHEAD := 7
const FINISH_Y := -15000.0
const MAX_LIVES := 3
const MAX_CONFIDENCE := 3
# which track pieces get NPCs and pickups
const NPC_SEGMENTS := [3, 9, 15, 21, 27, 33, 39, 44]
const PICKUP_SEGMENTS := [7, 20, 32]

# the quotes that show up beside the path
const STIGMA_MESSAGES := [
	"Why get screened if you feel fine?",
	"That's too private to talk about.",
	"What will people think?",
	"Isn't screening only if something is wrong?",
]

const BARRIERS := [
	# some of the quotes also show up as barriers
	{"name": "Feel fine? Why screen?", "color": Color("#b56f7c")},
	{"name": "Too private to discuss", "color": Color("#8f709c")},
	{"name": "What will people think?", "color": Color("#c87965")},
	{"name": "Only if something is wrong?", "color": Color("#7770a8")},
	# these ones are more general barrier ideas
	{"name": "Shame", "color": Color("#a45f6b")},
	{"name": "Social pressure", "color": Color("#927052")},
	{"name": "Misconception", "color": Color("#557d9b")},
	{"name": "Privacy stigma", "color": Color("#568f86")},
]

const SUPPORT_TYPES := [
	{
		"name": "Trusted information",
		"color": Color("#4f9b78"),
		"icon": "i",
	},
	{
		"name": "Support",
		"color": Color("#d1974f"),
		"icon": "+",
	},
]

# values that change during a run
var track_segments: Array[Node2D] = []
var next_segment_y: float = 320.0
var segment_count: int = 0
var lives: int = MAX_LIVES
var confidence: int = 0
var is_playing: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
# stops an old message timer from deleting a newer message
var feedback_revision: int = 0
var feedback_tween: Tween = null

var current_support_popup: SupportPopup = null

# shortcuts to nodes in the main scene
@onready var player: RunnerPlayer = $Player
@onready var clinic_finish: ClinicFinish = $Destination
@onready var score_label: Label = $Interface/HUD/Score
@onready var lives_label: Label = $Interface/HUD/Lives
@onready var support_label: Label = $Interface/HUD/Support
@onready var feedback_label: Label = $Interface/HUD/Feedback
@onready var start_screen: Control = $Interface/StartScreen
@onready var game_over_screen: Control = $Interface/GameOverScreen
@onready var completion_screen: Control = $Interface/CompletionScreen
@onready var final_score: Label = (
	$Interface/GameOverScreen/Panel/Content/FinalScore
)
@onready var barrier_message: Label = (
	$Interface/GameOverScreen/Panel/Content/BarrierMessage
)
@onready var completion_score: Label = (
	$Interface/CompletionScreen/Panel/Content/FinalScore
)

func _ready() -> void:
	# hook up buttons and game events when the scene loads
	rng.randomize()
	clinic_finish.position.y = FINISH_Y
	player.obstacle_hit.connect(_on_player_hit)
	clinic_finish.reached.connect(_on_clinic_reached)
	$Interface/StartScreen/Panel/Content/StartButton.pressed.connect(
		_start_game
	)
	$Interface/GameOverScreen/Panel/Content/RestartButton.pressed.connect(
		_restart_game
	)
	$Interface/CompletionScreen/Panel/Content/RestartButton.pressed.connect(
		_restart_game
	)
	_build_initial_track()
	_update_hud()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if event is InputEventKey and event.echo:
		return

	get_viewport().set_input_as_handled()
	if is_instance_valid(current_support_popup):
		current_support_popup.close_popup()
	elif start_screen.visible:
		_start_game()
	elif game_over_screen.visible or completion_screen.visible:
		_restart_game()


func _process(_delta: float) -> void:
	# dont update the run while a menu is open
	if not is_playing:
		return
	_update_score()
	_maintain_track()


func _start_game() -> void:
	# hide menus and let the player start moving
	start_screen.hide()
	game_over_screen.hide()
	completion_screen.hide()
	_show_feedback("Reach the health service")
	is_playing = true
	player.start_run()


func _restart_game() -> void:
	# get rid of the old track before making a new run
	for segment in track_segments:
		$Track.remove_child(segment)
		segment.queue_free()
	track_segments.clear()
	next_segment_y = 320.0
	segment_count = 0
	lives = MAX_LIVES
	confidence = 0
	is_playing = false
	clinic_finish.reset_finish()
	player.reset_player()
	_build_initial_track()
	_update_hud()
	_start_game()


func _build_initial_track() -> void:
	# make enough track so the camera doesnt start on empty space
	for index in range(SEGMENTS_AHEAD):
		_spawn_segment(index > 0)


func _spawn_segment(add_obstacles: bool) -> void:
	# every new piece goes further up the path (negative Y)
	var current_index: int = segment_count
	var npc_index: int = NPC_SEGMENTS.find(current_index)
	var has_animated_quote: bool = npc_index >= 0
	var segment: Node2D = TRACK_SEGMENT.instantiate()
	segment.position.y = next_segment_y
	$Track.add_child(segment)
	track_segments.append(segment)

	# quote NPCs make their own barrier, so dont add another one there
	if (
		add_obstacles
		and not has_animated_quote
		and next_segment_y > FINISH_Y + SEGMENT_HEIGHT
	):
		if current_index in PICKUP_SEGMENTS:
			_add_full_obstacle_row(segment, -180.0)
		else:
			var obstacle_y: float = rng.randf_range(-210.0, 210.0)
			_add_obstacle_row(segment, obstacle_y)
	if current_index in NPC_SEGMENTS:
		_add_npc(segment, current_index)
	if current_index in PICKUP_SEGMENTS:
		_add_support_pickup(segment, current_index)

	segment_count += 1
	next_segment_y -= SEGMENT_HEIGHT


func _add_obstacle_row(segment: Node2D, local_y: float) -> void:
	# normal obstacle rows should always leave a lane open
	var open_lane: int = rng.randi_range(0, 2)
	# use two blocked lanes a bit more often, but still keep one lane open
	var obstacle_count: int = 1 if rng.randf() < 0.55 else 2
	var lanes: Array[int] = [0, 1, 2]
	lanes.erase(open_lane)
	lanes.shuffle()
	for index in range(obstacle_count):
		var barrier: Dictionary = BARRIERS[
			rng.randi_range(0, BARRIERS.size() - 1)
		]
		var obstacle: BarrierObstacle = OBSTACLE.instantiate()
		var lane_x: float = RunnerPlayer.LANE_X[lanes[index]]
		obstacle.position = Vector2(lane_x, local_y)
		segment.add_child(obstacle)
		var barrier_name: String = str(barrier["name"])
		var barrier_color: Color = barrier["color"]
		obstacle.configure(barrier_name, barrier_color)


func _add_full_obstacle_row(segment: Node2D, local_y: float) -> void:
	# full row - player needs the pickup or has to jump
	var barrier: Dictionary = BARRIERS[
		rng.randi_range(0, BARRIERS.size() - 1)
	]
	var barrier_name: String = str(barrier["name"])
	var barrier_color: Color = barrier["color"]
	for lane_x in RunnerPlayer.LANE_X:
		var obstacle: BarrierObstacle = OBSTACLE.instantiate()
		obstacle.position = Vector2(float(lane_x), local_y)
		segment.add_child(obstacle)
		obstacle.configure(barrier_name, barrier_color)


func _add_npc(segment: Node2D, current_index: int) -> void:
	# swap sides each time so the NPCs arent all on one side
	var npc: StigmaNpc = NPC.instantiate()
	var side: float = -1.0 if current_index % 2 == 0 else 1.0
	var message_index: int = NPC_SEGMENTS.find(current_index)
	npc.position = Vector2(side * 315.0, 70.0)
	segment.add_child(npc)
	npc.configure(
		STIGMA_MESSAGES[message_index % STIGMA_MESSAGES.size()],
		side,
		message_index,
	)
	# all of the NPC quotes turn into obstacles in this level
	_add_animated_quote_barrier(segment, npc, message_index)


func _add_animated_quote_barrier(
	segment: Node2D,
	npc: StigmaNpc,
	message_index: int,
) -> void:
	# starts hidden because the speech bubble turns into this
	var barrier_data: Dictionary = BARRIERS[
		message_index % STIGMA_MESSAGES.size()
	]
	var obstacle: BarrierObstacle = OBSTACLE.instantiate()
	var lane_index: int = rng.randi_range(0, RunnerPlayer.LANE_X.size() - 1)
	obstacle.position = Vector2(RunnerPlayer.LANE_X[lane_index], -135.0)
	segment.add_child(obstacle)
	var barrier_name: String = str(barrier_data["name"])
	var barrier_color: Color = barrier_data["color"]
	obstacle.configure(barrier_name, barrier_color)
	npc.bind_quote_barrier(obstacle)


func _add_support_pickup(segment: Node2D, current_index: int) -> void:
	# alternate pickup type and choose a lane for it
	var pickup_index: int = PICKUP_SEGMENTS.find(current_index)
	var support: Dictionary = SUPPORT_TYPES[
		pickup_index % SUPPORT_TYPES.size()
	]
	var pickup: SupportPickup = SUPPORT_PICKUP.instantiate()
	var lane_index: int = rng.randi_range(
		0,
		RunnerPlayer.LANE_X.size() - 1,
	)
	pickup.position = Vector2(RunnerPlayer.LANE_X[lane_index], 175.0)
	segment.add_child(pickup)
	var support_name: String = str(support["name"])
	var support_color: Color = support["color"]
	var support_icon: String = str(support["icon"])
	pickup.configure(support_name, support_color, support_icon)
	pickup.collected.connect(_on_support_collected)


func _maintain_track() -> void:
	# keep track ahead of the player and clean up old pieces behind
	var route_limit: float = FINISH_Y - SEGMENT_HEIGHT / 2.0
	var player_limit: float = (
		player.position.y - SEGMENT_HEIGHT * SEGMENTS_AHEAD
	)
	while next_segment_y > player_limit and next_segment_y >= route_limit:
		_spawn_segment(true)
	for segment in track_segments.duplicate():
		if segment.position.y > player.position.y + SEGMENT_HEIGHT * 1.5:
			track_segments.erase(segment)
			segment.queue_free()


func _update_score() -> void:
	# going forward is negative Y, 10 pixels = 1 metre
	var distance: int = maxi(0, int(-player.position.y / 10.0))
	score_label.text = "%04d m" % distance


func _update_hud() -> void:
	# build the little filled/empty life display
	_update_score()
	var filled_lives: String = "[+] ".repeat(lives)
	var empty_lives: String = "[ ] ".repeat(MAX_LIVES - lives)
	lives_label.text = "LIVES  %s%s" % [filled_lives, empty_lives]
	support_label.text = "SUPPORT  %d / %d" % [confidence, MAX_CONFIDENCE]


func _on_player_hit(barrier_name: String) -> void:
	# take one life for a proper hit
	lives = maxi(0, lives - 1)
	_show_feedback("Barrier: %s" % barrier_name)
	_update_hud()
	if lives > 0:
		return
	is_playing = false
	player.stop_run()
	var distance: int = maxi(0, int(-player.position.y / 10.0))
	final_score.text = "Distance  %d m" % distance
	barrier_message.text = "This path was blocked by: %s" % barrier_name
	game_over_screen.show()


func _on_support_collected(support_name: String) -> void:
	# Apply the gameplay effect first.
	confidence = mini(MAX_CONFIDENCE, confidence + 1)
	
	# Pause the run and show a local screening fact.
	await _open_support_popup()

	var feedback_message := (
		"%s cleared the barrier row" % support_name
	)

	_show_feedback(feedback_message)
	_update_hud()


func _clear_nearest_barrier_row() -> bool:
	# find the closest barrier that is still ahead
	var nearest: BarrierObstacle = null
	var nearest_distance: float = INF
	for node in get_tree().get_nodes_in_group("stigma_obstacle"):
		if not (node is BarrierObstacle):
			continue
		var obstacle: BarrierObstacle = node as BarrierObstacle
		if not obstacle.is_active:
			continue
		var distance_ahead: float = (
			player.global_position.y - obstacle.global_position.y
		)
		if distance_ahead > 70.0 and distance_ahead < nearest_distance:
			nearest = obstacle
			nearest_distance = distance_ahead
	if nearest == null:
		return false
	# clear anything on the same row, not just one lane
	var cleared_count: int = 0
	for node in get_tree().get_nodes_in_group("stigma_obstacle"):
		if not (node is BarrierObstacle):
			continue
		var obstacle: BarrierObstacle = node as BarrierObstacle
		if not obstacle.is_active:
			continue
		if absf(obstacle.global_position.y - nearest.global_position.y) <= 45.0:
			obstacle.clear_with_support()
			cleared_count += 1
	return cleared_count > 0


func _on_clinic_reached() -> void:
	# stop the run and show the clinic ending
	if not is_playing:
		return
	is_playing = false
	player.stop_run()
	_update_score()
	var distance: int = maxi(0, int(-player.position.y / 10.0))
	completion_score.text = "Distance  %d m" % distance
	_show_feedback("Trusted support reached")
	completion_screen.show()


func _show_feedback(message_text: String, duration: float = 2.5) -> void:
	# show this for a bit, then fade it out
	feedback_revision += 1
	var current_revision: int = feedback_revision
	if feedback_tween != null and feedback_tween.is_valid():
		feedback_tween.kill()
	feedback_label.modulate = Color.WHITE
	feedback_label.text = message_text
	await get_tree().create_timer(duration).timeout
	if current_revision != feedback_revision:
		return
	feedback_tween = create_tween()
	feedback_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.35)
	await feedback_tween.finished
	if current_revision != feedback_revision:
		return
	feedback_label.text = ""
	feedback_label.modulate = Color.WHITE

func _open_support_popup() -> void:
	# Stop gameplay while the user reads the popup.
	is_playing = false
	player.stop_run()
	
	await get_tree().create_timer(0.2).timeout
	
	if is_instance_valid(current_support_popup):
		current_support_popup.queue_free()

	current_support_popup = (
		SUPPORT_POPUP.instantiate() as SupportPopup
	)

	if current_support_popup == null:
		push_error("Support popup must use the api_display script.")
		_resume_after_support_popup()
		return

	$Interface.add_child(current_support_popup)
	current_support_popup.closed.connect(
		_on_support_popup_closed
	)
	var fact_index: int = rng.randi_range(
		0,
		SupportPopup.SCREENING_FACTS.size() - 1,
	)
	current_support_popup.show_fact(fact_index)


func _on_support_popup_closed() -> void:
	current_support_popup = null
	_clear_nearest_barrier_row()

	await get_tree().create_timer(0.3).timeout
	_resume_after_support_popup()


func _resume_after_support_popup() -> void:
	# Do not resume if another ending screen has appeared.
	if game_over_screen.visible or completion_screen.visible:
		return

	is_playing = true
	player.start_run()
