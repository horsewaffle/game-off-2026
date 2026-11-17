class_name CardUI
extends Control

signal card_selected(ref: CardUI)
signal card_unselected(ref: CardUI)

const card_scene = preload("res://scenes/ui/card_ui.tscn")

@onready
var hand_controller = $".."

@onready
var order_label = $OrderLabel
var order_label_value = -1

var target_pos: Vector2
var _offset_pos: Vector2 = Vector2(0,0)
var is_selected: bool = false

var main_icon: String
var context_left: String
var context_right: String
var proxied_card: Card

static func card_ui_builder(icon: String, ctx_left: String, ctx_right: String, prx_card: Card) -> CardUI:
	var card_ui_built = card_scene.instantiate()
	card_ui_built.values_init(icon, ctx_left, ctx_right, prx_card)
	return card_ui_built

func values_init(icon: String, ctx_left: String, ctx_right: String, prx_card: Card):
	self.main_icon = icon
	self.context_left = ctx_left
	self.context_right = ctx_right
	self.proxied_card = prx_card
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_display()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	target_pos = position
	
func _process(delta) -> void:
	if (target_pos != null):
		position = position.lerp(target_pos, 15 * delta)
	offset_transform_position_ratio = offset_transform_position_ratio.lerp(_offset_pos, 30 * delta)


func init_display():
	var attr1_val_panel = find_child("Attr1Val", true)
	# var icon_panel = find_child("Icon", true)
	var attr2_val_panel = find_child("Attr2Val", true)
	
	# icon_panel.texture.load_path = self.main_icon 
	attr1_val_panel.text = self.context_left
	attr2_val_panel.text = self.context_right

func _on_mouse_entered():
	_offset_pos.y -= 0.15
	

func _on_mouse_exited():
	_offset_pos.y += 0.15

func update_order_label(value: int):
	order_label_value = str(value)
	order_label.get_child(0).text = order_label_value

# TODO: Rather than this being on GUI input, move to signal from a controller?
func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed == false:
		is_selected = !is_selected
		if is_selected:
			card_selected.emit(self)
			order_label.visible = true
			_offset_pos.y -= 0.15
		else:
			card_unselected.emit(self)
			order_label.visible = false
			_offset_pos.y += 0.15
