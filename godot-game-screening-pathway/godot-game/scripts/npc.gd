class_name StigmaNpc
extends Node2D

# NPC standing beside the track with a quote that moves into a barrier

const TINTS := [
	Color("#ffffff"),
	Color("#f3d6c6"),
	Color("#d7e7c7"),
	Color("#d9d3ee"),
]

@export_multiline var message: String = "What will people think?"

var target_barrier: BarrierObstacle = null
var animation_started: bool = false

@onready var speech_bubble: Polygon2D = $SpeechBubble
@onready var speech_label: Label = $SpeechBubble/Label
@onready var quote_trigger: Area2D = $QuoteTrigger


func _ready() -> void:
	# wait until the player is close before moving the bubble
	speech_label.text = message
	add_to_group("stigma_npc")
	quote_trigger.body_entered.connect(_on_quote_trigger_body_entered)


func configure(message_text: String, side: float, variant: int) -> void:
	# point the bubble towards the track so it stays on screen
	message = message_text
	speech_bubble.position.x = -112.0 if side > 0.0 else 112.0
	$Character.modulate = TINTS[variant % TINTS.size()]
	if is_node_ready():
		speech_label.text = message


func bind_quote_barrier(barrier: BarrierObstacle) -> void:
	# save the hidden barrier this bubble is linked to
	target_barrier = barrier
	target_barrier.set_dormant()


func _on_quote_trigger_body_entered(body: Node2D) -> void:
	if body is RunnerPlayer:
		call_deferred("_animate_quote_to_barrier")


func _animate_quote_to_barrier() -> void:
	# only do the animation once
	if animation_started or not is_instance_valid(target_barrier):
		return
	animation_started = true
	var target_position: Vector2 = to_local(
		target_barrier.global_position + Vector2(0.0, -21.0)
	)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	# pulse first so there is time to read it, then move it onto the track
	tween.tween_property(speech_bubble, "scale", Vector2(1.12, 1.12), 0.2)
	tween.tween_property(speech_bubble, "scale", Vector2.ONE, 0.2)
	tween.tween_interval(0.4)
	tween.tween_property(speech_bubble, "position", target_position, 1.0)
	tween.parallel().tween_property(
		speech_bubble,
		"scale",
		Vector2(0.52, 0.52),
		1.0,
	)
	tween.tween_callback(_finish_quote_animation)


func _finish_quote_animation() -> void:
	# hide the bubble and switch on the real obstacle
	speech_bubble.hide()
	quote_trigger.set_deferred("monitoring", false)
	if is_instance_valid(target_barrier):
		target_barrier.activate()
