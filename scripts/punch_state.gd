extends State

@export var friction : float = 700.0
@export var time : float = 0.3

const PUNCH : StringName = "punch"

@onready var dmgArea:DmgArea = $dmgArea2D

func _ready() -> void:
	dmgArea.register(chtr)

#var start : int
func enter(..._args)->void:
	#start = Time.get_ticks_msec()
	chtr.animate(PUNCH, time, 0.0)
	#print(chtr.name, " punches")

func end()->void:
	chtr.check_state()
	dmgArea.clearVictims()
	#print("elapsed ", Time.get_ticks_msec() - start)

func apply(delta: float)->void:
	#var accel = Vector2( Character.calculate_lerp_offset(chtr.velocity.x, 0.0, friction_lerp * delta), 0.0)
	var speed := chtr.velocity
	chtr.apply_movement(speed, Vector2( -signf(speed.x) * friction * delta, 0.0), delta)
