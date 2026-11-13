class_name CardUI
extends Control

const card_scene = preload("res://scenes/ui/card_ui.tscn")

var main_icon: String
var context_left: String
var context_right: String
var proxied_card: Card

static func card_ui_builder(icon: String, ctx_left: String, ctx_right: String, prx_card: Card) -> CardUI:
	var card_ui_built = card_scene.instantiate()
	card_ui_built.values_init(icon, ctx_left, ctx_right, prx_card)
	print("builder")
	return card_ui_built

func values_init(icon: String, ctx_left: String, ctx_right: String, prx_card: Card):
	self.main_icon = icon
	self.context_left = ctx_left
	self.context_right = ctx_right
	self.proxied_card = prx_card
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_display()


func init_display():
	var attr1_val_panel = find_child("Attr1Val", true)
	# var icon_panel = find_child("Icon", true)
	var attr2_val_panel = find_child("Attr2Val", true)
	
	# icon_panel.texture.load_path = self.main_icon 
	attr1_val_panel.text = self.context_left
	attr2_val_panel.text = self.context_right
	print("display init")
