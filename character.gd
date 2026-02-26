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

@export var SPEED = 250.0
@export var CONTROL = 20.0
@export var AIR_CONTROL = 9.0
@export var JUMP_VELOCITY = 330.0
@export var GRAVITY = 80.0
const ON_GROUND_MARGIN = 10.0

var grounded : bool = false
var direction := Vector2.ZERO


# TODO: move input out of charcter
func _physics_process(delta: float) -> void:
	grounded = ground_check.is_colliding()
	var accel = (CONTROL if grounded else AIR_CONTROL) * delta
	var gravity_accel = GRAVITY * 0.5 * delta

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
			velocity.y = -GRAVITY*0.5
		#print("dist ", dist)
	else:
		velocity.y += gravity_accel
		var y_dir = -1.0 if Input.is_action_pressed("ui_accept") else direction.y
		velocity.y = const_lerp(velocity.y, velocity.y + GRAVITY * (1 + 0.5 * y_dir), accel)

	move_and_slide()
	
