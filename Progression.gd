
extends Node


# ============================================================
# PLAYER PROGRESSION
# ============================================================

var coins: int = 0


# ============================================================
# SAVE FILE
# ============================================================

const SAVE_PATH = "user://progression.cfg"


# ============================================================
# READY
# ============================================================

func _ready():

	load_progression()


# ============================================================
# ADD COINS
# ============================================================

func add_coins(amount: int):

	if amount <= 0:
		return

	coins += amount

	print("RECEIVED ", amount, " COINS")
	print("TOTAL COINS: ", coins)

	save_progression()


# ============================================================
# SPEND COINS
# ============================================================

func spend_coins(amount: int) -> bool:

	if amount <= 0:
		return false

	if coins < amount:

		print("NOT ENOUGH COINS")

		return false

	coins -= amount

	print("SPENT ", amount, " COINS")
	print("REMAINING COINS: ", coins)

	save_progression()

	return true


# ============================================================
# SAVE PROGRESSION
# ============================================================

func save_progression():

	var save_data = ConfigFile.new()

	save_data.set_value("Progression", "coins", coins)

	var error = save_data.save(SAVE_PATH)

	if error != OK:

		print("FAILED TO SAVE PROGRESSION")

	else:

		print("PROGRESSION SAVED")


# ============================================================
# LOAD PROGRESSION
# ============================================================

func load_progression():

	var save_data = ConfigFile.new()

	var error = save_data.load(SAVE_PATH)

	if error != OK:

		print("NO SAVE FILE FOUND - STARTING NEW GAME")

		coins = 0

		return

	coins = save_data.get_value(
		"Progression",
		"coins",
		0
	)

	print("PROGRESSION LOADED")
	print("COINS: ", coins)
