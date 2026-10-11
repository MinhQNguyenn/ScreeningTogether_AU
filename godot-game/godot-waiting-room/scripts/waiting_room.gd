extends Control


const PLAYER_NAME := "Emily Nguyen"

const OTHER_NAMES := [
	"Olivia Tran",
	"Sophia Patel",
	"Amelia Nguyen",
	"Charlotte Lee",
	"Grace Wilson",
	"Emma Taylor",
]

var announcement_queue: Array = []
var current_name := ""
var score := 0
var game_completed := false

var rng := RandomNumberGenerator.new()

@onready var called_name: Label = (
	$AnnouncementPanel/AnnouncementContent/CalledName
)
@onready var feedback_label: Label = $FeedbackLabel
@onready var thats_me_button: Button = $ThatsMeButton


func _ready() -> void:
	rng.randomize()
	thats_me_button.pressed.connect(_on_thats_me_pressed)

	_prepare_announcement_queue()
	_run_announcements()


func _prepare_announcement_queue() -> void:
	announcement_queue = OTHER_NAMES.duplicate()
	announcement_queue.shuffle()

	# The player's name will be the fourth to seventh call.
	var player_call_index := rng.randi_range(3, 6)
	announcement_queue.insert(player_call_index, PLAYER_NAME)


func _run_announcements() -> void:
	await get_tree().create_timer(1.5).timeout

	while not announcement_queue.is_empty():
		if game_completed:
			return

		current_name = str(announcement_queue.pop_front())
		called_name.text = current_name
		feedback_label.text = "Is this your name?"

		await get_tree().create_timer(4.0).timeout

		if game_completed:
			return

		# If the player missed their name, call it again later.
		if current_name == PLAYER_NAME:
			announcement_queue.append(PLAYER_NAME)

		current_name = ""
		called_name.text = "Please wait..."
		feedback_label.text = "Keep listening for your name."

		await get_tree().create_timer(1.0).timeout

	called_name.text = "No more announcements"
	feedback_label.text = "Please speak to reception."


func _on_thats_me_pressed() -> void:
	if current_name.is_empty():
		feedback_label.text = "Wait for the next announcement."
		return

	if current_name == PLAYER_NAME:
		score += 500
		game_completed = true
		called_name.text = "Emily Nguyen â€” please proceed"
		feedback_label.text = "Correct! +500 points"
		thats_me_button.disabled = true
	else:
		score = maxi(0, score - 50)
		feedback_label.text = "That is not your name. Keep listening."
