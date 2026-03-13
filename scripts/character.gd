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
@onready var PUNCH_STATE : Node2D = %PunchState

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
@onready var state = AIR_STATE
signal input

func _physics_process(delta: float) -> void:
	input.emit() # gather input
	state.apply(delta)

# framerate independent lerp
# use as a = const_lerp(a, b, speed * dt) each frame
# see https://www.youtube.com/watch?v=LSNQuFEDOyQ
static func const_lerp(a, b, amount:float):
	return lerp(a, b, 1-exp(-amount))
	
func is_grounded() -> bool:
	return ground_check.is_colliding()

func ground_distance() -> Vector2:
	return (ground_check.global_position + ground_check.target_position - ground_check.get_collision_point())

func apply_movement(speed : Vector2, half_acceleration : Vector2, max_horizontal_speed:float) -> void:
	# half acceleration before + after movement makes for a better integration of the force
	speed.y += half_acceleration.y
	speed.x = move_toward(speed.x, sign(half_acceleration.x) * max_horizontal_speed, abs(half_acceleration.x))
	velocity = speed
	
	# would help with DI while launched
	#if abs(velocity.x) > max_horizontal_speed:
	#	half_acceleration.x = - sign(velocity.x) * abs(half_acceleration.x)
	
	#print("accleration ", half_acceleration)
	#print("velocity ", velocity)
	#print("position ", position)
	move_and_slide()
	velocity += half_acceleration

func animate(anim_name:StringName, strength:float=1.0, blend_time:float = 0.1)->void:
	var speed = max(0.4, strength)
	#if anim_name != animation_player.current_animation:
	#	print(self.name, " play ", anim_name, "/", blend_time, "/", speed)
	animation_player.play(anim_name, blend_time, speed)
	animation_player.advance(0)

func enter(state : State, ...args)->void:
	self.state = state
	state.enter.callv(args)
	if Engine.is_in_physics_frame():
		state.apply(1.0/float(Engine.physics_ticks_per_second))

# TODO: check the command buffer and apply it in there ?
func check_state()->bool:
	var grounded = is_grounded()
	var _state := GROUND_STATE if grounded else AIR_STATE
	var different:bool = state != _state
	if different: enter(_state)
	return different

func jump(strength:float)->void:
	enter(JUMP_STATE, strength)

func teleport(tp_position : Vector2)->void:
	position = tp_position
	reset_physics_interpolation()
