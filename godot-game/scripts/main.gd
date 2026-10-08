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
const ROUTE_DISTANCE_METRES := 1500
const PIXELS_PER_METRE := 10.0
const FINISH_Y := -ROUTE_DISTANCE_METRES * PIXELS_PER_METRE
const MAX_LIVES := 3
# Include collision clearance so the first possible hit is at least four seconds away.
const OPENING_SECONDS := 4.0
const OBSTACLE_CLEARANCE := 100.0
# which track pieces get NPCs and pickups
const NPC_SEGMENTS := [3, 9, 15, 21, 27, 33, 39, 44]
const PICKUP_SEGMENTS := [5, 12, 20]

# the quotes that show up beside the path
const STIGMA_MESSAGES := [
	"Why get screened if you feel fine?",
	"That's too private to talk about.",
	"What will people think?",
	"Isn't screening only if something is wrong?",
]

const BARRIERS := [
	# some of the quotes also show up as barriers
	{"name": "Myths", "color": Color("#b56f7c")},
	{"name": "Privacy", "color": Color("#8f709c")},
	{"name": "Judgement", "color": Color("#c87965")},
	{"name": "Doubt", "color": Color("#7770a8")},
	# these ones are more general barrier ideas
	{"name": "Shame", "color": Color("#a45f6b")},
	{"name": "Pressure", "color": Color("#927052")},
	{"name": "Language", "color": Color("#557d9b")},
	{"name": "Trust", "color": Color("#568f86")},
]

const BARRIER_EXPLANATIONS := {
	"Myths": "\"I feel well, so I don't need screening.\"\nScreening can be due even without symptoms.",
	"Privacy": "Worrying that others may find out can make screening feel difficult. Ask your GP how your information stays private.",
	"Judgement": "\"What will people think?\"\nFear of gossip or blame can make screening harder. You deserve respectful care.",
	"Doubt": "Not knowing what screening involves can make it hard to start. Ask your GP to explain your options.",
	"Shame": "Talking about intimate health can feel embarrassing. You can ask for a female practitioner when booking.",
	"Pressure": "Family or community expectations can make screening feel difficult to discuss. Your screening decision is yours.",
	"Language": "Unfamiliar medical words can make screening confusing. Ask the clinic for an interpreter when booking.",
	"Trust": "An unfamiliar health system can make it hard to feel safe. A practitioner you trust can explain each step.",
}
const BARRIER_FEEDBACK_SECONDS := 5.0

const SUPPORT_TYPES := [
	{
		"name": "Medicare card",
		"color": Color("#4f9b78"),
		"icon": preload("res://assets/preparation/medicare_card.svg"),
		"description": "Bring your Medicare card if you have one. You can still access cervical screening without a Medicare card; ask the clinic about costs when booking.",
	},
	{
		"name": "Question notes",
		"color": Color("#d1974f"),
		"icon": preload("res://assets/preparation/question_notes.svg"),
		"description": "You might like to bring a list of questions or concerns. For example: What are my screening options? Can you explain each step? You can ask to pause or stop.",
	},
	{
		"name": "Reminder letter",
		"color": Color("#6b80b4"),
		"icon": preload("res://assets/preparation/reminder_letter.svg"),
		"description": "Bring your cervical screening reminder letter if you have one. You can use it to ask your GP when you are due. You do not need a letter to book an appointment.",
	},
]

# values that change during a run
var track_segments: Array[Node2D] = []
var next_segment_y: float = 320.0
var segment_count: int = 0
var lives: int = MAX_LIVES
var is_playing: bool = false
var collected_items: Array[String] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
# stops an old message timer from deleting a newer message
var feedback_revision: int = 0
var feedback_tween: Tween = null
var barrier_feedback_revision: int = 0
var barrier_feedback_tween: Tween = null

var current_support_popup: SupportPopup = null

# shortcuts to nodes in the main scene
@onready var player: RunnerPlayer = $Player
@onready var clinic_finish: ClinicFinish = $Destination
@onready var score_label: Label = $Interface/HUD/Score
@onready var health_hearts: Array[TextureRect] = [
	$Interface/HUD/HealthDisplay/Heart1,
	$Interface/HUD/HealthDisplay/Heart2,
	$Interface/HUD/HealthDisplay/Heart3,
]
@onready var feedback_label: Label = $Interface/HUD/Feedback
@onready var barrier_feedback: PanelContainer = $Interface/HUD/BarrierFeedback
@onready var barrier_feedback_label: Label = $Interface/HUD/BarrierFeedback/Message
@onready var barrier_explanation: Label = $Interface/GameOverScreen/Panel/Content/BarrierExplanation
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
	_clear_barrier_feedback()
	start_screen.hide()
	game_over_screen.hide()
	completion_screen.hide()
	_show_feedback("Find appointment items. Dodge or jump fences.", 4.0)
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
	collected_items.clear()
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
		and -next_segment_y - 210.0 >= player.forward_speed * OPENING_SECONDS + OBSTACLE_CLEARANCE
		and next_segment_y > FINISH_Y + SEGMENT_HEIGHT
	):
		if current_index in PICKUP_SEGMENTS:
			_add_full_obstacle_row(segment, -180.0)
		else:
			var obstacle_y: float = rng.randf_range(-210.0, 210.0)
			_add_obstacle_row(segment, obstacle_y)
	if current_index in NPC_SEGMENTS and -next_segment_y + 135.0 >= player.forward_speed * OPENING_SECONDS + OBSTACLE_CLEARANCE:
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
	var support_icon: Texture2D = support["icon"]
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
	# Show the journey as a clear countdown from 1500 m to the clinic.
	GameLanguage.bind_text(score_label, "%d m", [_get_remaining_distance_metres()])


func _get_remaining_distance_metres() -> int:
	var travelled_metres: float = clampf(
		-player.position.y / PIXELS_PER_METRE,
		0.0,
		float(ROUTE_DISTANCE_METRES),
	)
	return int(ceil(float(ROUTE_DISTANCE_METRES) - travelled_metres))


func _update_hud() -> void:
	# Use image-based hearts so the HUD renders consistently in Web exports.
	_update_score()
	GameLanguage.bind_text($Interface/HUD/Bag, "Appointment bag: %d / %d", [collected_items.size(), SUPPORT_TYPES.size()])
	for heart_index in health_hearts.size():
		var heart_alpha: float = 1.0 if heart_index < lives else 0.2
		health_hearts[heart_index].modulate = Color(1.0, 1.0, 1.0, heart_alpha)


func _on_player_hit(barrier_name: String) -> void:
	# take one life for a proper hit
	if not is_playing:
		return
	lives = maxi(0, lives - 1)
	_update_hud()
	var explanation: String = BARRIER_EXPLANATIONS.get(barrier_name, "Screening can feel unfamiliar. Ask your healthcare provider about the support you need.")
	if lives > 0:
		_show_barrier_feedback(barrier_name, explanation)
		return
	_clear_barrier_feedback()
	is_playing = false
	player.stop_run()
	GameLanguage.bind_text(final_score, "Remaining distance  %d m", [_get_remaining_distance_metres()])
	GameLanguage.bind_text(barrier_message, "Last barrier: %s", [barrier_name])
	barrier_explanation.text = explanation
	game_over_screen.show()


func _clear_barrier_feedback() -> void:
	barrier_feedback_revision += 1
	if barrier_feedback_tween != null and barrier_feedback_tween.is_valid():
		barrier_feedback_tween.kill()
	barrier_feedback.hide()
	barrier_feedback.modulate = Color.WHITE
	GameLanguage.bind_text(barrier_feedback_label, "")


func _show_barrier_feedback(barrier_name: String, explanation: String) -> void:
	# Separate from pickup feedback: no pause, focus change or input interception.
	_clear_barrier_feedback()
	var revision: int = barrier_feedback_revision
	GameLanguage.bind_text(barrier_feedback_label, "%s\n%s", [barrier_name, explanation])
	barrier_feedback.show()
	await get_tree().create_timer(BARRIER_FEEDBACK_SECONDS).timeout
	if revision != barrier_feedback_revision:
		return
	barrier_feedback_tween = create_tween()
	barrier_feedback_tween.tween_property(barrier_feedback, "modulate:a", 0.0, 0.35)
	await barrier_feedback_tween.finished
	if revision == barrier_feedback_revision:
		_clear_barrier_feedback()


func _on_support_collected(support_name: String) -> void:
	if not is_playing:
		return
	if support_name not in collected_items:
		collected_items.append(support_name)
	_update_hud()
	await _open_support_popup(support_name)


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
	_clear_barrier_feedback()
	is_playing = false
	player.stop_run()
	player.position.y = FINISH_Y
	_update_score()
	GameLanguage.bind_text(completion_score, "Appointment items collected: %d / %d\nYou can attend even without these items.", [collected_items.size(), SUPPORT_TYPES.size()])
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

func _open_support_popup(support_name: String) -> void:
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
	for item in SUPPORT_TYPES:
		if item["name"] == support_name:
			current_support_popup.show_preparation_item(item)
			break


func _on_support_popup_closed() -> void:
	current_support_popup = null
	_clear_nearest_barrier_row()
	_show_feedback("Packed for your appointment! Fence row cleared.")

	await get_tree().create_timer(0.3).timeout
	_resume_after_support_popup()


func _resume_after_support_popup() -> void:
	# Do not resume if another ending screen has appeared.
	if game_over_screen.visible or completion_screen.visible:
		return

	is_playing = true
	player.start_run()
