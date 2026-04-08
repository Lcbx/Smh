@tool
extends Area2D
class_name DmgArea

@export var power : float = 5.0 :
	set(value):
		power = value
		update()

@export var impulse : float = 0.0 :
	set(value):
		impulse = value
		update()

@export var angle : float = -10.0 :
	set(value):
		angle = value
		update()

func update()->void:
	_dir = Vector2.RIGHT.rotated(deg_to_rad(angle))
	update_line(power, Color.BLUE_VIOLET)
	update_line(impulse, Color.BISQUE)

@export var disable_time : float = 0.17

var _dir : Vector2

func _ready() -> void:
	update()

var _chtr : Character
func register(chtr:Character, ...args)->void:
	_chtr = chtr
	self.body_entered.connect(args[0] if args else handle)

func handle(body:CollisionObject2D)->void:
	var victim := body as Character
	var impulse_dir = _dir * _chtr.collision.scale
	
	if victim and victim != _chtr:
		#print('hi', body.name, " from ", _chtr.name)
		
		if power > 0.0:
			victim._state.receive_damage(power, impulse_dir)
			temp_disable.call_deferred()
		
		if impulse > 0.0:
			victim.impulse += impulse_dir * impulse * impulse

func temp_disable()->void:
		self.monitoring = false 
		( get_tree().create_timer(disable_time).timeout.connect(
		func():self.monitoring = true
		))

func update_line(value:float, color:Color)->void:
	if Engine.is_editor_hint() and value > 0.0:
		var name := "debug_" + str(color)
		var line := self.get_node_or_null(name) as Line2D
		if line == null:
			line = Line2D.new()
			line.name = name
			self.add_child(line)
		line.clear_points()
		var rads = deg_to_rad(angle)
		line.default_color = color
		line.add_point(Vector2.ZERO)
		line.add_point(Vector2(cos(rads), sin(rads)) * value * 5.0)
		line.width = 3.0
		line.z_index = 1
