extends Node2D

@onready var music: AudioStreamPlayer2D = $Music

func _ready() -> void:
	if not music.playing:
		music.play()

func _on_start_pressed() -> void:
	var t := create_tween()
	t.tween_property(music, "volume_db", -40.0, 0.6) # fade out in 0.6s
	await t.finished
	music.stop()
	get_tree().change_scene_to_file("res://Assets/Scenes/cutscene.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
