extends Area2D

@export var required_orbs: int = 10
@export var outro_scene: String = "res://Assets/Scenes/outro_cutscene.tscn"

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	visible = false
	monitoring = false
	body_entered.connect(_on_body_entered)
	Game.connect("orbs_changed", _on_orbs_changed)
	_update_state(Game.orbs)

func _on_orbs_changed(v: int) -> void:
	_update_state(v)

func _update_state(v: int) -> void:
	var active := v >= required_orbs
	visible = active
	monitoring = active

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file(outro_scene)
