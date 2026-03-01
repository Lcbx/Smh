extends Node2D

@export var SPEED := 350.0
@export var JUMP_VELOCITY = 450.0
@export var ACCELERATION := 2000.0
const ON_GROUND_MARGIN := 10.0
const GROUND_DISPLACEMENT := 50.0
const FRICTION := 10.0


func apply(chtr : Character, delta: float) -> void:
	var grounded = chtr.is_grounded()
	if not grounded:
		chtr.state = %AirState
		chtr.state.apply(chtr, delta)
		return
	
	var acceleration := Vector2.ZERO
	var velocity := chtr.velocity
	var direction := chtr.stick_direction
	#if chtr.jump_requested: direction.y = -1
	
	velocity.x = chtr.const_lerp(velocity.x, 0.0, FRICTION * delta)
	acceleration.x += direction.x * ACCELERATION * delta
		
	var dist = chtr.ground_distance()
	if chtr.jump_requested:
		velocity.y = -JUMP_VELOCITY
	elif dist < ON_GROUND_MARGIN:
		velocity.y = 0.0
	else:
		velocity.y = -GROUND_DISPLACEMENT
	
	velocity.x = clampf(velocity.x, -SPEED, SPEED)
	chtr.apply_movement(velocity, acceleration)
	
	chtr.sprite.scale.x = sign(velocity.x) if velocity.x != 0.0 else chtr.sprite.scale.x
