extends Node

@onready var music: AudioStreamPlayer2D = $Music

func _ready() -> void:
	Game.connect("game_over", _on_game_over)
	if music and music.stream:
		if !music.playing:
			music.play()  

func _on_game_over() -> void:
	if music and music.playing:
		music.stop()
	Game.reset_run()
	get_tree().reload_current_scene()
