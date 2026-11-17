class_name AttackButton
extends Button

const tile_highlight = preload("res://scenes/ui/tile_highlight.tscn")
@onready
var hand: HandController = $"../../PlayerUIBottom/DrawnCardsContainer"
@onready
var ui_root: Control = $"../.."
@onready
var game_root: Node3D = $"../../.."
@onready
var player: PlayerController

signal attack_button_pressed

# TODO: Better way to propagate this than just passing it up?
signal ui_attack_prepared(target_pos: Vector2i)

var active_elements: Array

func _pressed() -> void:
	destroy_active_elements()
	attack_button_pressed.emit()

func spawn_adjacent_tile_highlights(root_pos: Vector2i):
	for offset in [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]:
			var test_asset = tile_highlight.instantiate()
			
			test_asset.position = Vector3(root_pos.x, 0.02, root_pos.y)
			test_asset.position.x += offset.x
			test_asset.position.y = 0.02
			test_asset.position.z += offset.y
			
			ui_root.add_child(test_asset)
			test_asset.element_activated.connect(_on_highlighted_tile_clicked)
			active_elements.append(test_asset)

# Reset UI elements if the player takes a turn
func on_player_turn_taken():
	destroy_active_elements()

func _on_highlighted_tile_clicked(tile_pos: Vector2i):

	ui_attack_prepared.emit(tile_pos)
	destroy_active_elements()
	
func destroy_active_elements():
	for element in active_elements:
		element.element_activated.disconnect(_on_highlighted_tile_clicked)
		element.queue_free()
	active_elements.clear()
