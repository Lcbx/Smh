extends State

const JUMP : StringName = "jump"

@export var anim_speed := 3.0

var move := false
var strength:float

func enter(...args) -> void:
	#print("jump start ", chtr.jumps)
	strength = args[0]
	chtr.velocity.y = 0.0
	chtr.jumps -= 1
	move = false
	chtr.COYOTE_TIMER.stop()
	chtr.animate(JUMP,anim_speed)

# not a fan of this compromise
func start_moving():
	chtr.velocity.y = -strength
	move=true

func end()->void:
	chtr.check_state()

func apply(delta: float) -> void:
	if move:
		chtr.AIR_STATE.apply_movement(delta)
	else:
		# just the horizontal velocity while we are crouching before the jump
		chtr.move_and_slide()
