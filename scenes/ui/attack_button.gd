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

var active_elements: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = game_root.find_child("PlayerCharacter")
	
	player.player_turn_taken.connect(_on_player_turn_taken)


func _pressed() -> void:
	
	destroy_active_elements()
	for offset in [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]:
		var test_asset = tile_highlight.instantiate()
		
		test_asset.position = player.position
		test_asset.position.x += offset.x
		test_asset.position.y = 0.02
		test_asset.position.z += offset.y
		
		ui_root.add_child(test_asset)
		test_asset.element_activated.connect(_on_highlighted_tile_clicked)
		active_elements.append(test_asset)

# Reset UI elements if the player takes a turn
func _on_player_turn_taken():
	destroy_active_elements()

func _on_highlighted_tile_clicked(tile_pos: Vector2i):
	# TODO: Wrap fight logic in function rather than hardcoded in movement
	print("Attacking tile at ", tile_pos.x, ":", tile_pos.y)
	destroy_active_elements()
	
func destroy_active_elements():
	for element in active_elements:
		element.element_activated.disconnect(_on_highlighted_tile_clicked)
		element.queue_free()
	active_elements.clear()
