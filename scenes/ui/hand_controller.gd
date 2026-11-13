class_name HandController
extends Panel

var selected_cards: Array[CardUI]

func add_card_to_hand(card_ui: CardUI):
	add_child(card_ui)
	card_ui.set_position(Vector2(-50, (size.y / 2) - 65))
	card_ui.card_selected.connect(_on_card_selected)
	card_ui.card_unselected.connect(_on_card_unselected)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_card_selected(card_ui: CardUI):
	selected_cards.append(card_ui)
	card_ui.update_order_label(selected_cards.size())

func _on_card_unselected(card_ui: CardUI):
	selected_cards.erase(card_ui)
	card_ui.update_order_label(-1)
	for idx in range(0, selected_cards.size()):
		selected_cards[idx].update_order_label(idx + 1)
