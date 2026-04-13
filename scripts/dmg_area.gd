@tool
extends Area2D
class_name DmgArea

@export var damage : float = 5.0 :
	set(value):
		damage = value
		update()

@export var impulse : float = 2.0 :
	set(value):
		impulse = value
		update()

@export var hitstun : float = 0.1 :
	set(value):
		hitstun = value
		update()

@export var angle : float = -10.0 :
	set(value):
		angle = value
		update()

func update()->void:
	_impulse = Vector2.RIGHT.rotated(deg_to_rad(angle)) * impulse
	update_line(damage, Color.RED)
	update_line(impulse, Color.BLUE)
	update_line(hitstun * 20.0, Color.GREEN)

@export var disable_time : float = 0.17

var _impulse : Vector2

func _ready() -> void:
	# use prefab instead of setting those fields in ready
	#self.monitorable = false
	#self.monitoring = false
	#self.collision_layer = 0
	#self.collision_mask = 2
	if Engine.is_editor_hint():
		for c in self.get_children():
			if c.name.begins_with(debugLineName):
				c.queue_free()
	update()

var _chtr : Character
func register(chtr:Character, ...args)->void:
	_chtr = chtr
	self.body_entered.connect(args[0] if args else handle)

func handle(body:CollisionObject2D)->void:
	var victim := body as Character
	var final_impulse = _impulse * _chtr.collision.scale 
	
	if victim and victim != _chtr:
		#print('hi', body.name, " from ", _chtr.name)
		
		if damage > 0.0:
			victim._state.receive_damage(damage, final_impulse, hitstun)
			#temp_disable.call_deferred()
		else:
			victim.impulse += final_impulse

func temp_disable()->void:
		self.monitoring = false 
		( get_tree().create_timer(disable_time).timeout.connect(
		func():self.monitoring = true
		))

const debugLineName := "debug_line_"
const debugLineSize := 1.5
const debugLineLength := 5.0

func update_line(value:float, color:Color)->void:
	if Engine.is_editor_hint() and get_parent() and value > 0.0:
		var name := debugLineName + color.to_html()
		var line := self.get_node_or_null(name) as Line2D
		if line == null:
			line = Line2D.new()
			line.name = name
			self.add_child(line)
		line.clear_points()
		line.default_color = color
		var index:int = get_parent().get_child_count() - line.get_index()
		var start = Vector2.RIGHT.rotated(deg_to_rad(angle + 90)) * debugLineSize * index
		line.add_point(start)
		line.add_point(start + _impulse * value * debugLineLength)
		line.width = debugLineSize
		line.z_index = 1
