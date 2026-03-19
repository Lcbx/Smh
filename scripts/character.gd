class_name Character
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var ground_check: RayCast2D = %ground_check
@onready var sprite: Node2D = %sprite
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D

@onready var GROUND_STATE : Node2D = %GroundState
@onready var AIR_STATE : Node2D = %AirState
@onready var JUMP_STATE : Node2D = %JumpState
@onready var COYOTE_TIMER : Timer = %CoyoteTime

@export var MAX_JUMPS := 2
var unused_wall_jump := true
var jumps : int = MAX_JUMPS :
	set(value):
		jumps = mini(value, MAX_JUMPS)

func _ready() -> void:
	animation_player.play("idle")
	COYOTE_TIMER.timeout.connect(AIR_STATE.on_coyote_timer_end)

var stick_direction := Vector2.ZERO
var jump_requested := false
var attack_requested := false
var special_requested := false

#TODO: create abstract class for State
@onready var _state = AIR_STATE
signal input

func _physics_process(delta: float) -> void:
	input.emit() # gather input
	_state.apply(delta)

# framerate independent lerp
# use as a = const_lerp(a, b, speed * dt) each frame
# see https://www.youtube.com/watch?v=LSNQuFEDOyQ
static func const_lerp2(a : Vector2, b : Vector2, amount:float) -> Vector2:
	return lerp(a, b, 1-exp(-amount))

static func const_lerpf(a:float, b:float, amount:float)->float:
	return lerpf(a, b, 1-exp(-amount))
	
static func caculate_lerp_offset2(from:Vector2, to:Vector2, amount:float) -> Vector2:
	return const_lerp2(from, to, amount) - from

static func caculate_lerp_offset(from:float, to:float, amount:float) -> float:
	return const_lerpf(from, to, amount) - from
	
func is_grounded() -> bool:
	return ground_check.is_colliding()

func ground_distance() -> Vector2:
	return (ground_check.global_position + ground_check.target_position - ground_check.get_collision_point())

func apply_movement(speed : Vector2, acceleration : Vector2, max_horizontal_speed:float) -> void:
	# half acceleration before + after movement makes for a better integration of the force
	var half_acceleration := acceleration * 0.5
	speed += impulse
	impulse = Vector2.ZERO
	speed.y += half_acceleration.y
	speed.x = move_toward(speed.x, sign(half_acceleration.x) * max_horizontal_speed, abs(half_acceleration.x))
	velocity = speed
	
	#print("accleration ", half_acceleration)
	#print("velocity ", velocity)
	#print("position ", position)
	move_and_slide()
	velocity += half_acceleration

func animate(anim_name:StringName, strength:float=1.0, blend_time:float = 0.2)->void:
	var speed = max(0.4, strength)
	#if anim_name != animation_player.current_animation:
	#	print(self.name, " play ", anim_name, "/", blend_time, "/", speed)
	animation_player.play(anim_name, blend_time, speed)
	animation_player.advance(0)

func enter(state : State, ...args)->void:
	self._state = state
	_state.enter.callv(args)
	if Engine.is_in_physics_frame():
		_state.apply(1.0/float(Engine.physics_ticks_per_second))

# TODO: check the command buffer and apply it in there ?
func check_state()->bool:
	var grounded = is_grounded()
	var state := GROUND_STATE if grounded else AIR_STATE
	var different:bool = _state != state
	if different: self.enter(state)
	return different

func jump(strength:float)->void:
	enter(JUMP_STATE, strength)

func teleport(tp_position : Vector2)->void:
	position = tp_position
	reset_physics_interpolation()

var flipped : bool :
	get():
		return flipped
	set(value):
		flipped = value
		## NOTE: flipping collision using scale might be bad for physics
		collision.scale.x = -1.0 if value else 1.0


# all characters have 100 total health
# damage is substracted to it
# the lower it is the more knockback is taken (but hitstun is not affected)
var health := 100.0

# impulse from damage, applied in movement
var impulse := Vector2.ZERO

# TODO :
# * add hitstun state / calculate hitstun duration
# * pass damage to state for hyperarmor application (or just set hyperarmor as character attribute)
# * add hard stun when health dips under 0
func receive_damage(power:float, dir:Vector2)->void:
	health -= power
	var impulse_value = (200.0 - health) * 0.1 * power * power
	impulse += dir * impulse_value
	#print('health ', health, ' impulse ', impulse)
