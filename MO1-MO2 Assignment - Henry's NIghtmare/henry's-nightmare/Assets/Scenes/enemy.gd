extends CharacterBody2D

@export var move_speed: float = 40.0
@export var gravity: float = 1000.0
@export var death_fade_time: float = 0.35
@export var ledge_probe_forward: float = 16.0
@export var ledge_probe_down: float = 32.0
@export var wall_unstuck_nudge: float = 2.0
@export var flip_cooldown_time: float = 0.12

var direction: int = -1
var is_dead: bool = false
var flip_cooldown: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var head: Area2D = $hitbox
@onready var hurtbox: Area2D = $hurtbox
@onready var ray_down: RayCast2D = $RayDown


func _ready() -> void:
	modulate.a = 1.0
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("death"):
		sprite.sprite_frames.set_animation_loop("death", false)
	sprite.play("walk")
	sprite.flip_h = direction < 0
	head.body_entered.connect(_on_hitbox_body_entered)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	ray_down.enabled = true
	add_to_group("Enemy")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	flip_cooldown = max(flip_cooldown - delta, 0.0)

	ray_down.position.x = ledge_probe_forward * direction
	ray_down.target_position = Vector2(0, ledge_probe_down)

	velocity.y += gravity * delta

	var ahead := Vector2(direction * 2.0, 0.0)
	var will_hit_wall := test_move(global_transform, ahead)

	if will_hit_wall and flip_cooldown <= 0.0:
		_flip()
		global_position.x -= wall_unstuck_nudge * (-direction)
		flip_cooldown = flip_cooldown_time
	else:
		velocity.x = direction * move_speed

	move_and_slide()

	if flip_cooldown <= 0.0 and !ray_down.is_colliding():
		_flip()
		global_position.x -= wall_unstuck_nudge * (-direction)
		flip_cooldown = flip_cooldown_time

	if abs(velocity.x) > 0.1:
		_play("walk")
	else:
		_play("idle")

func _flip() -> void:
	direction *= -1
	sprite.flip_h = direction < 0
	ray_down.position.x = ledge_probe_forward * direction

func _play(anim_name: String) -> void:
	if sprite.animation != anim_name:
		sprite.play(anim_name)

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	head.monitoring = false
	hurtbox.monitoring = false
	_play("death")
	await sprite.animation_finished
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, death_fade_time)
	await t.finished
	queue_free()

func _on_hitbox_body_entered(body: Node) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		var cb := body as CharacterBody2D
		var above: bool = body.global_position.y < global_position.y - 8.0
		var falling: bool = cb != null and cb.velocity.y > 0.0
		if above and falling:
			_die()
			if body.has_method("stomp_jump"):
				body.stomp_jump()


func _on_hurtbox_body_entered(body: Node) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		var dir = -1 if body.global_position.x < global_position.x else 1
		if body.has_method("take_damage"):
			body.take_damage(1, dir)
