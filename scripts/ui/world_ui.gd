extends Control

var player: PlayerController
var attack_button

@onready
var health_bar: ProgressBar = $"PlayerUIBottom/PlayerStatsContainer/StatsVBox/HealthBar"

@onready
var xp_bar: ProgressBar = $"PlayerUIBottom/PlayerStatsContainer/StatsVBox/XPBar"

# TODO: Better way to propagate this than just passing it up?
signal ui_attack_prepared(target_pos: Vector2i)

func init_stats(player_ref: PlayerController):
	player = player_ref
	player.enemy_turn_triggered.connect(_on_enemy_turn_triggered)
	
	health_bar.max_value = player.fightable.max_health
	health_bar.value = player.fightable.health
	xp_bar.value = player.fightable.xp
	
	player.fightable.health_updated.connect(_on_health_update)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_button = $AttackButtonPanel/AttackButton
	attack_button.ui_attack_prepared.connect(_on_ui_attack_prepared)
	attack_button.attack_button_pressed.connect(_on_attack_button_pressed)

	
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
