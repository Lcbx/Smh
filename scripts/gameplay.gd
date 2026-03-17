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
	
	#print("jump_requested ", player.jump_requested)
	#print("attack_requested ", player.attack_requested)
	#print("special_requested ", player.special_requested)
	
	#print("event ", event)
	#print("position ", player.position)
	#print("velocity ", player.velocity)
	#print("")

# this is for when we use sticks / implement bots
# (though for bots we might not want to think every frame)
func gatherInput() -> void:
	player.stick_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _on_stage_exit(body: Node2D) -> void:
	if body is Character and immediate_respawn:
		# TODO : clear all statuses, add some invincibility frames
		body.velocity = Vector2.ZERO
		body.enter(body.GROUND_STATE)
		body.teleport(respawn_point.position)


func _on_timer_timeout() -> void:
	print("char2 jump")
	$Character2.jump_requested = true
	await get_tree().physics_frame
	await get_tree().physics_frame
	$Character2.jump_requested = false
