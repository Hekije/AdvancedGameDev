extends Control

@export var next_scene: String = "res://Assets/Scenes/cutscene_stills.tscn"
@export var show_skip_after: float = 1.0

@onready var video: VideoStreamPlayer = $Video

func _ready() -> void:
	video.finished.connect(_on_finished)
	_play_video()
	_show_skip_hint_later()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("start"):
		_on_finished()

func _play_video() -> void:
	video.play()

func _show_skip_hint_later() -> void:
	await get_tree().create_timer(show_skip_after).timeout
	print("Press Enter to Skip")  

func _on_finished() -> void:
	get_tree().change_scene_to_file(next_scene)
