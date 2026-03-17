@abstract
extends Node2D
class_name State

@onready var chtr : Character = get_node("../..")

@abstract func enter(...args)->void
@abstract func apply(delta: float)->void
