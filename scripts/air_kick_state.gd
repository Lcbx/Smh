extends State

@export var lerp_strength : float = 7.0
@export var start_speed : float = 300.0
@export var cruise_speed : float = 1500.0
@export var ending_lag : float = 0.05
@export var time = 0.5

const AIRKICK : StringName = "airkick"


# TODO: stop momentum or seek animation end when we detect ground / deal damage
# allow jumping once character hasn started moving ?
# restore a jump mid-move ?

#@onready var dmgArea:DmgArea = $dmgArea2D

var direction : Vector2
var move: bool

func _ready() -> void:
	#dmgArea.register(chtr)
	pass

#var start : int
func enter(..._args)->void:
	#start = Time.get_ticks_msec()
	
	move = false
	chtr.animate(AIRKICK, time, 0.0)
	
	var dir := chtr.stick_direction
	
	# align character to direction
	if dir.x != 0:
		chtr.flipped = dir.x < 0.0
	
	direction.x = (-1.0 if chtr.flipped else 1.0) * clampf(absf(dir.x), 0.15, 0.7)
	direction.y = 1
	direction = direction.normalized()
	#print("direction ", direction)
	
	var angle := -deg_to_rad(dir.x * 23.0)
	chtr.collision.rotation = angle

func start_moving():
	chtr.impulse = start_speed * direction
	#chtr.velocity = start_speed * direction
	move = true

func end()->void:
	chtr.collision.rotation = 0.0
	chtr.check_state()
	#print("elapsed ", Time.get_ticks_msec() - start)

func apply(delta: float)->void:
	if chtr.is_grounded(): interrupt()
	
	var speed := chtr.velocity
	var offset := (
		Character.caculate_lerp_offset2(speed,
		cruise_speed * direction
		#if move else Vector2.ZERO
		, lerp_strength*delta)
		if move else Vector2.ZERO
	)
	#print("speed ", speed)
	chtr.apply_movement(speed, offset, delta)

func interrupt()->void:
	var remaining := chtr.animation_player.current_animation_length - chtr.animation_player.current_animation_position
	if remaining > ending_lag:
		chtr.animation_player.advance( remaining - ending_lag )
