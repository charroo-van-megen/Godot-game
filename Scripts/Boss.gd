
extends CharacterBody2D


# ============================================================
# HEALTH
# ============================================================

@export var max_health: int = 1000

var current_health: int

var is_hurt: bool = false
var is_dead: bool = false


# ============================================================
# MOVEMENT
# ============================================================

@export var move_speed: float = 120.0
@export var gravity: float = 1200.0

@export var attack_range: float = 55.0
@export var vertical_attack_tolerance: float = 60.0

var facing_direction: float = -1.0


# ============================================================
# ATTACK
# ============================================================

@export var attack_damage: int = 100

@export var attack_cooldown: float = 1.5

@export var attack_windup: float = 0.35
@export var attack_active_time: float = 0.25
@export var attack_recovery: float = 0.5

@export var hitbox_offset: float = 35.0

var attack_cooldown_timer: float = 0.0

var is_attacking: bool = false


# ============================================================
# DEFENSE
# ============================================================

@export_range(0.0, 1.0) var parry_chance: float = 0.0
@export_range(0.0, 1.0) var dodge_chance: float = 0.0

@export var dodge_speed: float = 700.0
@export var dodge_duration: float = 0.2

var is_dodging: bool = false
var dodge_animation_playing: bool = false

var dodge_timer: float = 0.0


# ============================================================
# FIGHT
# ============================================================

var fight_active: bool = false

var player: CharacterBody2D


# ============================================================
# REFERENCES
# ============================================================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox


# ============================================================
# READY
# ============================================================

func _ready():

	add_to_group("boss")

	current_health = max_health

	collision_layer = 4
	collision_mask = 1

	attack_hitbox.damage = attack_damage

	attack_hitbox.end_attack()

	player = get_tree().get_first_node_in_group("player")

	animated_sprite.animation_finished.connect(
		_on_animation_finished
	)

	play_animation("idle")

	print("BOSS READY - WAITING FOR FIGHT")


# ============================================================
# PHYSICS
# ============================================================

func _physics_process(delta):

	if is_dead:
		return

	handle_gravity(delta)

	update_timers(delta)

	if not fight_active:

		velocity.x = move_toward(
			velocity.x,
			0,
			move_speed * 5.0 * delta
		)

	elif player == null:

		player = get_tree().get_first_node_in_group("player")

	elif is_attacking or is_hurt:

		velocity.x = move_toward(
			velocity.x,
			0,
			move_speed * 5.0 * delta
		)

	elif is_dodging:

		velocity.x = get_dodge_direction() * dodge_speed

	else:

		handle_combat()

	move_and_slide()

	update_animation()


# ============================================================
# START FIGHT
# ============================================================

func start_fight():

	if fight_active or is_dead:
		return

	fight_active = true

	attack_cooldown_timer = 0.5

	print("BOSS FIGHT STARTED")


# ============================================================
# STOP FIGHT
# ============================================================

func stop_fight():

	fight_active = false

	is_attacking = false

	is_dodging = false

	dodge_animation_playing = false

	attack_hitbox.end_attack()

	velocity.x = 0


# ============================================================
# GRAVITY
# ============================================================

func handle_gravity(delta):

	if not is_on_floor():

		velocity.y += gravity * delta

	elif velocity.y > 0:

		velocity.y = 0


# ============================================================
# COMBAT AI
# ============================================================

func handle_combat():

	var horizontal_distance = abs(
		player.global_position.x - global_position.x
	)

	var vertical_distance = abs(
		player.global_position.y - global_position.y
	)

	if vertical_distance > vertical_attack_tolerance:

		move_toward_player()

		return

	if horizontal_distance <= attack_range:

		velocity.x = 0

		try_attack()

	else:

		move_toward_player()


# ============================================================
# MOVEMENT
# ============================================================

func move_toward_player():

	var difference = player.global_position.x - global_position.x

	var direction = sign(difference)

	if direction != 0:

		facing_direction = direction

	velocity.x = direction * move_speed


# ============================================================
# ATTACK
# ============================================================

func try_attack():

	if attack_cooldown_timer > 0:
		return

	if is_attacking:
		return

	start_attack()


func start_attack():

	if is_attacking or is_dead:
		return

	is_attacking = true

	attack_cooldown_timer = attack_cooldown

	var direction = sign(
		player.global_position.x - global_position.x
	)

	if direction == 0:
		direction = facing_direction

	facing_direction = direction

	attack_hitbox.position.x = direction * hitbox_offset

	print("BOSS WINDUP")

	await get_tree().create_timer(attack_windup).timeout

	if not fight_active or is_dead:

		attack_hitbox.end_attack()

		is_attacking = false

		return

	print("BOSS ATTACK ACTIVE")

	await attack_hitbox.start_attack()

	if not fight_active or is_dead:

		attack_hitbox.end_attack()

		is_attacking = false

		return

	await get_tree().create_timer(attack_active_time).timeout

	attack_hitbox.end_attack()

	print("BOSS RECOVERY")

	await get_tree().create_timer(attack_recovery).timeout

	is_attacking = false


# ============================================================
# TAKE DAMAGE
# ============================================================

func take_damage(amount: int):

	if is_dead or current_health <= 0:
		return

	if not fight_active:
		return

	if randf() < parry_chance:

		print("BOSS PARRIED THE ATTACK")

		return

	if randf() < dodge_chance:

		print("BOSS DODGED THE ATTACK")

		start_boss_dodge()

		return

	if is_hurt:
		return

	var actual_damage = min(amount, current_health)

	current_health -= actual_damage

	print("BOSS RECEIVED DAMAGE: ", actual_damage)

	print("BOSS HP: ", current_health)

	var fight = get_tree().get_first_node_in_group("boss_fight")

	if fight:

		fight.register_damage_dealt(actual_damage)

	if current_health <= 0:

		die()

	else:

		is_hurt = true

		play_animation("take_damage")


# ============================================================
# BOSS DODGE
# ============================================================

func start_boss_dodge():

	if is_dodging or is_attacking or is_hurt:
		return

	is_dodging = true

	dodge_animation_playing = true

	dodge_timer = dodge_duration

	play_animation("dodge")

	print("BOSS DODGING")


func get_dodge_direction() -> float:

	if player == null:
		return 0.0

	var direction = sign(
		global_position.x - player.global_position.x
	)

	if direction == 0:
		direction = -facing_direction

	facing_direction = direction

	return direction


# ============================================================
# DEATH
# ============================================================

func die():

	if is_dead:
		return

	is_dead = true

	current_health = 0

	fight_active = false

	is_attacking = false

	is_dodging = false

	dodge_animation_playing = false

	velocity = Vector2.ZERO

	attack_hitbox.end_attack()

	play_animation("death")

	print("BOSS DEFEATED")

	set_physics_process(false)

	var fight = get_tree().get_first_node_in_group("boss_fight")

	if fight:

		fight.boss_defeated()


# ============================================================
# ANIMATION CONTROL
# ============================================================

func update_animation():

	if is_dead:
		return

	if is_hurt:
		return

	# Keep dodge animation playing until it finishes.
	if dodge_animation_playing:
		return

	if player != null:

		var difference = player.global_position.x - global_position.x

		if difference != 0:

			facing_direction = sign(difference)

	animated_sprite.flip_h = facing_direction < 0

	if is_attacking:

		play_animation("idle")

		return

	if abs(velocity.x) > 5:

		play_animation("run")

	else:

		play_animation("idle")


func play_animation(animation_name: String):

	if animated_sprite.sprite_frames == null:
		return

	if not animated_sprite.sprite_frames.has_animation(animation_name):

		print("MISSING BOSS ANIMATION: ", animation_name)

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

		print("BOSS RECOVERED")

	elif animated_sprite.animation == "dodge":

		dodge_animation_playing = false

		print("BOSS DODGE ANIMATION FINISHED")


# ============================================================
# TIMERS
# ============================================================

func update_timers(delta):

	if attack_cooldown_timer > 0:

		attack_cooldown_timer -= delta

	if dodge_timer > 0:

		dodge_timer -= delta

		if dodge_timer <= 0:

			is_dodging = false
