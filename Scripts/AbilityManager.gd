extends Node


# ============================================================
# PLAYER UPGRADES
# ============================================================

var health_bonus: int = 0

var damage_bonus: int = 0

var speed_bonus: float = 0.0

var dodge_bonus: float = 0.0


# ============================================================
# GET HEALTH
# ============================================================

func get_max_health(base_health: int) -> int:

	return base_health + health_bonus


# ============================================================
# GET DAMAGE
# ============================================================

func get_attack_damage(base_damage: int) -> int:

	return base_damage + damage_bonus


# ============================================================
# GET SPEED
# ============================================================

func get_move_speed(base_speed: float) -> float:

	return base_speed + speed_bonus


# ============================================================
# ADD HEALTH
# ============================================================

func increase_health(amount: int):

	health_bonus += amount

	print(
		"Health increased by ",
		amount
	)


# ============================================================
# ADD DAMAGE
# ============================================================

func increase_damage(amount: int):

	damage_bonus += amount

	print(
		"Damage increased by ",
		amount
	)


# ============================================================
# ADD SPEED
# ============================================================

func increase_speed(amount: float):

	speed_bonus += amount

	print(
		"Movement speed increased by ",
		amount
	)
