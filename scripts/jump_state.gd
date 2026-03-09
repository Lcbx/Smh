extends Node2D

const JUMP : StringName = "jump"

@onready var chtr : Character = get_parent()

@export var anim_speed := 3.0

var move := false
var initial_velocity:Vector2

func enter() -> void:
	#print("jump start ", chtr.jumps)
	chtr.jumps -= 1
	move = false
	initial_velocity = chtr.velocity
	chtr.velocity = Vector2(initial_velocity.x, 0.0)
	chtr.COYOTE_TIMER.stop()
	chtr.animate(JUMP,anim_speed)
	chtr.animation_player.animation_finished.connect(self.end,ConnectFlags.CONNECT_ONE_SHOT)

# not a fan of this compromise
func start_moving():
	chtr.velocity = initial_velocity
	move=true

func end(anim_name:StringName)->void:
	if anim_name == JUMP:
		chtr.sprite.position = Vector2.ZERO
		chtr.enter(chtr.AIR_STATE)

func apply(delta: float) -> void:
	if move:
		chtr.AIR_STATE.apply_movement(delta)
	else:
		# just the horizontal velocity while we are crouching before the jump
		chtr.move_and_slide()
