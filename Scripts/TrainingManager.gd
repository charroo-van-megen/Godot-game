extends Node


# ============================================================
# TRAINING
# ============================================================

var training_time: float = 0.0

var training_required: float = 1200.0

var is_training: bool = false


# ============================================================
# PHYSICS
# ============================================================

func _process(delta):

	if not is_training:

		return


	training_time += delta


	print(
		"Training: ",
		training_time,
		"/",
		training_required
	)


	if training_time >= training_required:

		complete_training()


# ============================================================
# START TRAINING
# ============================================================

func start_training():

	if is_training:

		return


	is_training = true

	training_time = 0.0


	print("Training started.")


# ============================================================
# STOP TRAINING
# ============================================================

func stop_training():

	is_training = false


# ============================================================
# COMPLETE
# ============================================================

func complete_training():

	is_training = false

	training_time = training_required

	print("ABILITY TRAINING COMPLETE!")
