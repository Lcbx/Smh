@abstract
extends Node2D
class_name State

@onready var chtr : Character = get_node("../..")

@abstract func enter(...args)->void
@abstract func apply(delta: float)->void

@onready var HITSTUN_STATE : State = %HitstunState

# TODO :
# * add hitstun state / calculate hitstun duration
# * apply hyperarmor
# * add hard stun when health dips under 0
func receive_damage(damage:float, impulse:Vector2, hitstun)->void:
	if damage>0.0:
		chtr.health -= damage
	
	# assuming max health is 100, impulse is doubled at 0 health
	chtr.impulse += (200.0 - chtr.health) * impulse
	
	# TODO : add visual indicator of long stun
	# maybe make that be handled by hitstun state, with stronger visual with longer stuns
	var hitstun_duration:float = hitstun if chtr.health > 0.0 else 1.0
	
	print(chtr.name, ' health ', chtr.health, ' impulse ', chtr.impulse, ' hitstun ', hitstun_duration)
	if hitstun_duration > 0.0:
		chtr.enter(HITSTUN_STATE, hitstun_duration)
	
