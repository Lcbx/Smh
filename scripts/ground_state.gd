extends State

@export var SPEED := 550.0
@export var MIN_SPEED := 200.0
@export var JUMP_HEIGHT := 165
@export var ACCELERATION_LERP := 5.0

const ON_GROUND_MARGIN := 5.0
const MANTLING_SLERP := 15.0

const IDLE : StringName = "idle"
const WALK : StringName = "walk"

@onready var PUNCH_STATE : Node2D = %PunchState

@onready var JUMP_IMPULSE : float = %AirState.calculate_jump_impulse(JUMP_HEIGHT)

func enter(..._args) -> void:
	chtr.COYOTE_TIMER.stop()
	chtr.jumps = chtr.MAX_JUMPS
	chtr.unused_wall_jump = true

func apply(delta: float) -> void:
	if chtr.check_state():
		chtr.COYOTE_TIMER.start()
		return
	
	#print("ground")
	apply_movement(delta)
	
	if chtr.jump_requested:
		chtr.jump(JUMP_IMPULSE)
		return
		
	if chtr.attack_requested:
		chtr.enter(PUNCH_STATE)
		return
	
	apply_animation(chtr.velocity)
	

func apply_movement(delta:float)->void:
	var acceleration := Vector2.ZERO
	var velocity := chtr.velocity
	var direction := chtr.stick_direction
	#if chtr.jump_requested: direction.y = -1
	
	if velocity.x * direction.x < MIN_SPEED:
		velocity.x = direction.x * MIN_SPEED
	acceleration.x = Character.caculate_lerp_offset(velocity.x, SPEED * direction.x, ACCELERATION_LERP * delta)
	
	var dist : Vector2 = chtr.ground_distance()
	if absf(dist.y) > ON_GROUND_MARGIN:
		# NOTE: target_pos is more or less constant throughout frames
		var target_pos := chtr.position - dist
		#print("target_pos", target_pos)
		var traveled : Vector2 = Character.const_lerp( chtr.position, target_pos, MANTLING_SLERP * delta) - chtr.position
		chtr.move_and_collide(traveled)
	
	velocity.y = 0.0
	chtr.apply_movement(velocity, acceleration, SPEED)
	

func apply_animation(velocity:Vector2)->void:
	
	if velocity.x != 0.0:
		chtr.flipped = velocity.x < 0.0	
	
	var walk_blend := absf(velocity.x) / SPEED
	if walk_blend < 0.2:
		chtr.animate(IDLE, 1.0 - walk_blend)
	else:
		chtr.animate(WALK, walk_blend)
