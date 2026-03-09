extends Node2D

@export var SPEED := 450.0
@export var JUMP_HEIGHT := 250
@export var ACCELERATION := 2000.0
const ON_GROUND_MARGIN := 5.0
const GROUND_DISPLACEMENT := 300.0
const FRICTION := 1000.0

const IDLE : StringName = "idle"
const WALK : StringName = "walk"

@onready var chtr : Character = get_parent()
@onready var JUMP_IMPULSE : float = %AirState.calculate_jump_impulse(JUMP_HEIGHT)

func enter() -> void:
	chtr.COYOTE_TIMER.stop()
	chtr.jumps = chtr.MAX_JUMPS

func apply(delta: float) -> void:
	if chtr.check_state(delta):
		chtr.COYOTE_TIMER.start()
		return
	
	#print("ground")
	
	apply_animation(chtr.velocity)
	
	var acceleration := Vector2.ZERO
	var velocity := chtr.velocity
	var direction := chtr.stick_direction
	#if chtr.jump_requested: direction.y = -1
	
	if abs(direction.x) <= 0.1:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
	else: acceleration.x += direction.x * ACCELERATION * delta
	
	var dist = chtr.ground_distance()
	if chtr.jump_requested:
		chtr.jump(JUMP_IMPULSE)
		return
	elif dist < ON_GROUND_MARGIN:
		velocity.y = 0.0
	else:
		velocity.y = -GROUND_DISPLACEMENT
	
	chtr.apply_movement(velocity, acceleration, SPEED)
	

func apply_animation(velocity:Vector2)->void:
	var flip := float(sign(velocity.x)) if velocity.x != 0.0 else chtr.sprite.scale.x
	chtr.sprite.scale.x = flip
	chtr.collision.scale.x = flip
	
	var walk_blend := absf(velocity.x) / SPEED
	if walk_blend < 0.1:
		chtr.animate(IDLE, 1.0 - walk_blend)
	else:
		chtr.animate(WALK, walk_blend)
