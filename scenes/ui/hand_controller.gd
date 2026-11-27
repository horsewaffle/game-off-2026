class_name HandController
extends NinePatchRect

var selected_cards_ui: Array[CardUI]

signal selected_cards_updated(selected_cards: Array[Card])

func add_card_to_hand(card_ui: CardUI):
	add_child(card_ui)
	card_ui.set_position(Vector2(-50, (size.y / 2) - 65))
	card_ui.card_selected.connect(_on_card_selected)
	card_ui.card_unselected.connect(_on_card_unselected)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_card_selected(card_ui: CardUI):
	selected_cards_ui.append(card_ui)
	card_ui.update_order_label(selected_cards_ui.size())
	update_selected_cards()

func _on_card_unselected(card_ui: CardUI):
	selected_cards_ui.erase(card_ui)
	card_ui.update_order_label(-1)
	for idx in range(0, selected_cards_ui.size()):
		selected_cards_ui[idx].update_order_label(idx + 1)
	update_selected_cards()

func update_selected_cards():
	var selected_cards: Array[Card] = []
	for card in selected_cards_ui:
		selected_cards.append(card.proxied_card)
	selected_cards_updated.emit(selected_cards)
