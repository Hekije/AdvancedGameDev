extends CanvasLayer

@onready var lives_label: Label = $MarginContainer/TopBar/LivesLabel
@onready var orbs_label: Label = $MarginContainer/TopBar/OrbsLabel

func _ready() -> void:
	Game.connect("lives_changed", _on_lives_changed)
	Game.connect("orbs_changed", _on_orbs_changed)
	_on_lives_changed(Game.lives)
	_on_orbs_changed(Game.orbs)

func _on_lives_changed(v: int) -> void:
	lives_label.text = "x %d" % v

func _on_orbs_changed(v: int) -> void:
	orbs_label.text = "x %d" % v
