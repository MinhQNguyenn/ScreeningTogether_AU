class_name ClinicFinish
extends Area2D

signal reached

var has_been_reached: bool = false
var approaching_player: RunnerPlayer = null


func _ready() -> void:
	# Track the player after they enter the finish area. The area's collision
	# shapes overlap before the player's logical position reaches the line.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	if has_been_reached or not is_instance_valid(approaching_player):
		return
	if approaching_player.global_position.y > global_position.y:
		return

	has_been_reached = true
	reached.emit()


func reset_finish() -> void:
	# let the finish work again after restart
	has_been_reached = false
	approaching_player = null


func _on_body_entered(body: Node2D) -> void:
	# Entering the collision area means the player is approaching the line;
	# completion happens only when their logical position crosses its centre.
	if (
		has_been_reached
		or not (body is RunnerPlayer)
		or not body.is_running
	):
		return
	approaching_player = body as RunnerPlayer


func _on_body_exited(body: Node2D) -> void:
	if body == approaching_player and not has_been_reached:
		approaching_player = null
