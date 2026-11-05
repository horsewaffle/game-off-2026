extends Node3D

@onready var board = $Board
@onready var player = $PlayerCharacter
@onready var enemy = $Enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var player_registered: bool = board.register_entity(player)
	
	if not player_registered:
		push_error("Failed to register PlayerCharacter with Board")
	
	var enemy_registered: bool = board.register_entity(enemy)
	
	if not enemy_registered:
		push_error("Failed to register Enemy with Board")
