
extends CharacterBody2D


# ============================================================
# MOVEMENT
# ============================================================

@export var move_speed: float = 250.0
@export var acceleration: float = 1500.0
@export var friction: float = 2000.0

@export var jump_force: float = 450.0
@export var gravity: float = 1200.0

var facing_direction: float = 1.0


# ============================================================
# HEALTH
# ============================================================

@export var max_health: int = 100

var current_health: int

var is_hurt: bool = false
var is_dead: bool = false


# ============================================================
# ATTACK
# ============================================================

@export var attack_damage: int = 10

@export var attack_duration: float = 0.2
@export var attack_recovery: float = 0.2

var is_attacking: bool = false


# ============================================================
# DODGE
# ============================================================

@export var dodge_speed: float = 700.0
@export var dodge_duration: float = 0.2
@export var dodge_cooldown: float = 0.6

var is_dodging: bool = false
var dodge_animation_playing: bool = false

var dodge_timer: float = 0.0
var dodge_cooldown_timer: float = 0.0


# ============================================================
# REFERENCES
# ============================================================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox


# ============================================================
# READY
# ============================================================

func _ready():

	add_to_group("player")

	current_health = max_health

	collision_layer = 2
	collision_mask = 1

	attack_hitbox.damage = attack_damage

	animated_sprite.animation_finished.connect(
		_on_animation_finished
	)

	play_animation("idle")

	print("PLAYER READY")


# ============================================================
# PHYSICS
# ============================================================

func _physics_process(delta):

	if is_dead:
		return

	handle_gravity(delta)

	handle_movement(delta)

	handle_jump()

	handle_dodge()

	handle_attack()

	update_timers(delta)

	move_and_slide()

	update_animation()


# ============================================================
# MOVEMENT
# ============================================================

func handle_movement(delta):

	if is_dodging or is_hurt:

		velocity.x = move_toward(
			velocity.x,
			0,
			friction * delta
		)

		return

	var direction = Input.get_axis(
		"move_left",
        "move_right"
	)

	if direction != 0:

		velocity.x = move_toward(
			velocity.x,
			direction * move_speed,
			acceleration * delta
		)

		facing_direction = direction

	else:

		velocity.x = move_toward(
			velocity.x,
			0,
			friction * delta
		)


# ============================================================
# GRAVITY
# ============================================================

func handle_gravity(delta):

	if not is_on_floor():

		velocity.y += gravity * delta

	elif velocity.y > 0:

		velocity.y = 0


# ============================================================
# JUMP
# ============================================================

func handle_jump():

	if is_hurt or is_dead:
		return

	if Input.is_action_just_pressed("jump"):

		if is_on_floor():

			velocity.y = -jump_force


# ============================================================
# DODGE
# ============================================================

func handle_dodge():

	if is_hurt or is_dead:
		return

	if Input.is_action_just_pressed("dodge"):

		if not is_dodging and dodge_cooldown_timer <= 0:

			start_dodge()

	if is_dodging:

		velocity.x = facing_direction * dodge_speed


func start_dodge():

	is_dodging = true

	dodge_animation_playing = true

	dodge_timer = dodge_duration

	dodge_cooldown_timer = dodge_cooldown

	play_animation("dodge")

	print("PLAYER DODGING")


# ============================================================
# ATTACK
# ============================================================

func handle_attack():

	if is_hurt or is_dead:
		return

	if Input.is_action_just_pressed("attack"):

		start_attack()


func start_attack():

	if is_attacking or is_dodging or is_hurt or is_dead:
		return

	is_attacking = true

	print("PLAYER ATTACK")

	attack_hitbox.position.x = facing_direction * 35

	attack_hitbox.damage = attack_damage

	await attack_hitbox.start_attack()

	await get_tree().create_timer(attack_duration).timeout

	if is_dead:
		return

	attack_hitbox.end_attack()

	await get_tree().create_timer(attack_recovery).timeout

	if is_dead:
		return

	is_attacking = false


# ============================================================
# TAKE DAMAGE
# ============================================================

func take_damage(amount: int):

	if is_dead or current_health <= 0:
		return

	if is_dodging:

		print("PLAYER DODGED ATTACK")

		return

	if is_hurt:
		return

	current_health -= amount

	current_health = max(current_health, 0)

	print("PLAYER RECEIVED DAMAGE: ", amount)

	print("PLAYER HP: ", current_health)

	if current_health <= 0:

		die()

	else:

		is_hurt = true

		is_attacking = false

		attack_hitbox.end_attack()

		play_animation("take_damage")


# ============================================================
# DEATH
# ============================================================

func die():

	if is_dead:
		return

	is_dead = true

	is_hurt = false

	is_dodging = false

	dodge_animation_playing = false

	is_attacking = false

	current_health = 0

	velocity = Vector2.ZERO

	attack_hitbox.end_attack()

	play_animation("death")

	print("PLAYER DIED")

	set_physics_process(false)

	var fight = get_tree().get_first_node_in_group("boss_fight")

	if fight:

		fight.player_died()


# ============================================================
# ANIMATION CONTROL
# ============================================================

func update_animation():

	if is_dead:
		return

	# Damage animation has priority.
	if is_hurt:
		return

	# Let dodge animation finish naturally.
	if dodge_animation_playing:
		return

	# Update facing direction.
	if facing_direction != 0:

		animated_sprite.flip_h = facing_direction < 0

	# Running.
	if abs(velocity.x) > 5:

		play_animation("run")

	# Standing still.
	else:

		play_animation("idle")


func play_animation(animation_name: String):

	if animated_sprite.sprite_frames == null:
		return

	if not animated_sprite.sprite_frames.has_animation(animation_name):

		print("MISSING PLAYER ANIMATION: ", animation_name)

		return

	if animated_sprite.animation != animation_name:

		animated_sprite.play(animation_name)


# ============================================================
# ANIMATION FINISHED
# ============================================================

func _on_animation_finished():

	if is_dead:
		return

	if animated_sprite.animation == "take_damage":

		is_hurt = false

		print("PLAYER RECOVERED")

	elif animated_sprite.animation == "dodge":

		dodge_animation_playing = false

		print("PLAYER DODGE ANIMATION FINISHED")


# ============================================================
# TIMERS
# ============================================================

func update_timers(delta):

	# Dodge movement duration.
	if dodge_timer > 0:

		dodge_timer -= delta

		if dodge_timer <= 0:

			is_dodging = false

	# Dodge cooldown.
	if dodge_cooldown_timer > 0:

		dodge_cooldown_timer -= delta
