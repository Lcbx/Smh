extends State

const HITSTUN : StringName = "hitstun"

@export var acceleration : float = 100.0
@export var gravity : float = 1500.0
@export var friction_lerp : float = 3.0

var duration : float

func enter(...args) -> void:
	duration = args[0]
	print(duration)
	chtr.animate(HITSTUN, duration, 0.05)

func apply(delta: float) -> void:
	var accel := chtr.stick_direction * acceleration
	accel.y += gravity
	accel *= delta
	accel += Character.calculate_lerp_offset2(chtr.velocity, Vector2.ZERO, friction_lerp*delta)
	# false is to bounce on floor collision
	chtr.apply_movement(chtr.velocity, accel, delta, false)

func end()->void:
	#print('end speed ', chtr.velocity)
	if chtr.health <= 0.0: chtr.health = 50.0
	chtr.check_state()
