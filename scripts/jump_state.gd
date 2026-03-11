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
	chtr.animation_player.animation_finished.connect(self.end,ConnectFlags.CONNECT_ONE_SHOT)

# not a fan of this compromise
func start_moving():
	chtr.velocity.y = -strength
	move=true

func end(anim_name:StringName)->void:
	if anim_name == JUMP:
		chtr.sprite.position = Vector2.ZERO
		#chtr.state = chtr.AIR_STATE # bypass enter()
		chtr.enter(chtr.AIR_STATE)

func apply(delta: float) -> void:
	if move:
		chtr.AIR_STATE.apply_movement(delta)
	else:
		# just the horizontal velocity while we are crouching before the jump
		chtr.move_and_slide()
