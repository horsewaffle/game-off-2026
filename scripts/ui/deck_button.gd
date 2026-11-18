extends Button

signal card_drawn

const card: PackedScene = preload("res://scenes/ui/card_ui.tscn")

@onready
var hand: Panel = get_node("../../DrawnCardsContainer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _pressed() -> void:
	card_drawn.emit()

func draw_card(card: Card):
	if card == null:
		return
	var card_info = CardFunctions.get_card_info(card.id)
	# TODO: Return dict with keys rather than array
	var drawn_card_ui = CardUI.card_ui_builder(card_info[0], card_info[1], card_info[2], card)
	hand.add_card_to_hand(drawn_card_ui)
	update_card_poses_in_hand()

func update_card_poses_in_hand():
	for iter_card in hand.get_children():
		var hand_ratio = 0.5
		if hand.get_child_count() != 1:
			hand_ratio = float(iter_card.get_index()) / float(hand.get_child_count() - 1)

		iter_card.target_pos.x = 20 + hand_ratio * (hand.size.x - (iter_card.size.x + 40 ))
		iter_card.target_pos.y = -40
		
	
static func card_on_activate(damage: int):
	return damage + 1
