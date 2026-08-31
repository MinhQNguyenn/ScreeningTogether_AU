class_name ClinicFinish
extends Area2D

signal reached

var has_been_reached: bool = false


func _ready() -> void:
	# listen for the player crossing the clinic line
	body_entered.connect(_on_body_entered)


func reset_finish() -> void:
	# let the finish work again after restart
	has_been_reached = false


func _on_body_entered(body: Node2D) -> void:
	# ignore anything that isnt the running player (and dont finish twice)
	if (
		has_been_reached
		or not (body is RunnerPlayer)
		or not body.is_running
	):
		return
	has_been_reached = true
	reached.emit()
