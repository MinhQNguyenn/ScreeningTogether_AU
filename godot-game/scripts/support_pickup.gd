class_name SupportPickup
extends Area2D

# positive info/support pickup

signal collected(support_name: String)

@export var support_name: String = "Medicare card"

var animation_time: float = 0.0

@onready var visual: Node2D = $Visual
@onready var caption: Label = $Visual/Caption


func _ready() -> void:
	# show the pickup name and listen for the player touching it
	caption.text = support_name
	body_entered.connect(_on_body_entered)


func configure(name_text: String, color: Color, icon_texture: Texture2D) -> void:
	# set which pickup this is and what it looks like
	support_name = name_text
	$Visual/Token.color = color
	$Visual/Icon.texture = icon_texture
	if is_node_ready():
		caption.text = support_name


func _process(delta: float) -> void:
	# small floating animation so it stands out
	animation_time += delta
	visual.position.y = sin(animation_time * 4.0) * 8.0
	visual.rotation = sin(animation_time * 2.0) * 0.04


func _on_body_entered(body: Node2D) -> void:
	# only collect it during an actual run
	if not (body is RunnerPlayer) or not body.is_running:
		return
	set_deferred("monitoring", false)
	collected.emit(support_name)
	queue_free()
