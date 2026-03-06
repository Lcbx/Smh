extends Node2D

@export var SPEED := 350.0
@export var MAX_FALL_SPEED := 300.0
@export var ACCELERATION := 1000.0
@export var GRAVITY := 500.0
@export var FRICTION := 0.5

#TODO expose jump height and air time instead of GRAVITY and JUMP_IMPULSE
#TODO: support double jump

func apply(chtr : Character, delta: float) -> void:
	var grounded = chtr.is_grounded()
	if grounded:
		chtr.state = %GroundState
		chtr.state.apply(chtr, delta)
		return
	
	#print("air")
	
	var acceleration := Vector2.ZERO
	var velocity := chtr.velocity
	var direction := chtr.stick_direction
	#if chtr.jump_requested: direction.y = -1
	
	velocity.x = Character.const_lerp(velocity.x, 0.0, FRICTION * delta)
	acceleration.x += direction.x * ACCELERATION * delta
	
	var floatiness_modifier := 0.1 if sign(direction.y) < 0 else 1.0
	acceleration.y = GRAVITY * (1.0 + floatiness_modifier * direction.y) * delta
	
	velocity.y = min(MAX_FALL_SPEED, velocity.y)
	chtr.apply_movement(velocity, acceleration, SPEED)
	
	chtr.sprite.scale.x = sign(velocity.x) if velocity.x != 0.0 else chtr.sprite.scale.x
