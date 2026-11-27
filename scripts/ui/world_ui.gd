extends Control

var player: PlayerController

@onready
var health_bar: ProgressBar = find_child("HealthBar")

@onready
var xp_bar: ProgressBar = find_child("XPBar")

@onready
var hand: HandController = find_child("DrawnCardsContainer")

@onready
var attack_button = find_child("AttackButton")

@onready
var deck_button = find_child("DeckButton")

# TODO: Better way to propagate this than just passing it up?
signal ui_attack_prepared(target_pos: Vector2i)

func init_stats(player_ref: PlayerController):
	player = player_ref
	player.enemy_turn_triggered.connect(_on_enemy_turn_triggered)
	
	health_bar.max_value = player.fightable.max_health
	health_bar.value = player.fightable.health
	xp_bar.value = player.fightable.xp
	
	player.fightable.health_updated.connect(_on_health_update)
	
	hand.selected_cards_updated.connect(_on_selected_cards_updated)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_button.ui_attack_prepared.connect(_on_ui_attack_prepared)
	attack_button.attack_button_pressed.connect(_on_attack_button_pressed)
	
	deck_button.card_drawn.connect(_on_card_drawn)
	

	
func _process(_delta):
	attack_button.disabled = !player.can_take_action
	
func _on_ui_attack_prepared(target_pos: Vector2i):
	ui_attack_prepared.emit(target_pos)
	
func _on_attack_button_pressed():
	@warning_ignore("narrowing_conversion")
	var player_pos_2d = Vector2i(player.position.x, player.position.z)
	attack_button.spawn_adjacent_tile_highlights(player_pos_2d)

func _on_enemy_turn_triggered():
	attack_button.on_player_turn_taken()
	
func _on_health_update(new_health: int):
	health_bar.max_value = player.fightable.max_health
	health_bar.value = new_health

func _on_selected_cards_updated(selected_cards: Array[Card]):
	player.selected_cards = selected_cards

func _on_card_drawn():
	if hand.get_child_count() < player.max_hand_size:
		var drawn_card = player.deck.draw_one()
		deck_button.draw_card(drawn_card)
