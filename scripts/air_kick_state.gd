extends State

@export var friction_lerp : float = 2.0
#@export var min_speed : float = 200.0
@export var cruise_speed : float = 1200.0

const AIRKICK : StringName = "airkick"


# TODO: stop momentum or seek animation end when we detect ground / deal damage
# allow jumping once character hasn started moving ?
# restore a jump mid-move ?

#@onready var dmgArea:DmgArea = $dmgArea2D

var direction : Vector2
var move := false

func _ready() -> void:
	#dmgArea.register(chtr)
	move = false

#var start : int
func enter(..._args)->void:
	#start = Time.get_ticks_msec()
	chtr.animate(AIRKICK, 2.0, 0.0)
	
	direction = chtr.stick_direction
	
	# align character to direction
	if direction.x != 0:
		chtr.flipped = direction.x < 0.0
	direction.x *= 0.7
	direction.y = 1
	direction = direction.normalized()
	#print("direction ", direction)
	var angle := -deg_to_rad(direction.x * 40)
	chtr.collision.rotation = angle

func start_moving():
	chtr.impulse = cruise_speed * direction
	move = true

func end()->void:
	chtr.collision.rotation = 0.0
	chtr.check_state()
	#print("elapsed ", Time.get_ticks_msec() - start)

func apply(_delta: float)->void:
	var speed := chtr.velocity
	#var offset := (#Vector2.ZERO if move else
	#Character.caculate_lerp_offset2(speed, sign(chtr.stick_direction) * min_speed, friction_lerp*delta))
	#chtr.apply_movement(speed, offset, min_speed)
	chtr.apply_movement(speed, Vector2.ZERO, 0.0)
	
