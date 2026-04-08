extends State

const HITSTUN : StringName = "hitstun"

@export var acceleration : float = 100.0

@export var friction : float = 700.0
var duration : float

func enter(...args) -> void:
	duration = args[0]
	#print(duration)
	chtr.animate(HITSTUN, duration, 0.05)

func apply(delta: float) -> void:
	# TODO : bounce on floor collision (use groundcheck raycast for ground bounce)
	var accel := chtr.stick_direction * acceleration
	accel.y += chtr.AIR_STATE.RISING_GRAVITY
	accel *= delta
	chtr.apply_movement(chtr.velocity, accel, delta, false)
	if chtr.is_grounded():
		chtr.ground_repulsion(delta)

func end()->void:
	#print('end speed ', chtr.velocity)
	if chtr.health < 0.0: chtr.health = 50.0
	chtr.check_state()
