class_name GameCompletePopup
extends ColorRect

signal replay_requested

@onready var title_label: Label = $PanelContainer/Content/TitleLabel
@onready var message_label: Label = $PanelContainer/Content/MessageLabel
@onready var reaction_score_label: Label = $PanelContainer/Content/ReactionScoreLabel
@onready var side_quest_score_label: Label = $PanelContainer/Content/SideQuestScoreLabel
@onready var total_score_label: Label = $PanelContainer/Content/TotalScoreLabel
@onready var replay_button: Button = $PanelContainer/Content/ReplayButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	replay_button.pressed.connect(_on_replay_pressed)
	replay_button.grab_focus()


func show_result(
	player_name: String,
	reaction_points: int,
	side_quest_points: int
) -> void:
	message_label.text = (
		"Great listening, %s!\nYou recognised your name and responded in time."
		% player_name
	)
	reaction_score_label.text = "Reaction score:  +%d" % reaction_points
	side_quest_score_label.text = "Side quest bonus:  +%d" % side_quest_points
	total_score_label.text = "TOTAL SCORE:  %d" % (
		reaction_points + side_quest_points
	)
	get_tree().paused = true


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			get_viewport().set_input_as_handled()
			_on_replay_pressed()


func _on_replay_pressed() -> void:
	replay_button.disabled = true
	get_tree().paused = false
	replay_requested.emit()
	get_tree().reload_current_scene()
