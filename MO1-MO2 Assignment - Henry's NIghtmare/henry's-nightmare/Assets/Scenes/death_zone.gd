extends Area2D

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		if Game.lives > 1:
			Game.lose_life(1)
			get_tree().reload_current_scene()
		else:
			Game.lose_life(1) # triggers game_over
