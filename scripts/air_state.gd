extends State

@export var SPEED := 400.0
@export var ACCELERATION_LERP := 3.0

@export var JUMP_HEIGHT := 250
@export var JUMP_RISING_TIME := 0.8
@export var JUMP_FALL_TIME := 0.55

var JUMP_IMPULSE : float
var RISING_GRAVITY : float
var FALL_GRAVITY : float
var MAX_FALL_SPEED : float

const AIRBORNE : StringName = "airborne"

#/* calculate secondary constants */
func _enter_tree() -> void:
	#jump_air_time = target_jump_max_distance / top_speeds[Character.MovementEnum.run]
	RISING_GRAVITY = (2*JUMP_HEIGHT)/pow(JUMP_RISING_TIME,2)
	FALL_GRAVITY = (2*JUMP_HEIGHT)/pow(JUMP_FALL_TIME,2)
	JUMP_IMPULSE = calculate_jump_impulse(JUMP_HEIGHT) #RISING_GRAVITY * JUMP_RISING_TIME
	MAX_FALL_SPEED = FALL_GRAVITY * JUMP_FALL_TIME

func calculate_jump_impulse(jump_height:float) ->float:
	return sqrt( 2. * RISING_GRAVITY * jump_height )

func enter(...args)->void:
	pass

func on_coyote_timer_end()->void:
	#print("coyote timer end")
	chtr.jumps -= 1

func apply(delta: float) -> void:
	if chtr.check_state(): return
	#print("air")
	apply_animation(chtr.velocity)
	
	#if chtr.attack_requested:
	#	chtr.velocity = Vector2.RIGHT.rotated(deg_to_rad(-45)) * 800.0
	
	if chtr.jumps > 0 and chtr.jump_requested:
		chtr.jump(JUMP_IMPULSE)
		return
	
	apply_movement(delta)

func apply_movement(delta: float)->void:
	
	# restores a jump on the first wall collision of an aerial maneuver
	if (chtr.unused_wall_jump
		and chtr.jumps < chtr.MAX_JUMPS
		and chtr.get_slide_collision_count() > 0
		and abs(chtr.get_last_slide_collision().get_normal().dot(Vector2.RIGHT)) > 0.5
	):
		#print("restoring jump")
		chtr.unused_wall_jump = false
		chtr.jumps += 1
	
	var velocity := chtr.velocity
	var acceleration := Vector2.ZERO
	var direction := chtr.stick_direction
	#if chtr.jump_requested: direction.y = -1
	
	acceleration.x = chtr.const_lerp(velocity.x, SPEED * direction.x, ACCELERATION_LERP * delta) - velocity.x
	
	var floatiness_modifier := 0.1 if sign(direction.y) < 0 else 0.5
	var gravity := RISING_GRAVITY if velocity.y < 0 else FALL_GRAVITY
	acceleration.y = gravity * (1.0 + floatiness_modifier * direction.y) * delta
	
	velocity.y = min(MAX_FALL_SPEED, velocity.y)
	chtr.apply_movement(velocity, acceleration, SPEED)

func apply_animation(velocity:Vector2)->void:
	chtr.sprite.scale.x = sign(velocity.x) if velocity.x != 0.0 else chtr.sprite.scale.x
	chtr.animate(AIRBORNE)
