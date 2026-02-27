extends CharacterBody2D

# framerate independent lerp
# use as a = const_lerp(a, b, speed * dt) each frame
# see https://www.youtube.com/watch?v=LSNQuFEDOyQ
static func const_lerp(a, b, amount):
	return lerp(a, b, 1-exp(-amount))
	
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ground_check: RayCast2D = $ground_check
@onready var sprite: Node2D = $sprite


func _ready() -> void:
	animation_player.play("idle")

@export var SPEED := 350.0
@export var CONTROL := 20.0
@export var AIR_CONTROL := 10.0
@export var GRAVITY := 500.0
@export var MAX_FALL_SPEED := 250.0
@export var JUMP_VELOCITY = 400.0
const ON_GROUND_MARGIN := 10.0

var grounded : bool = false
var direction := Vector2.ZERO


# TODO: move input out of charcter
func _physics_process(delta: float) -> void:
	grounded = ground_check.is_colliding()
	var accel := (CONTROL if grounded else AIR_CONTROL) * delta

	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	sprite.scale.x = sign(velocity.x) if velocity.x != 0.0 else sprite.scale.x
	
	velocity.x = const_lerp(velocity.x, direction.x * SPEED, accel)
		
	if grounded:
		var dist = ground_check.global_position + ground_check.target_position - ground_check.get_collision_point()
		if Input.is_action_pressed("ui_accept"):
			velocity.y = -JUMP_VELOCITY
			grounded = false
		elif dist.length_squared() < ON_GROUND_MARGIN:
			velocity.y = 0.0
		else:
			velocity.y = -MAX_FALL_SPEED
		#print("dist ", dist)
		move_and_slide()
	else:
		var y_dir := -1.0 if Input.is_action_pressed("ui_accept") else direction.y
		var gravity_accel := GRAVITY * (1.0 + 0.5 * y_dir) * delta
		# applying half acceleration before + after movement makes for a better integration of the force
		velocity.y += gravity_accel
		velocity.y = min(MAX_FALL_SPEED * (1.0 + 0.34 * y_dir), velocity.y)
		move_and_slide()
		velocity.y += gravity_accel

	
