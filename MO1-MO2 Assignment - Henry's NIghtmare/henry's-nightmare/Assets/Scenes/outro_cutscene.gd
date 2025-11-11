extends Control

@export var next_scene: String = "res://Assets/Scenes/main_menu.tscn"
@export var stills: Array[Texture2D]
@export var captions: Array[String]
@export var hold_time: float = 2.5
@export var fade_time: float = 0.35
@export var type_speed: float = 0.02

@export var music_fade_in: float = 0.6
@export var music_fade_out: float = 0.4
@export var music_volume_db: float = -8.0  

@onready var img: TextureRect = $Image
@onready var text: Label = $Text
@onready var hint: Label = $Hint
@onready var music: AudioStreamPlayer2D = $Music

var i := 0
var typing := false
var skipping := false
var ending := false

func _ready() -> void:
	hint.modulate.a = 0.0
	if music and music.stream:
		music.volume_db = -40.0
		music.play()
		var mt := create_tween()
		mt.tween_property(music, "volume_db", music_volume_db, music_fade_in)
	_show_current(true)

func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_accept") or e.is_action_pressed("start"):
		if typing:
			skipping = true
		else:
			_next()

func _show_current(first: bool=false) -> void:
	if i >= stills.size():
		_finish()
		return
	img.texture = stills[i]
	text.text = ""
	typing = true
	skipping = false
	var t := create_tween()
	if !first:
		img.modulate.a = 0.0
		t.tween_property(img, "modulate:a", 1.0, fade_time)
	await _type_out(captions[i])
	typing = false
	await get_tree().create_timer(hold_time).timeout
	if hint.modulate.a < 0.99:
		var h := create_tween()
		h.tween_property(hint, "modulate:a", 1.0, 0.25)

func _type_out(s: String) -> void:
	text.text = ""
	for c in s:
		text.text += c
		if skipping:
			text.text = s
			break
		await get_tree().create_timer(type_speed).timeout

func _next() -> void:
	i += 1
	var t := create_tween()
	t.tween_property(img, "modulate:a", 0.0, fade_time * 0.8)
	t.tween_property(hint, "modulate:a", 0.0, 0.2)
	await t.finished
	_show_current()

func _finish() -> void:
	if ending:
		return
	ending = true
	if music and music.playing:
		var mt := create_tween()
		mt.tween_property(music, "volume_db", -40.0, music_fade_out)
		await mt.finished
		music.stop()
	get_tree().change_scene_to_file(next_scene)
