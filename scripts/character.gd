class_name Character
extends PhysicsBody2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var ground_check: RayCast2D = %ground_check
@onready var sprite: Node2D = %sprite
@onready var damage_sprite : Sprite2D = %dmgSprite
@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var GROUND_STATE : State = %GroundState
@onready var AIR_STATE : State = %AirState
@onready var JUMP_STATE : State = %JumpState
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
var velocity := Vector2.ZERO

var last_collision : KinematicCollision2D = null

# impulse from damage, applied in movement
var impulse := Vector2.ZERO

# all characters stocks start with 100 health
# damage is substracted to it
# the lower it is the more knockback is taken (but hitstun is not affected)
# once under 1 character is stunned for a while, before it resets to 50
var health := 100.0 :
	set(value):
		health_changed.emit(value)
		health = value
signal health_changed(value:float)

#TODO: create abstract class for State
@onready var _state = AIR_STATE
signal input

func _physics_process(delta: float) -> void:
	input.emit() # gather input
	_state.apply(delta)
	
func is_grounded() -> bool:
	return ground_check.is_colliding() and (ground_check.get_collider() as Character == null)

func apply_movement(speed : Vector2, acceleration : Vector2, delta:float, slide_else_bounce:bool=true) -> void:
	
	# apply last impulse
	speed += impulse
	impulse = Vector2.ZERO
	
	# half acceleration before + after movement makes for a better integration of the force
	var half_acceleration := acceleration * 0.5
	speed += half_acceleration
	
	#print(name, " accleration ", half_acceleration)
	#print(name, " velocity ", velocity)
	#print(name, " position ", position)
	
	# simple move_and_slide implementation 
	var move := speed * delta
	last_collision = move_and_collide(move)
	if last_collision:
		var remaining := last_collision.get_remainder()
		var normal := last_collision.get_normal()
		var second_move := normal * last_collision.get_depth()
		if slide_else_bounce:
			second_move += remaining.slide(normal)
		else:
			second_move += remaining.bounce(normal)
			speed = speed.bounce(normal)
			# try to avoid pinballing
			speed.x *= 0.4
			#half_acceleration = Vector2.ZERO
		move_and_collide(second_move)
	
	elif is_grounded():
		const ON_GROUND_MARGIN := 5.0
		const MANTLING_SLERP := 15.0
		var ground_dist : Vector2 = ground_check.global_position + ground_check.target_position - ground_check.get_collision_point()
		#print("ground_dist ", ground_dist)
		if ground_dist.y > ON_GROUND_MARGIN:
			#print("height adjustment !", ground_dist)
			# NOTE: target_pos is more or less constant throughout frames
			var target_pos := position.y - ground_dist.y
			var traveled := calculate_lerp_offset( position.y, target_pos, MANTLING_SLERP * delta)
			move_and_collide(Vector2(0, traveled))
	else:
		const DFLT_SHOVE_DIST := 100.0
		const SHOVE_SLERP := 3.0
		# if ground raycast is on other character, shove ourselves away 
		var char_collider := ground_check.get_collider() as Character
		if char_collider:
			var target_pos : Vector2 = position + sign(position - char_collider.position) * DFLT_SHOVE_DIST
			var traveled := self.calculate_lerp_offset2( position, target_pos, SHOVE_SLERP * delta)
			move_and_collide(traveled)
	
	velocity = speed + half_acceleration

func animate(anim_name:StringName, time:float=1.0, blend_time:float = 0.2)->void:
	var speed = 1.0 / max(time, 0.1) # speed is 1.0 / time if anim duration is 1. second
	#if anim_name != animation_player.current_animation:
	#	print(self.name, " play ", anim_name, "/", blend_time, "/", speed)
	animation_player.play(anim_name, blend_time, speed)
	#animation_player.advance(0)

func enter(state : State, ...args)->void:
	#print(name, ' ', state.name)
	self._state = state
	_state.enter.callv(args)
	#if Engine.is_in_physics_frame():
	#	_state.apply(1.0/float(Engine.physics_ticks_per_second))

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


# framerate independent lerp
# use as a = const_lerp(a, b, speed * dt) each frame
# see https://www.youtube.com/watch?v=LSNQuFEDOyQ
static func const_lerp2(a : Vector2, b : Vector2, amount:float) -> Vector2:
	return lerp(a, b, 1-exp(-amount))

static func const_lerp(a:float, b:float, amount:float)->float:
	return lerpf(a, b, 1-exp(-amount))
	
static func calculate_lerp_offset2(from:Vector2, to:Vector2, amount:float) -> Vector2:
	return const_lerp2(from, to, amount) - from

static func calculate_lerp_offset(from:float, to:float, amount:float) -> float:
	return const_lerp(from, to, amount) - from
