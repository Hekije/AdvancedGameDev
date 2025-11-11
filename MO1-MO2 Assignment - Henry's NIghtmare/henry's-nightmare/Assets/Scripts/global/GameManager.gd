extends Node

signal lives_changed(v: int)
signal orbs_changed(v: int)
signal game_over()

var lives: int = 3
var orbs: int = 0

func add_orb(n: int = 1) -> void:
	orbs += n
	emit_signal("orbs_changed", orbs)

func lose_life(n: int = 1) -> void:
	lives = max(0, lives - n)
	emit_signal("lives_changed", lives)
	if lives == 0:
		emit_signal("game_over")

func reset_run() -> void:
	lives = 3
	orbs = 0
	emit_signal("lives_changed", lives)
	emit_signal("orbs_changed", orbs)
