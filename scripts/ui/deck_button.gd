extends TextureButton

const card: PackedScene = preload("res://scenes/ui/card_ui.tscn")

@onready
var hand: HBoxContainer = get_node("../../DrawnCardsContainer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _pressed() -> void:
	var drawn_card = Card.new("card_id", "card_name", "card_desc", card_on_activate)
	var drawn_card_ui = CardUI.card_ui_builder("test", "1", "R", drawn_card)
	hand.add_child(drawn_card_ui)
		
	
static func card_on_activate():
	print("burger")
