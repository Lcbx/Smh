extends Node2D

@export var SPEED := 350.0
@export var MAX_FALL_SPEED := 300.0
@export var JUMP_VELOCITY = 500.0
@export var ACCELERATION := 1000.0
@export var GRAVITY := 500.0
@export var FRICTION := 0.5

#TODO: support double jump

func apply(chtr : Character, delta: float) -> void:
	var grounded = chtr.is_grounded()
	if grounded:
		chtr.state = %GroundedState
		chtr.state.apply(chtr, delta)
		return
	
	var acceleration := Vector2.ZERO
	var velocity := chtr.velocity
	var direction := chtr.stick_direction
	#if chtr.jump_requested: direction.y = -1
	
	velocity.x = chtr.const_lerp(velocity.x, 0.0, FRICTION * delta)
	acceleration.x += direction.x * ACCELERATION * delta
	
	#acceleration.y = GRAVITY * (1.0 + AIR_ACCELERATION / ACCELERATION * direction.y) * delta
	var modifier = 0.2 if sign(direction.y) < 0 else 0.6
	acceleration.y = GRAVITY * (1.0 + modifier * direction.y) * delta
	#acceleration.y = GRAVITY * delta
	
	velocity.x = clampf(velocity.x, -SPEED, SPEED)
	velocity.y = min(MAX_FALL_SPEED * (1.0 + 0.25 * direction.y), velocity.y)
	chtr.apply_movement(velocity, acceleration)
	
	chtr.sprite.scale.x = sign(velocity.x) if velocity.x != 0.0 else chtr.sprite.scale.x
