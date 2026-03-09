extends Node2D

@onready var player:CharacterBody2D = $Character

#TODO: implement input buffer
func _ready() -> void:
	player.input.connect(gatherInput)

func gatherInput() -> void:
	player.stick_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	player.jump_requested = Input.is_action_just_pressed("ui_accept")
	player.attack_requested = Input.is_action_just_pressed("attack")
	player.special_requested = Input.is_action_just_pressed("special")
