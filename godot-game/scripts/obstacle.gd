class_name BarrierObstacle
extends Area2D

# one of the sign obstacles on the path

@export var barrier_name: String = "Barrier"

var is_active: bool = true

@onready var label: Label = $Sign/Label


func _ready() -> void:
	# add to a group so main can find barriers for the pickup
	label.text = barrier_name
	add_to_group("stigma_obstacle")
	body_entered.connect(_on_body_entered)


func configure(name_text: String, color: Color) -> void:
	# set the words and colour picked by main
	barrier_name = name_text
	if is_node_ready():
		label.text = barrier_name
	$Sign.color = color


func set_dormant() -> void:
	# hide quote obstacles until the bubble animation is done
	is_active = false
	set_deferred("monitoring", false)
	visible = false


func activate() -> void:
	# pop the sign into the lane so its easier to notice
	is_active = true
	visible = true
	set_deferred("monitoring", true)
	scale = Vector2(0.52, 0.52)
	modulate = Color(1.35, 1.25, 0.75, 1.0)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.32)
	tween.tween_property(self, "modulate", Color.WHITE, 0.32)


func _on_body_entered(body: Node2D) -> void:
	# crash returns false if this hit shouldnt count
	if is_active and body.has_method("crash") and body.crash(barrier_name):
		clear_with_support(Color("#d9b45b"))


func clear_with_support(clear_color: Color = Color("#6bbf87")) -> void:
	# shrink/fade when the obstacle gets cleared
	if not is_active:
		return
	is_active = false
	set_deferred("monitoring", false)
	$Sign.color = clear_color
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.15, 0.15), 0.28)
	tween.tween_property(self, "modulate:a", 0.0, 0.28)
	tween.chain().tween_callback(queue_free)
