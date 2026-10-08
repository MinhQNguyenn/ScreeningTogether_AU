class_name GameCompletePopup
extends ColorRect

signal replay_requested
signal continue_requested

@onready var title_label: Label = $PanelContainer/Content/TitleLabel
@onready var message_label: Label = $PanelContainer/Content/MessageLabel
@onready var reaction_score_label: Label = $PanelContainer/Content/ReactionScoreLabel
@onready var side_quest_score_label: Label = $PanelContainer/Content/SideQuestScoreLabel
@onready var total_score_label: Label = $PanelContainer/Content/TotalScoreLabel
@onready var replay_button: Button = $PanelContainer/Content/ReplayButton
@onready var continue_button: Button = $PanelContainer/Content/ContinueButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	replay_button.pressed.connect(_on_replay_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	replay_button.grab_focus()


func show_result(
	player_name: String,
	reaction_points: int,
	side_quest_points: int
) -> void:
	GameLanguage.bind_text(message_label, "Great listening, %s!\nYou recognised your name and responded in time.", [StringName(player_name)])
	GameLanguage.bind_text(reaction_score_label, "Reaction score:  +%d", [reaction_points])
	GameLanguage.bind_text(side_quest_score_label, "Side quest bonus:  +%d", [side_quest_points])
	GameLanguage.bind_text(total_score_label, "TOTAL SCORE:  %d", [reaction_points + side_quest_points])
	get_tree().paused = true


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			get_viewport().set_input_as_handled()
			_on_replay_pressed()


func _on_replay_pressed() -> void:
	replay_button.disabled = true
	continue_button.disabled = true
	get_tree().paused = false
	replay_requested.emit()
	get_tree().reload_current_scene()


func _on_continue_pressed() -> void:
	replay_button.disabled = true
	continue_button.disabled = true
	get_tree().paused = false
	continue_requested.emit()
