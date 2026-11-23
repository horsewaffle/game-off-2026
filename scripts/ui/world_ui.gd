extends Control

var player: PlayerController

@onready
var health_bar: ProgressBar = $"PlayerUIBottom/PlayerStatsContainer/StatsVBox/HealthBar"

@onready
var xp_bar: ProgressBar = $"PlayerUIBottom/PlayerStatsContainer/StatsVBox/XPBar"

@onready
var hand: HandController = $"PlayerUIBottom/DrawnCardsContainer"

@onready
var attack_button = $AttackButtonPanel/AttackButton

@onready
var deck_button = $"PlayerUIBottom/DeckContainer/Button"

var fade_in: bool = false
var fade_in_percentage: float = 0

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
	

	
func _process(delta):
	if player != null:
		attack_button.disabled = !player.can_take_action
	
	if fade_in and fade_in_percentage <= 1:
		fade_in_percentage += delta / 3
		$FadeRect.set_modulate(lerp($FadeRect.get_modulate(), Color(0.0, 0.0, 0.0, 0.0), fade_in_percentage))
		print(fade_in_percentage)
		if fade_in_percentage >= 1:
			fade_in_percentage = 1
			fade_in = false
	
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

func trigger_fade_in():
	fade_in = true
