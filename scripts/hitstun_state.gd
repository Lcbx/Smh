extends State

const HITSTUN : StringName = "hitstun"

@export var friction : float = 700.0
var duration : float

func enter(...args) -> void:
	duration = args[0]
	#print(duration)
	chtr.animate(HITSTUN, duration, 0.05)

func apply(delta: float) -> void:
	# TODO : bounce on surface collision (dont forget to use ground check for ground bounce)
	
	#var velocity = chtr.velocity
	# !!! ground repulsion has very weird behaviour
	#chtr.ground_repulsion(delta)
	chtr.AIR_STATE.apply_movement(delta)
	#chtr.apply_movement(velocity, Vector2.ZERO, 0.0)
	#chtr.move_and_slide()
	#print('applied ', chtr.velocity)


func end()->void:
	#print('end speed ', chtr.velocity)
	if chtr.health < 0.0: chtr.health = 50.0
	chtr.check_state()
