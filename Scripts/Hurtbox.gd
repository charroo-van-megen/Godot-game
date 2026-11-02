
extends Area2D


func _ready():

	# Collision layer 4.
	collision_layer = 8

	# Hurtboxes don't need their own detection.
	collision_mask = 0

	monitorable = true


func take_damage(amount: int):

	var character = get_parent()

	if character.has_method("take_damage"):

		character.take_damage(amount)
