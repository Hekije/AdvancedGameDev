extends Sprite2D
@onready var interaction: Area2D = $interaction

func _ready() -> void:
	interaction.body_entered.connect(_on_interaction_body_entered)

func _on_interaction_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		interaction.monitoring = false
		var t := create_tween()
		t.tween_property(self, "scale", scale * 1.6, 0.15).set_ease(Tween.EASE_OUT)
		t.tween_property(self, "modulate:a", 0.0, 0.15)
		t.tween_callback(Callable(self, "_collect"))

func _collect() -> void:
	Game.add_orb(1)
	queue_free()
