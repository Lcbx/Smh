@abstract
extends Node2D
class_name State

@onready var chtr : Character = get_node("../..")

@abstract func enter(...args)->void
@abstract func apply(delta: float)->void

# applioed when receiving damage
@export var damage_impulse_mult :float= 0.07
@export var damage_hitstun_mult :float= 0.02
@export var longstun_duration :float= 1.0

@onready var HITSTUN_STATE : State = %HitstunState

# TODO :
# * add hitstun state / calculate hitstun duration
# * apply hyperarmor
# * add hard stun when health dips under 0
func receive_damage(power:float, dir:Vector2)->void:
	chtr.health -= power
	# assuming max health is 100, impulse is doubled at 0 health
	var impulse_value = (200.0 - chtr.health) * damage_impulse_mult * power * power
	chtr.impulse += dir * impulse_value
	
	var hitstun_duration:float = clampf(damage_hitstun_mult * power, 0.0, 0.4)
	
	# TODO : add visual indicator of long stun
	# maybe make that be handled by hitstun state, with stronger visual with longer stuns
	if chtr.health < 0.0: hitstun_duration = longstun_duration
	
	print(chtr.name, ' health ', chtr.health, ' impulse ', chtr.impulse, ' hitstun ', hitstun_duration)
	chtr.enter(HITSTUN_STATE, hitstun_duration)
	
