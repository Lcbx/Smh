class_name Character
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var ground_check: RayCast2D = %ground_check
@onready var sprite: Node2D = %sprite
@onready var collision: Node2D = $CollisionPolygon2D

func _ready() -> void:
	animation_player.play("idle")

var stick_direction := Vector2.ZERO
var jump_requested := false
var acceleration := Vector2.ZERO

#TODO: create abstract class for State
@onready var state = %GroundState
signal input

func _physics_process(delta: float) -> void:
	input.emit() # gather input
	state.apply(self, delta)

# framerate independent lerp
# use as a = const_lerp(a, b, speed * dt) each frame
# see https://www.youtube.com/watch?v=LSNQuFEDOyQ
static func const_lerp(a, b, amount):
	return lerp(a, b, 1-exp(-amount))
	
func is_grounded():
	return ground_check.is_colliding()

func ground_distance() -> float:
	return (ground_check.global_position + ground_check.target_position - ground_check.get_collision_point()).y

func apply_movement(speed : Vector2, half_acceleration : Vector2, max_horizontal_speed := 1000.0 ) -> void:
	# half acceleration before + after movement makes for a better integration of the force
	speed = speed + half_acceleration
	speed.x = clampf(speed.x, -max_horizontal_speed, max_horizontal_speed)
	velocity = speed
	#print("velocity", velocity)
	move_and_slide()
	velocity += half_acceleration

var swap := false
func animate(name:String, strength:float=1.0)->void:
	var speed = lerp(0.4, 1.0, strength)
	var blend = lerp(0.0, 1.0, strength)
	animation_player.play(name, blend, speed)
	#print("play", name, blend, speed)
