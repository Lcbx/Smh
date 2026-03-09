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
var jumps : int = MAX_JUMPS

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

#NOTE: maybe restore a jump on first collision with the side of the arena

# framerate independent lerp
# use as a = const_lerp(a, b, speed * dt) each frame
# see https://www.youtube.com/watch?v=LSNQuFEDOyQ
static func const_lerp(a, b, amount:float):
	return lerp(a, b, 1-exp(-amount))
	
func is_grounded() -> bool:
	return ground_check.is_colliding()

func ground_distance() -> float:
	return (ground_check.global_position + ground_check.target_position - ground_check.get_collision_point()).y

func apply_movement(speed : Vector2, half_acceleration : Vector2, max_horizontal_speed := 1000.0 ) -> void:
	# half acceleration before + after movement makes for a better integration of the force
	speed = speed + half_acceleration
	speed.x = clampf(speed.x, -max_horizontal_speed, max_horizontal_speed)
	velocity = speed
	#print("velocity ", velocity)
	#print("position ", position)
	move_and_slide()
	velocity += half_acceleration

func animate(name:StringName, strength:float=1.0)->void:
	var speed = max(0.4, strength)
	var blend = lerp(0.0, 1.0, strength)
	animation_player.play(name, blend, speed)
	#print("play", name, blend, speed)

func enter(state, delta:float = 0.0)->void:
	self.state = state
	state.enter()
	if delta != 0.0:
		state.apply(delta)

# might be made obsolete by command buffer implementation
func check_state(delta:float)->bool:
	var grounded = is_grounded()
	var _state := GROUND_STATE if grounded else AIR_STATE
	var different:bool= state != _state
	if different: enter(_state, delta)
	return different

func jump(strength:float)->void:
	velocity.y = -strength
	enter(JUMP_STATE)
