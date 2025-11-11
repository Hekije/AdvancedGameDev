extends CharacterBody2D

@export var speed: float = 10.0
@export var jump_power: float = 10.0
@export var gravity: float = 1000.0
@export var invuln_time: float = 1.0
@export var flash_interval: float = 0.08
@export var knockback_speed: float = 220.0
@export var knockup: float = 320.0

var speed_multiplier: float = 30.0
var jump_multiplier: float = -30.0
var direction: float = 0.0
var crouching: bool = false
var invincible: bool = false
var lives: int = 3

@onready var animated_sprite: AnimatedSprite2D = $Henry/AnimatedSprite2D

func _ready():
	add_to_group("Player")

func set_anim(name: String) -> void:
	if animated_sprite.animation != name:
		animated_sprite.play(name)

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta

	direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * speed * speed_multiplier
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * speed_multiplier)

	if Input.is_action_just_pressed("jump") and is_on_floor() and !crouching:
		velocity.y = jump_power * jump_multiplier
		set_anim("jump")
	elif is_on_floor():
		if Input.is_action_just_pressed("down"):
			crouching = true
			velocity.x = 0.0
			set_anim("crouch")
		elif Input.is_action_just_released("down"):
			crouching = false
			if direction != 0:
				set_anim("walk")
			else:
				set_anim("idle")
		else:
			if !crouching:
				if direction != 0:
					set_anim("walk")
				else:
					set_anim("idle")
	else:
		if animated_sprite.animation != "jump":
			set_anim("jump")

	move_and_slide()

func stomp_jump():
	velocity.y = jump_power * jump_multiplier * 0.8

func take_damage(amount: int = 1, hit_dir: int = 0) -> void:
	if invincible:
		return
	invincible = true
	if hit_dir != 0:
		velocity.x = sign(hit_dir) * -knockback_speed
	velocity.y = -knockup
	Game.lose_life(amount)
	await _flash_invincible(invuln_time)
	invincible = false

func _flash_invincible(duration: float) -> void:
	var elapsed := 0.0
	while elapsed < duration:
		animated_sprite.modulate = Color(1, 0.6, 0.6)
		await get_tree().create_timer(flash_interval).timeout
		animated_sprite.modulate = Color(1, 1, 1)
		await get_tree().create_timer(flash_interval).timeout
		elapsed += flash_interval * 2.0
