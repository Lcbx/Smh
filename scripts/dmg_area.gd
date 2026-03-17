@tool
extends Area2D
class_name DmgArea

@export var power : float = 5.0 :
	set(value):
		power = value
		update_line()
@export var angle : float = -5.0 :
	set(value):
		angle = value
		update_line()

@export var disable_time : float = 0.17

func _ready() -> void:
	update_line()

var _chtr : Character
func register(chtr:Character, ...args)->void:
	_chtr = chtr
	self.body_entered.connect(args[0] if args else handle)

func calculate_launch():
	return Vector2(1, 0.0).rotated(deg_to_rad(angle)) * _chtr.collision.scale

func handle(body:CollisionObject2D)->void:
	if body is Character and body != _chtr:
		#print('hi', body.name, " from ", _chtr.name)
		body.receive_damage(power, calculate_launch())
		temp_disable.call_deferred()

func temp_disable()->void:
		self.monitoring = false 
		(get_tree().create_timer(disable_time).timeout
		.connect(func():self.monitoring = true))

func update_line()->void:
	if Engine.is_editor_hint():
		var line := self.get_node_or_null("debug_line") as Line2D
		if line == null:
			line = Line2D.new()
			line.name = "debug_line"
			self.add_child(line)
		line.clear_points()
		var rads = deg_to_rad(angle)
		line.default_color = Color.BLUE_VIOLET
		line.add_point(Vector2.ZERO)
		line.add_point(Vector2(cos(rads), sin(rads)) * power * 5.0)
		line.width = 3.0
		line.z_index = 1
