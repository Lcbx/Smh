extends Node2D

@onready var player:Character = $Character
@onready var stageArea:Area2D = $StageArea
@onready var respawn_point:Node2D = $respawnPoint

@export var immediate_respawn:bool = true

func _ready() -> void:
	player.input.connect(gatherInput)
	stageArea.body_exited.connect(_on_stage_exit)
	print('immediate_respawn ', immediate_respawn)

#TODO: implement input buffer in Character
func _input(event: InputEvent) -> void:
	if event is InputEventMouse: return
	player.jump_requested = Input.is_action_just_pressed("ui_accept")
	player.attack_requested = Input.is_action_just_pressed("attack")
	player.special_requested = Input.is_action_just_pressed("special")
	#print("event ", event)
	#print("position ", player.position)
	#print("velocity ", player.velocity)
	#print("")

# this is for when we use sticks / implement bots
# (though for bots we might not want to think every frame)
func gatherInput() -> void:
	player.stick_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _on_stage_exit(body: Node2D) -> void:
	if is_instance_of(body,Character) and immediate_respawn:
		# TODO : clear all statuses, add some invincibility frames
		player.velocity = Vector2.ZERO
		player.enter(player.GROUND_STATE)
		player.teleport(respawn_point.position)
