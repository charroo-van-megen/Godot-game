
extends Node


# ============================================================
# SETTINGS
# ============================================================

@export var interaction_distance: float = 120.0

@export var base_reward: int = 5

@export var survival_reward_interval: float = 10.0

@export var damage_reward_interval: int = 50

@export var boss_defeat_bonus: int = 50

@export var restart_delay: float = 2.0


# ============================================================
# REFERENCES
# ============================================================

var player: CharacterBody2D
var boss: CharacterBody2D


# ============================================================
# FIGHT DATA
# ============================================================

var fight_active: bool = false
var fight_ended: bool = false

var fight_start_time: int = 0

var damage_dealt: int = 0


# ============================================================
# READY
# ============================================================

func _ready():

	add_to_group("boss_fight")

	call_deferred("find_characters")


func find_characters():

	player = get_tree().get_first_node_in_group("player")

	boss = get_tree().get_first_node_in_group("boss")


# ============================================================
# INTERACTION
# ============================================================

func _process(_delta):

	if fight_active or fight_ended:
		return

	if player == null or boss == null:

		find_characters()

		return

	var distance = player.global_position.distance_to(
		boss.global_position
	)

	if distance <= interaction_distance:

		if Input.is_action_just_pressed("interact"):

			start_fight()


# ============================================================
# START FIGHT
# ============================================================

func start_fight():

	if fight_active or fight_ended:
		return

	if boss == null:
		return

	fight_active = true

	fight_start_time = Time.get_ticks_msec()

	damage_dealt = 0

	boss.start_fight()

	print("==============================")
	print("FIGHT STARTED")
	print("==============================")


# ============================================================
# REGISTER DAMAGE
# ============================================================

func register_damage_dealt(amount: int):

	if not fight_active:
		return

	damage_dealt += amount


# ============================================================
# SURVIVAL TIME
# ============================================================

func get_survival_time() -> float:

	if fight_start_time == 0:
		return 0.0

	var elapsed = Time.get_ticks_msec() - fight_start_time

	return elapsed / 1000.0


# ============================================================
# CALCULATE REWARD
# ============================================================

func calculate_reward(boss_defeated: bool) -> int:

	var survival_time = get_survival_time()

	var survival_reward = int(
		survival_time / survival_reward_interval
	)

	var damage_reward = int(
		damage_dealt / damage_reward_interval
	)

	var reward = base_reward + survival_reward + damage_reward

	if boss_defeated:

		reward += boss_defeat_bonus

	return reward


# ============================================================
# END FIGHT
# ============================================================

func end_fight(boss_defeated: bool):

	if fight_ended:
		return

	fight_ended = true

	fight_active = false

	var survival_time = get_survival_time()

	var reward = calculate_reward(boss_defeated)

	print("==============================")
	print("FIGHT FINISHED")
	print("SURVIVAL TIME: ", survival_time)
	print("DAMAGE DEALT: ", damage_dealt)
	print("REWARD: ", reward, " COINS")
	print("==============================")

	# Save the reward permanently.
	Progression.add_coins(reward)

	if boss:

		boss.stop_fight()

	# Wait before restarting.
	await get_tree().create_timer(restart_delay).timeout

	# Reload the World.
	get_tree().reload_current_scene()


# ============================================================
# PLAYER DIED
# ============================================================

func player_died():

	if not fight_active:
		return

	print("PLAYER LOST")

	end_fight(false)


# ============================================================
# BOSS DEFEATED
# ============================================================

func boss_defeated():

	if not fight_active:
		return

	print("BOSS DEFEATED!")

	end_fight(true)
