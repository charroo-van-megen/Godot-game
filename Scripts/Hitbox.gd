
extends Area2D

@export var damage: int = 10

var already_hit: Array[Area2D] = []
var attack_active: bool = false


func _ready():

	# Detect Hurtboxes on collision layer 4.
	collision_layer = 0
	collision_mask = 8

	monitoring = false

	if not area_entered.is_connected(_on_area_entered):

		area_entered.connect(_on_area_entered)


# ============================================================
# START ATTACK
# ============================================================

func start_attack():

	already_hit.clear()

	attack_active = true

	set_deferred("monitoring", true)

	print(get_parent().name, " HITBOX ACTIVATED")

	await get_tree().physics_frame

	if not attack_active:
		return

	# Check targets already inside the hitbox.
	for area in get_overlapping_areas():

		try_hit(area)


# ============================================================
# END ATTACK
# ============================================================

func end_attack():

	attack_active = false

	set_deferred("monitoring", false)

	print(get_parent().name, " HITBOX DEACTIVATED")


# ============================================================
# AREA ENTERED
# ============================================================

func _on_area_entered(area: Area2D):

	if not attack_active:
		return

	try_hit(area)


# ============================================================
# DAMAGE DETECTION
# ============================================================

func try_hit(area: Area2D):

	if not attack_active:
		return

	if area in already_hit:
		return

	# Prevent hitting our own Hurtbox.
	if area.get_parent() == get_parent():
		return

	if not area.has_method("take_damage"):
		return

	already_hit.append(area)

	print("HIT DETECTED: ", area.get_parent().name)

	area.take_damage(damage)
