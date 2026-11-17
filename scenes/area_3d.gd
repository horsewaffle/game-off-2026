class_name HighlightedTile
extends Area3D

signal element_activated(pos_2d: Vector2i)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	self.input_event.connect(_on_input_event)

func _on_mouse_entered():
	print("hello mouse")
	
func _on_mouse_exited():
	print("goodbye mouse")
	
func _on_input_event(_camera, event: InputEvent, _event_pos, _normal, _shape):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed == false:
		
		@warning_ignore("narrowing_conversion")
		var pos_2d = Vector2i(position.x, position.z)
		
		element_activated.emit(pos_2d)
